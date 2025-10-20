#!/system/bin/sh

# Paths
MODULE="/data/adb/modules"
MODDIR="$MODULE/playintegrity"
SCRIPT_DIR="$MODDIR/webroot/common_scripts"
TARGET="$SCRIPT_DIR/user.sh"
KILL="$SCRIPT_DIR/kill.sh"
UPDATE="$SCRIPT_DIR/key.sh"
PATCH="$SCRIPT_DIR/patch.sh"
PIF="$MODULE/playintegrityfix"
PROP="/data/adb/modules/playintegrity/module.prop"
URL="https://raw.githubusercontent.com/MeowDump/Integrity-Box/refs/heads/main/DUMP/notice.md"
BAK="$PROP.bak"
FLAG="/data/adb/Box-Brain/advanced"
FINGERPRINT="$PIF/custom.pif.json"
CPP="/data/adb/Box-Brain/Integrity-Box-Logs/spoofing.log"
P="/data/adb/modules/playintegrityfix/custom.pif.prop"

# Force override lineage props if flag exists
if [ -f "/data/adb/Box-Brain/override" ]; then
  sh "$SCRIPT_DIR/override_lineage.sh"
  exit 0
fi

# Detect if Google Wallet is installed
if command -v pm >/dev/null 2>&1 && pm list packages | grep -q com.google.android.apps.walletnfcrel; then
  WALLET_INSTALLED=true
else
  WALLET_INSTALLED=false
fi

# Connectivity check
megatron() {
  hosts="8.8.8.8 1.1.1.1 8.8.4.4"
  max_attempts=10
  attempt=1
  delay=1

  while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt of $max_attempts..."

    for h in $hosts; do
      if ping -c 1 -W 5 $h >/dev/null 2>&1; then
        return 0
      fi
    done

    if command -v curl >/dev/null 2>&1; then
      if curl -s --max-time 5 http://clients3.google.com/generate_204 >/dev/null 2>&1; then
        return 0
      fi
    fi

    echo "No/Poor internet connection"
    echo "Retrying in ${delay}s..."
    echo " "
    sleep $delay
    attempt=$((attempt + 1))
    delay=$((delay * 2))
    [ $delay -gt 30 ] && delay=30
  done

  echo "No internet connection detected after $max_attempts attempts."
  return 1
}

# Print header
print_header() {
  echo
  echo "══════════════════════════════════════════"
  echo "          Integrity Box Action Log"
  echo "══════════════════════════════════════════"
  echo
  printf " %-9s | %s\n" "STATUS" "TASK"
  echo "--------------------------------------------"
}

# Track results
log_step() {
  local status="$1"
  local task="$2"
  printf " %-9s | %s\n" "$status" "$task"
}

# Exit delay
handle_delay() {
  if [ "$KSU" = "true" ] || [ "$APATCH" = "true" ] && [ "$KSU_NEXT" != "true" ] && [ "$MMRL" != "true" ]; then
    echo
    echo "Closing in 7 seconds..."
    sleep 7
  fi
}

# Ensure log directory/file exists (best-effort)
mkdir -p "$(dirname "$CPP")" 2>/dev/null || true
touch "$CPP" 2>/dev/null || true

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$CPP"; }

# Set or replace key=value in file (logs to CPP)
setval() { grep -q "^$2=" "$1" && sed -i "s/^$2=.*/$2=$3/" "$1" && log "$2 → $3" || log "$2 not found"; }

# Exit if offline
if ! megatron; then exit 1; fi

# Show header
print_header

# Description content update
{
  for p in /data/adb/modules/busybox-ndk/system/*/busybox \
           /data/adb/ksu/bin/busybox \
           /data/adb/ap/bin/busybox \
           /data/adb/magisk/busybox \
           /system/bin/busybox \
           /system/xbin/busybox; do
    [ -x "$p" ] && bb=$p && break
  done
  [ -z "$bb" ] && return 0

  C=$($bb wget -qO- "$URL" 2>/dev/null)
  if [ -n "$C" ]; then
    [ ! -f "$BAK" ] && $bb cp "$PROP" "$BAK"
    $bb sed -i '/^description=/d' "$PROP"
    echo "description=$C" >> "$PROP"
  else
    [ -f "$BAK" ] && $bb cp "$BAK" "$PROP"
  fi
} || true

# Run steps
if [ -f "$TARGET" ]; then
  sh "$TARGET" >/dev/null 2>&1 && log_step "UPDATED" "Target List" || log_step "FAILED" "Updating Target List"
else
  log_step "MISSING" "Target script"
fi

# Updating Fingerprint based on Advanced Flag
if [ -f "$FLAG" ]; then
  if [ -f "$PIF/autopif2.sh" ]; then
    sh "$PIF/autopif2.sh" -s -m -p >/dev/null 2>&1 || exit 1
    log_step "UPDATED" "Advanced Fingerprint"
  else
    log_step "MISSING" "autopif2.sh for advanced mode"
  fi
else
  if [ -f "$PIF/autopif2.sh" ]; then 
    FP_SCRIPT="$PIF/autopif2.sh"
  elif [ -f "$PIF/autopif.sh" ]; then 
    FP_SCRIPT="$PIF/autopif.sh"
  else 
    FP_SCRIPT=""
  fi

  if [ -n "$FP_SCRIPT" ]; then
    sh "$FP_SCRIPT" >/dev/null 2>&1 \
      && log_step "UPDATED" "Fingerprint" \
      || log_step "FAILED" "Updating Fingerprint"
  else
    log_step "MISSING" "PIF Module"
  fi
fi

# Only update spoofing props if Google Wallet NOT installed and advanced flag is present
if [ "$WALLET_INSTALLED" != "true" ] && [ -f "$FLAG" ]; then
  if [ -f "$P" ]; then
    cp -f "$P" "$P.bak" && log "Backup: $P.bak"
    for k in spoofProvider spoofProps spoofBuild spoofVendingFinger; do
      setval "$P" "$k" "1"
    done
    s=$(grep -m1 "^spoofProvider=" "$P" 2>/dev/null | cut -d= -f2 || echo "")
    log "Spoofing: $( [ "$s" = "1" ] || [ "$s" = "true" ] && echo "✅ Enabled" || echo "⚠️ Disabled" )"
    log_step "UPDATED" "Spoofing Props"
  else
    log_step "MISSING" "PIF Fork Module"
  fi
else
  # If wallet installed we skip only the updater; if advanced flag missing we skip updater too.
  if [ "$WALLET_INSTALLED" = "true" ]; then
    log_step "SKIPPED" "Spoofing Props update (Google Wallet)"
  else
    log_step "SKIPPED" "Spoofing Props (Disabled)"
  fi
fi

# Remove advanced settings from PROP only if advanced flag is missing (run always regardless of Google Wallet)
if [ -f "$P" ] && [ ! -f "$FLAG" ]; then
  if grep -qE '^(spoofBuild|spoofProps|spoofProvider|spoofSignature|spoofVendingSdk|spoofVendingFinger|verboseLogs)=' "$P"; then
    sed -i -E '/^(spoofBuild|spoofProps|spoofProvider|spoofSignature|spoofVendingSdk|spoofVendingFinger|verboseLogs)=/d' "$P"
    log_step "CLEANED" "Advanced settings from Fingerprint"
  else
    log_step "SKIPPED" "Default Fingerprint Detected"
  fi
fi

if [ -f "$UPDATE" ]; then
  sh "$UPDATE" >/dev/null 2>&1 && log_step "UPDATED" "Keybox" || log_step "FAILED" "Updating Keybox"
else
  log_step "MISSING" "Keybox script"
fi

if [ -f "$PATCH" ]; then
  sh "$PATCH" >/dev/null 2>&1 && log_step "UPDATED" "Boot Patch" || log_step "FAILED" "Updating Boot Patch"
else
  log_step "MISSING" "Boot Patch script"
fi

if [ -f "$KILL" ]; then
  sh "$KILL" >/dev/null 2>&1 && log_step "KILLED" "GMS Process" || log_step "FAILED" "Restarting GMS Services"
else
  log_step "MISSING" "Kill script"
fi

echo "--------------------------------------------"
echo " "
echo " Action completed successfully."
handle_delay
exit 0
