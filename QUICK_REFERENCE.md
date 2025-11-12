# Quick Reference Guide

## 📱 Installation (TL;DR)

1. Install a TEE module (Tricky Store recommended)
2. Install Play Integrity Fork (optional but recommended)  
3. Install Integrity Box module
4. Reboot
5. Wait 2-3 minutes
6. Access WebUI at `http://localhost:1024`

**Full details:** [INSTALLATION.md](INSTALLATION.md)

## 🌐 Access WebUI

```bash
# Method 1: Terminal
su -c am start -a android.intent.action.VIEW -d http://127.0.0.1:1024

# Method 2: Browser
http://127.0.0.1:1024
# or
http://localhost:1024
```

## ⚡ Quick Commands

### Refresh Configuration
```bash
su -c "sh /data/adb/modules/playintegrity/action.sh"
```

### Update Keybox
```bash
su -c "sh /data/adb/modules/playintegrity/webroot/common_scripts/key.sh"
```

### Clear Google Play Cache
```bash
su -c "pm clear com.google.android.gms"
su -c "pm clear com.android.vending"
```

### Kill GMS Processes
```bash
su -c "killall -9 com.google.android.gms.unstable"
su -c "killall -9 com.google.android.gms"
su -c "killall -9 com.android.vending"
```

### Check Fingerprint
```bash
su -c "getprop ro.build.fingerprint"
```

### Check Security Patch
```bash
su -c "getprop ro.build.version.security_patch"
```

### Check SELinux Status
```bash
su -c "getenforce"
```

## 📁 Important Files

| Path | Description |
|------|-------------|
| `/data/adb/modules/playintegrity/` | Module installation directory |
| `/data/adb/Box-Brain/` | Configuration files |
| `/data/adb/Box-Brain/Integrity-Box-Logs/` | Log files |
| `/data/adb/tricky_store/keybox.xml` | Device keybox |
| `/data/adb/tricky_store/target.txt` | Target packages |
| `/data/adb/Box-Brain/blacklist.txt` | Package blacklist |

## 🚩 Configuration Flags

Create/delete these files to enable/disable features:

```bash
# Enable advanced mode
su -c "touch /data/adb/Box-Brain/advanced"

# Disable GMS optimization
su -c "touch /data/adb/Box-Brain/gms"

# Use stock security patch
su -c "touch /data/adb/Box-Brain/patch"

# Disable Telegram redirect on install
su -c "touch /data/adb/Box-Brain/noredirect"

# Force override LineageOS props
su -c "touch /data/adb/Box-Brain/override"
```

## 📝 View Logs

```bash
# Installation log
cat /data/adb/Box-Brain/Integrity-Box-Logs/Installation.log

# Spoofing log
cat /data/adb/Box-Brain/Integrity-Box-Logs/spoofing.log

# Patch log
cat /data/adb/Box-Brain/Integrity-Box-Logs/patch.log
```

## 🔧 Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| Play Integrity failing | Wait 2-3 mins, clear Play cache, reboot |
| WebUI not accessible | Reboot, wait 2-3 mins, check module is active |
| Device not certified | Use WebUI > Certified, wait 24 hours |
| Strong integrity failing | Update keybox, enable advanced mode |
| Banking app detecting root | Check Risky Apps, add to target.txt |

## 🧪 Test Play Integrity

### Via WebUI
- Open `http://localhost:1024`
- Click "Run Integrity Test"

### Via Apps
Download one of these:
- Play Integrity API Checker
- YASNAC
- SafetyNet Test

## 🎯 Expected Results

✅ **BASIC** - Should always pass  
✅ **DEVICE** - Should pass with proper config  
✅ **STRONG** - Requires valid keybox + fingerprint  

## 🔄 Update Workflow

1. Download latest Integrity Box release
2. Install via Magisk/KernelSU (no need to uninstall old version)
3. Reboot
4. Check WebUI for changes

## 🆘 Getting Help

1. **WebUI**: Use "Report Bug" button
2. **Telegram**: [Join @MeowDump](https://t.me/MeowDump)  
3. **Documentation**: [USAGE.md](USAGE.md)
4. **GitHub**: [Create an issue](https://github.com/MeowDump/Integrity-Box/issues)

## 💡 Best Practices

- ✅ Keep SELinux in enforcing mode
- ✅ Keep Google Play Services updated
- ✅ Use minimal root exposure (DenyList/Shamiko)
- ✅ Avoid conflicting modules
- ✅ Don't modify Play Store/Play Services with Xposed
- ✅ Reboot after making changes

## ⚠️ Important Notes

- First boot takes 1-2 minutes to initialize
- Google Play cache should be cleared after changes
- "Device not certified" fix takes up to 24 hours
- Strong integrity needs valid keybox from TEE module
- Some apps may still detect modifications (not a bug)

---

**For detailed information, see:**
- 📖 [Full Installation Guide](INSTALLATION.md)
- 🎯 [Complete Usage Guide](USAGE.md)
