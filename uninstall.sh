TRICKY_STORE="/data/adb/tricky_store"
KEYBOX="$TRICKY_STORE/keybox.xml"
KEYBOX_BACKUP="$TRICKY_STORE/keybox.xml.bak"
TARGET="$TRICKY_STORE/target.txt"
TARGET_BACKUP="$TRICKY_STORE/target.txt.bak"

if [ -e /data/adb/Box-Brain ]; then
    rm -rf /data/adb/Box-Brain
fi

if [ -e "$KEYBOX" ]; then
    rm -rf "$KEYBOX"
fi

if [ -e "$TARGET" ]; then
    rm -rf "$TARGET"
fi

if [ -e /data/adb/shamiko/whitelist ]; then
    rm -rf /data/adb/shamiko/whitelist
fi

if [ -e /data/adb/nohello/whitelist ]; then
    rm -rf /data/adb/nohello/whitelist
fi

if [ -e /data/adb/modules/playintegrity ]; then
    rm -rf /data/adb/modules/playintegrity
fi

if [ -e "$TARGET_BACKUP" ]; then
    mv "$TARGET_BACKUP" "$TARGET"
fi

if [ -e "$KEYBOX_BACKUP" ]; then
    mv "$KEYBOX_BACKUP" "$KEYBOX"
fi