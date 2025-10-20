#!/system/bin/sh
LOGFILE="/sdcard/uninstall.log"
TRICKY_STORE="/data/adb/tricky_store"
KEYBOX="$TRICKY_STORE/keybox.xml"
KEYBOX_BACKUP="$TRICKY_STORE/keybox.xml.bak"
TARGET="$TRICKY_STORE/target.txt"
TARGET_BACKUP="$TRICKY_STORE/target.txt.bak"

log() {
  echo "$*" >> "$LOGFILE"
}

log "•••••• Integrity-Box Uninstall Started ••••••"

# Remove files
if [ -e "$KEYBOX" ]; then
  rm -rf "$KEYBOX"
  log "Deleted $KEYBOX"
else
  log "Skipped $KEYBOX (not found)"
fi

if [ -e "$TARGET" ]; then
  rm -rf "$TARGET"
  log "Deleted $TARGET"
else
  log "Skipped $TARGET (not found)"
fi

if [ -e /data/adb/shamiko/whitelist ]; then
  rm -rf /data/adb/shamiko/whitelist
  log "Deleted /data/adb/shamiko/whitelist"
fi

if [ -e /data/adb/nohello/whitelist ]; then
  rm -rf /data/adb/nohello/whitelist
  log "Deleted /data/adb/nohello/whitelist"
fi

if [ -e /data/adb/modules/playintegrity ]; then
  rm -rf /data/adb/modules/playintegrity
  log "Deleted /data/adb/modules/playintegrity"
fi

if [ -e /data/adb/Box-Brain ]; then
  rm -rf /data/adb/Box-Brain
  log "Deleted /data/adb/Box-Brain"
fi

if [ -e /data/adb/service.d/hash.sh ]; then
  rm -rf /data/adb/service.d/hash.sh
  log "Deleted /data/adb/service.d/hash.sh"
fi

# Restore backups
if [ -e "$TARGET_BACKUP" ]; then
  mv "$TARGET_BACKUP" "$TARGET"
  log "Restored $TARGET from backup"
else
  log "No $TARGET_BACKUP found"
fi

if [ -e "$KEYBOX_BACKUP" ]; then
  mv "$KEYBOX_BACKUP" "$KEYBOX"
  log "Restored $KEYBOX from backup"
else
  log "No $KEYBOX_BACKUP found"
fi

# Revert props only if modified
revert_prop_if_modified() {
  PROP="$1"
  MODIFIED="$2"
  DEFAULT="$3"
  CURRENT="$(resetprop "$PROP" 2>/dev/null)"
  if [ "$CURRENT" = "$MODIFIED" ]; then
    resetprop -n "$PROP" "$DEFAULT" 2>/dev/null
    if [ $? -eq 0 ]; then
      log "Reverted $PROP to $DEFAULT (was $MODIFIED)"
    else
      log "Failed to revert $PROP (was $MODIFIED)"
    fi
  else
    log "Skipped $PROP (current=$CURRENT)"
  fi
}

revert_prop_if_modified "persist.sys.pihooks.disable.gms_key_attestation_block" "true" "false"
revert_prop_if_modified "persist.sys.pihooks.disable.gms_props" "true" "false"
revert_prop_if_modified "persist.sys.pihooks.disable" "1" "0"
revert_prop_if_modified "persist.sys.kihooks.disable" "1" "0"

log "•••••• Integrity-Box Uninstall Completed ••••••"
sync