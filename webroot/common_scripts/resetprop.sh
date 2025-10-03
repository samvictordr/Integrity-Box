#!/system/bin/sh
PACKAGE_NAME="com.reveny.nativecheck"

su -c 'getprop | grep -E "pphooks|gphooks|pihook|pixelprops|gms|pi" | sed -E "s/^\[(.*)\]:.*/\1/" | while IFS= read -r prop; do resetprop -p -d "$prop"; done'

# force stop native detector
if pm list packages | grep -q "$PACKAGE_NAME"; then
    am force-stop $PACKAGE_NAME
    echo "App $PACKAGE_NAME stopped."
else
    echo "App $PACKAGE_NAME not found."
fi

echo "Done, Reopen detector to check"