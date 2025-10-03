#!/system/bin/sh

L="/data/adb/Box-Brain/Integrity-Box-Logs/risky_apps.log"
TIME=$(date "+%Y-%m-%d %H:%M:%S")
Q="------------------------------------------"
R="════════════════════════════════"

log() {
    echo -e "$1" | tee -a "$L"
}

# Start logging
echo -e "$Q" >> "$L"
echo -e " - INTEGRITY-BOX RISKY APPS DETECTION | $TIME " >> "$L"
echo -e "$Q\n" >> "$L"

log "- Risky Apps Detection"

RISKY_APPS="com.rifsxd.ksunext:KernelSU_Next
me.weishu.kernelsu:KernelSU
com.google.android.hmal:Hide_My_Applist
com.reveny.vbmetafix.service:VBmeta_Fixer
me.twrp.twrpapp:TWRP
com.termux:Termux
bin.mt.plus:MT_Manager
org.swiftapps.swiftbackup:Swift_Backup
ru.mike.updatelocker:Update_Locker
com.coderstory.toolkit:Core_Patch
ru.maximoff.apktool:APK_ToolM
io.github.muntashirakon.AppManager.debug:App_Manager
io.github.a13e300.ksuwebui:KSU_WebUI
com.slash.batterychargelimit:Battery_Charging_Limit
io.github.vvb2060.keyattestation:Key_Attestation
io.github.qwq233.keyattestation:Key_Attestation
io.github.muntashirakon.AppManager:App_Manager
io.github.vvb2060.mahoshojo:Momo
com.reveny.nativecheck:Native_Detector
icu.nullptr.nativetest:NativeTest
io.github.huskydg.memorydetector:Memory_Detector
org.akanework.checker:Checker
icu.nullptr.applistdetector:Applist_Detector
io.github.rabehx.securify:Securify
krypton.tbsafetychecker:TB_Checker
me.garfieldhan.holmes:Holmes
com.byxiaorun.detector:Ruru
com.kimchangyoun.rootbeerFresh.sample:Root_Beer"

FOUND_APPS=""
SPOOFED_APPS=""

for entry in $RISKY_APPS; do
    PKG=$(echo "$entry" | cut -d':' -f1)
    NAME=$(echo "$entry" | cut -d':' -f2)
    
    if pm list packages | grep -q "$PKG"; then
        FOUND_APPS="$FOUND_APPS\n$NAME ($PKG)"
    fi
done

for PKG in $(pm list packages -3 | cut -d':' -f2); do
    VERSION=$(dumpsys package "$PKG" | grep versionName | head -n 1 | awk '{print $1}' | cut -d'=' -f2)
    if echo "$VERSION" | grep -qi "spoofed"; then
        SPOOFED_APPS="$SPOOFED_APPS\n$PKG (KSU NEXT detected)"
    fi
done

if [ -n "$FOUND_APPS" ]; then
    log "   └─ ⚠️ Found risky packages:\n$FOUND_APPS"
    log " "
    log "🪵 TIP: Use H.M.A to hide them"
fi

if [ -n "$SPOOFED_APPS" ]; then
    log "   └─ ⚠️ Found spoofed apps by version:\n$SPOOFED_APPS"
fi

if [ -z "$FOUND_APPS" ] && [ -z "$SPOOFED_APPS" ]; then
    log "   └─ ✅ No risky apps found"
fi

log "$Q"
log "- Detection Complete!\n"
log " "
echo -e "$R" >> "$L"
log "Log saved to $L"