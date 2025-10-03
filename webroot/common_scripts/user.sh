#!/bin/sh
TARGET='/data/adb/tricky_store/target.txt'
BACKUP='/data/adb/tricky_store/target.txt.bak'
TEE_STATUS='/data/adb/tricky_store/tee_status'
TRICKY_DIR='/data/adb/tricky_store'
TMP="${TARGET}.new.$$"

success=0
made_backup=0

cleanup() {
    status=$?
    if [ $success -ne 1 ]; then
        [ -f "$TMP" ] && rm -f "$TMP"
        if [ $made_backup -eq 1 ] && [ -f "$BACKUP" ]; then
            echo "Restoring backup..."
            mv -f "$BACKUP" "$TARGET"
        fi
    fi
    exit $status
}
trap cleanup EXIT INT TERM HUP

# Ensure TrickyStore directory exists
if [ ! -d "$TRICKY_DIR" ]; then
    echo "- Please install Trickystore Module"
    am start -a android.intent.action.VIEW -d https://github.com/5ec1cff/TrickyStore/releases >/dev/null 2>&1 &
    echo "Redirecting to Github"
    exit 1
fi

# Backup current target
if [ -f "$TARGET" ]; then
    mv -f "$TARGET" "$BACKUP" || exit 1
    made_backup=1
#    echo "Backed up to: $BACKUP"
fi

# Read teeBroken value safely
teeBroken="false"
if [ -f "$TEE_STATUS" ]; then
    v=$(grep -E '^teeBroken=' "$TEE_STATUS" 2>/dev/null | cut -d '=' -f2)
    [ "$v" = "true" ] && teeBroken="true"
fi

# Helper to add a pkg for devices with broken TEE
add_pkg() {
    pkg="$1"
    if [ "$teeBroken" = "true" ]; then
        echo "${pkg}!" >> "$TMP"
    else
        echo "$pkg" >> "$TMP"
    fi
}

# Builder
echo "# Last updated on $(date '+%A %d/%m/%Y %I:%M:%S%p')" > "$TMP" || exit 1

add_pkg "com.android.vending"
add_pkg "com.google.android.gms"
add_pkg "com.reveny.nativecheck"
add_pkg "io.github.vvb2060.keyattestation"
add_pkg "io.github.qwq233.keyattestation"
add_pkg "io.github.vvb2060.mahoshojo"
add_pkg "icu.nullptr.nativetest"
add_pkg "com.google.android.contactkeys"
add_pkg "com.google.android.ims"
add_pkg "com.google.android.safetycore"
add_pkg "com.google.android.apps.walletnfcrel"

# Append installed packages; avoid dupes
pm list packages -3 2>/dev/null | cut -d ":" -f 2 | while read -r pkg; do
    [ -z "$pkg" ] && continue
    if ! grep -F -x -q "$pkg" "$TMP" && ! grep -F -x -q "$pkg!" "$TMP"; then
        add_pkg "$pkg"
    fi
done

# Swap in atomically
mv -f "$TMP" "$TARGET" || exit 1
success=1  

echo "Updating target list"
echo
echo "----------------------------------------------"
echo "  All Packages with TEE status applied"
echo "----------------------------------------------"
cat "$TARGET"

exit 0