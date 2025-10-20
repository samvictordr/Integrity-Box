#!/system/bin/sh

# Module path and file references
LOG_DIR="/data/adb/Box-Brain/Integrity-Box-Logs"
PROP="/data/adb/modules/playintegrity/system.prop"
LINE="ro.crypto.state=encrypted"
PIF="/data/adb/modules/playintegrityfix"
LOG="$LOG_DIR/service.log"
LOG2="$LOG_DIR/encrypt.log"
LOG3="$LOG_DIR/autopif.log"
LOG4="$LOG_DIR/twrp.log"

# Log folder
mkdir -p "$LOGDIR"

# Logger function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOG"
}

# SELinux spoofing
if [ -f /data/adb/Box-Brain/selinux ]; then
    if command -v setenforce >/dev/null 2>&1; then
        current=$(getenforce)
        if [ "$current" != "Enforcing" ]; then
            setenforce 1
            log "SELINUX Spoofed successfully"
        fi
    fi
fi

# Module install path
export MODPATH="/data/adb/modules/playintegrity"

NO_LINEAGE_FLAG="/data/adb/Box-Brain/NoLineageProp"
NODEBUG_FLAG="/data/adb/Box-Brain/nodebug"
TAG_FLAG="/data/adb/Box-Brain/tag"

TMP_PROP="$MODPATH/tmp.prop"
SYSTEM_PROP="$MODPATH/system.prop"
> "$TMP_PROP" # clear old temp file

# Build summary of active flags
FLAGS_ACTIVE=""
[ -f "$NO_LINEAGE_FLAG" ] && FLAGS_ACTIVE="$FLAGS_ACTIVE NoLineageProp"
[ -f "$NODEBUG_FLAG" ] && FLAGS_ACTIVE="$FLAGS_ACTIVE nodebug"
[ -f "$TAG_FLAG" ] && FLAGS_ACTIVE="$FLAGS_ACTIVE tag"

if [ -n "$FLAGS_ACTIVE" ]; then
    log "Prop sanitization flags active: $FLAGS_ACTIVE"
    log "Preparing temporary prop file..."
    getprop | grep "userdebug" >> "$TMP_PROP"
    getprop | grep "test-keys" >> "$TMP_PROP"
    getprop | grep "lineage_" >> "$TMP_PROP"

    # Basic cleanup
    sed -i 's///g' "$TMP_PROP"
    sed -i 's/: /=/g' "$TMP_PROP"
else
    log "No prop sanitization flags found. Skipping."
fi

# LineageOS cleanup
if [ -f "$NO_LINEAGE_FLAG" ]; then
    log "NoLineageProp flag detected. Deleting LineageOS props..."
    for prop in \
        ro.lineage.build.version \
        ro.lineage.build.version.plat.rev \
        ro.lineage.build.version.plat.sdk \
        ro.lineage.device \
        ro.lineage.display.version \
        ro.lineage.releasetype \
        ro.lineage.version \
        ro.lineagelegal.url; do
        resetprop --delete "$prop"
    done
    sed -i 's/lineage_//g' "$TMP_PROP"
    log "LineageOS props sanitized."
fi

# userdebug → user
if [ -f "$NODEBUG_FLAG" ]; then
    if grep -q "userdebug" "$TMP_PROP"; then
        sed -i 's/userdebug/user/g' "$TMP_PROP"
    fi
    log "userdebug → user sanitization applied."
fi

# test-keys → release-keys
if [ -f "$TAG_FLAG" ]; then
    if grep -q "test-keys" "$TMP_PROP"; then
        sed -i 's/test-keys/release-keys/g' "$TMP_PROP"
    fi
    log "test-keys → release-keys sanitization applied."
fi

# Finalize system.prop
if [ -s "$TMP_PROP" ]; then
    log "Sorting and creating final system.prop..."
    sort -u "$TMP_PROP" > "$SYSTEM_PROP"
    rm -f "$TMP_PROP"
    log "system.prop created at $SYSTEM_PROP."

    log "Waiting 30 seconds before applying props..."
    sleep 30

    log "Applying props via resetprop..."
    resetprop -n --file "$SYSTEM_PROP"
    log "Prop sanitization applied from system.prop"
fi

# Explicit fingerprint sanitization
if [ -f "$NODEBUG_FLAG" ] || [ -f "$TAG_FLAG" ]; then
    fp=$(getprop ro.build.fingerprint)
    fp_clean="$fp"

    [ -f "$NODEBUG_FLAG" ] && fp_clean=${fp_clean/userdebug/user}
    [ -f "$TAG_FLAG" ] && {
        fp_clean=${fp_clean/test-keys/release-keys}
        fp_clean=${fp_clean/dev-keys/release-keys}
    }

    if [ "$fp" != "$fp_clean" ]; then
        resetprop ro.build.fingerprint "$fp_clean"
        [ -f "$NODEBUG_FLAG" ] && resetprop ro.build.type "user"
        [ -f "$TAG_FLAG" ] && resetprop ro.build.tags "release-keys"
        log "Fingerprint sanitized → $fp_clean"
    else
        log "Fingerprint already clean. No changes applied."
    fi
fi

if [ -e "/data/adb/Box-Brain/target" ]; then
    sleep 69
    /data/adb/modules/playintegrity/webroot/common_scripts/user.sh
fi

# Spoof Encryption 
{
  echo "ENCRYPT CHECK ($(date))"

  if [ -f /data/adb/Box-Brain/encrypt ]; then
    if grep -qxF "$LINE" "$PROP"; then
      echo "Line already exists, no action needed"
    else
      echo "$LINE" >> "$PROP"
      echo "Spoofed prop: $LINE"
    fi
  else
    if grep -qxF "$LINE" "$PROP"; then
      sed -i "\|^$LINE\$|d" "$PROP"
      echo "Removed line: $LINE"
    else
      echo "Line not present, no action needed"
    fi
  fi

  echo
} >> "$LOG2" 2>&1

# Rename twrp folder to avoid root detection
{
  echo "TWRP/FOX RENAME ($(date))"
  echo

  rename_recovery_folder() {
    local MARKER="$1"
    local FOLDER="$2"
    local ALT="$3"
    local NAME="$4"

    # Resolve accessible folder path
    if [ -d "$FOLDER" ]; then
      PATH_TO_USE="$FOLDER"
    elif [ -d "$ALT" ]; then
      PATH_TO_USE="$ALT"
    else
      echo " $NAME folder not found at $FOLDER or $ALT"
      return
    fi

    # Verify marker
    if [ ! -f "$MARKER" ]; then
      echo " FLAG $MARKER missing for $NAME  skipping"
      return
    fi

    # Rename or delete
    if [ -z "$(ls -A "$PATH_TO_USE")" ]; then
      rm -rf "$PATH_TO_USE"
      echo " Deleted empty $PATH_TO_USE"
    else
      TARGET="/sdcard/renamed-${NAME,,}-folder-$(date +%Y%m%d-%H%M%S)"
      mv "$PATH_TO_USE" "$TARGET"
      echo " Renamed non-empty $PATH_TO_USE → $TARGET"
    fi
    echo
  }

  # Run for both TWRP and Fox
  rename_recovery_folder "/data/adb/Box-Brain/twrp" "/sdcard/TWRP" "/storage/emulated/0/TWRP" "TWRP"
  rename_recovery_folder "/data/adb/Box-Brain/fox" "/sdcard/Fox" "/storage/emulated/0/Fox" "Fox"

} >> "$LOG4" 2>&1

# Download PIF fingerprint on boot (will fail automatically wen no internet xD)
{
  echo "AUTO PIF EXECUTION"
  echo "Timestamp: $(date)"
  echo "Checking prerequisite: /data/adb/Box-Brain/pif"

  PIF="/data/adb/Box-Brain/pif"

  if [ -f "$PIF" ]; then
    echo "Detected PIF on boot"
    sleep 69

    run_temp_exec() {
      local script="$1"
      if [ ! -r "$script" ]; then
        echo "Script $script not readable ❌"
        return 1
      fi
      local orig_mode
      orig_mode=$(stat -c "%a" "$script")
      echo "Original permission: $orig_mode"
      chmod +x "$script"
      echo "Temporary +x granted, executing..."
      "$script"
      echo "Execution finished, reverting permission"
      chmod "$orig_mode" "$script"
    }

    if [ -f "$PIF/autopif2.sh" ]; then
      echo "Found autopif2.sh"
      run_temp_exec "$PIF/autopif2.sh"
    elif [ -f "$PIF/autopif.sh" ]; then
      echo "Found autopif.sh"
      run_temp_exec "$PIF/autopif.sh"
    else
      echo "No autopif2.sh or autopif.sh found ❌"
    fi
  else
    echo "PIF on boot toggle is disabled"
  fi

  echo "========================================"
  echo " "
} >> "$LOG3" 2>&1