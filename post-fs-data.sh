#!/system/bin/sh
MODPATH="${0%/*}"
. $MODPATH/common_func.sh

boot="/data/adb/service.d"
placeholder="/data/adb/modules/playintegrity/webroot/common_scripts"
PLAYSTORE="/data/adb/Box-Brain/playstore"
mkdir -p "$boot"

# Remove installation script if exists 
if [ -f "/data/adb/modules/playintegrity/customize.sh" ]; then
  rm -rf "/data/adb/modules/playintegrity/customize.sh"
fi

# Remove override flag if exists 
if [ -f "/data/adb/Box-Brain/.los" ]; then
  rm -rf "/data/adb/Box-Brain/.los"
fi

# create dummy placeholder files to fix broken translations in webui
touch "$placeholder/meowdump"
touch "$placeholder/boot_hash"
touch "$placeholder/vending"
touch "$placeholder/support"
touch "$placeholder/app.sh"
touch "$placeholder/user.sh"
touch "$placeholder/patch.sh"
touch "$placeholder/pif.sh"
touch "$placeholder/resetprop.sh"
touch "$placeholder/kill.sh"
touch "$placeholder/report"
touch "$placeholder/start"
touch "$placeholder/stop"

if [ ! -f "$placeholder/override_lineage.sh" ]; then
  cat <<'EOF' > "$placeholder/override_lineage.sh"
#!/system/bin/sh

# nuke flag if exists
if [ -f "/data/adb/Box-Brain/override" ]; then
  rm -rf "/data/adb/Box-Brain/override"
fi

# check prop
echo " Checking for Lineage Props"
getprop | grep -i lineage
echo " "

# config
PROP_FILE="/data/adb/modules/playintegrity/system.prop"
LOG_FILE="/data/adb/Box-Brain/Integrity-Box-Logs/prop_debug.log"

# init logging
echo "[prop spoof debug log]" > "$LOG_FILE"
echo "[INFO] Script started at $(date)" >> "$LOG_FILE"

# check file
if [ ! -f "$PROP_FILE" ]; then
    echo "[ERROR] Prop file not found: $PROP_FILE" >> "$LOG_FILE"
    exit 1
fi

if [ ! -r "$PROP_FILE" ]; then
    echo "[ERROR] Cannot read prop file: $PROP_FILE" >> "$LOG_FILE"
    exit 1
fi

# process lines
while IFS= read -r line || [ -n "$line" ]; do
    # Strip [brackets] if present
    clean_line=$(echo "$line" | sed -E 's/^\[(.*)\]=\[(.*)\]$/\1=\2/')

    # Skip empty or comment lines
    if [ -z "$clean_line" ] || echo "$clean_line" | grep -qE '^#'; then
        echo "[SKIP] Empty or comment: $line" >> "$LOG_FILE"
        continue
    fi

    key=$(echo "$clean_line" | cut -d '=' -f1)
    value=$(echo "$clean_line" | cut -d '=' -f2-)

    # Sanity check
    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "[SKIP] Malformed line: $line" >> "$LOG_FILE"
        continue
    fi

    case "$key" in
        init.svc.*|ro.boottime.*)
            echo "[SKIP] Dynamic prop (not changeable): $key" >> "$LOG_FILE"
            continue
            ;;
        ro.crypto.state)
            echo "[SKIP] Encryption state spoof skipped: $key" >> "$LOG_FILE"
            continue
            ;;
        *)
            # Attempt to override using resetprop
            resetprop "$key" "$value"
            # Check if the change was successful
            actual_value=$(getprop "$key")
            if [ "$actual_value" = "$value" ]; then
                echo "[OK] Overridden: $key=$value" >> "$LOG_FILE"
            else
                echo "[WARN] Failed to override: $key. Current value: $actual_value" >> "$LOG_FILE"
            fi
            ;;
    esac
done < "$PROP_FILE"

echo "[INFO] Script completed at $(date)" >> "$LOG_FILE"
echo "•••••••••••••••••••••=" >> "$LOG_FILE"
echo " "
echo " "
echo " LINEAGE PROPS AFTER OVERRIDE:"
echo " "
getprop | grep -i lineage
touch "/data/adb/Box-Brain/.los"
exit 0
EOF
fi

chmod 755 "$placeholder/override_lineage.sh"
  
if [ ! -f "$boot/hash.sh" ]; then
  cat <<'EOF' > "$boot/hash.sh"
#!/system/bin/sh

HASH_FILE="/data/adb/Box-Brain/hash.txt"
LOG_DIR="/data/adb/Box-Brain/Integrity-Box-Logs"
LOG_FILE="$LOG_DIR/vbmeta.log"

mkdir -p "$LOG_DIR"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG_FILE"
}

log " "
log "Script started"

# Find resetprop
RESETPROP=""
for RP in \
  /sbin/resetprop \
  /system/bin/resetprop \
  /system/xbin/resetprop \
  /data/adb/magisk/resetprop \
  /data/adb/ksu/bin/resetprop \
  $(command -v resetprop 2>/dev/null)
do
  if [ -x "$RP" ]; then
    RESETPROP="$RP"
    break
  fi
done

if [ -z "$RESETPROP" ]; then
  log "ERROR: resetprop binary not found. Exiting."
  exit 0
fi

log "Using resetprop: $RESETPROP"

# Always set static default props
"$RESETPROP" ro.boot.vbmeta.size "4096"
"$RESETPROP" ro.boot.vbmeta.hash_alg "sha256"
"$RESETPROP" ro.boot.vbmeta.avb_version "2.0"
"$RESETPROP" ro.boot.vbmeta.device_state "locked"
log "Set static VBMeta props: size=4096, hash_alg=sha256, avb_version=2.0, device_state=locked"

# Handle hash
if [ ! -s "$HASH_FILE" ]; then
  log "Hash file missing or empty : clearing vbmeta.digest"
  "$RESETPROP" --delete ro.boot.vbmeta.digest
  exit 0
fi

# Extract hash
DIGEST=$(tr -cd '0-9a-fA-F' < "$HASH_FILE")

if [ -z "$DIGEST" ]; then
  log "Hash file contained no valid hex. Clearing vbmeta.digest."
  "$RESETPROP" --delete ro.boot.vbmeta.digest
  exit 0
fi

if [ "${#DIGEST}" -ne 64 ]; then
  log "Invalid hash length (${#DIGEST}). Expected 64 (SHA-256). Clearing vbmeta.digest."
  "$RESETPROP" --delete ro.boot.vbmeta.digest
  exit 0
fi

# Set digest if valid
"$RESETPROP" ro.boot.vbmeta.digest "$DIGEST"
log "Set ro.boot.vbmeta.digest = $DIGEST"
log " "

exit 0
EOF
fi

chmod 777 "$boot/hash.sh"

if [ ! -f "$boot/prop.sh" ]; then
  cat <<'EOF' > "$boot/prop.sh"
#!/system/bin/sh
writelog() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
    /system/bin/log -t PATCH_OVERRIDE "$1"
}

# Function to check and set property if needed
check_and_set_prop() {
    local PROP=$1
    local VALUE=$2

    local CURRENT
    CURRENT=$(getprop "$PROP")

    if [ "$CURRENT" = "$VALUE" ]; then
        writelog " $PROP is already set to $VALUE : no change needed"
    else
        if resetprop "$PROP" "$VALUE"; then
            writelog " Set $PROP to $VALUE (was: $CURRENT)"
        else
            writelog " Failed to set $PROP (current: $CURRENT)"
        fi
    fi
}

# Log file
LOG_FILE="/data/adb/Box-Brain/Integrity-Box-Logs/prop_patch.log"

writelog "•••••• Overriding Security Patch ••••••"

# Desired patch level
PATCH_DATE="2025-10-05"
FILE_PATH="/data/adb/tricky_store/security_patch.txt"

mkdir -p "/data/adb/tricky_store"
echo "all=$PATCH_DATE" > "$FILE_PATH" 2>>"$LOG_FILE"

# Check if resetprop exists
if ! command -v resetprop >/dev/null 2>&1; then
    writelog " resetprop not found"
    exit 1
fi

# Apply only if needed
check_and_set_prop ro.build.version.security_patch "$PATCH_DATE"
check_and_set_prop ro.vendor.build.security_patch "$PATCH_DATE"

# Final verification
BUILD_VAL=$(getprop ro.build.version.security_patch)
VENDOR_VAL=$(getprop ro.vendor.build.security_patch)

if [ "$BUILD_VAL" = "$PATCH_DATE" ] && [ "$VENDOR_VAL" = "$PATCH_DATE" ]; then
    writelog " Both security patch props are correctly set to $PATCH_DATE"
else
    writelog " Final verification failed: one or both props are incorrect"
fi

writelog "•••••• Script finished ••••••"
exit 0
EOF
fi

chmod 777 "$boot/prop.sh"

if [ -e "$PLAYSTORE" ]; then
    echo "Disabling PixelPlaystore" >> /data/adb/Box-Brain/PixelStore.log
    resetprop -n persist.sys.pixelprops.vending false
else
    echo "Playstore flag is disabled, no action needed" >> /data/adb/Box-Brain/PixelStore.log
fi

if [ -d "/data/adb/modules/playintegrityfix" ]; then
    pif "PIF module detected, Script mode has been disabled"
    pif " [ post-fs-data.sh ] "
    exit 0
fi

# Add recommended process in denylist for better root hiding
if [ -d "/data/adb/magisk" ]; then
    add_if_missing com.google.android.gms
    add_if_missing com.google.android.gms com.google.android.gms.unstable
    add_if_missing com.android.vending
#    add_if_missing com.google.android.gsf
#    add_if_missing com.google.android.gsf com.google.process.gapps
#    add_if_missing com.google.android.gsf com.google.process.gservices
fi

exit 0