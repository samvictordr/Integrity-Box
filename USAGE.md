# Usage Guide for Integrity Box

This guide explains how to use Integrity Box after installation.

## Table of Contents
- [Accessing the WebUI](#accessing-the-webui)
- [WebUI Features](#webui-features)
- [Module Settings](#module-settings)
- [Testing Play Integrity](#testing-play-integrity)
- [Advanced Configuration](#advanced-configuration)
- [Logs and Debugging](#logs-and-debugging)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)

## Accessing the WebUI

Integrity Box includes a powerful web-based interface for managing all settings.

### Method 1: Using a Terminal App
1. Open a terminal app (Termux recommended)
2. Run: `su -c am start -a android.intent.action.VIEW -d http://127.0.0.1:1024`
3. The WebUI will open in your default browser

### Method 2: Direct Browser Access
1. Open any web browser on your device
2. Navigate to: `http://127.0.0.1:1024` or `http://localhost:1024`

### Method 3: Using Root File Manager
Some root file managers (like MiXplorer) can trigger the WebUI:
1. Navigate to `/data/adb/modules/playintegrity/webroot`
2. Open `index.html` with a browser

> **Note:** The WebUI server starts automatically on boot. If it's not accessible, reboot your device and wait 2-3 minutes.

## WebUI Features

The WebUI provides access to all module features:

### Main Dashboard
- **Play Integrity Status**: View current integrity verdicts
- **Device Information**: Check spoofed properties
- **Quick Actions**: Refresh services, clear cache, run tests

### Settings Pages

#### 1. **Flags** (`/webroot/Flags/`)
Configure module behavior:
- PIF Advanced mode
- Playstore Pixelify
- Spoof Lineage Props
- Override Lineage Props
- Debug Fingerprint cleaning
- Build Tag spoofing
- Storage Encryption spoofing
- SELinux status spoofing
- TWRP detection
- Auto-update settings

#### 2. **Custom PIF** (`/webroot/CustomPIF/`)
- Set custom device fingerprints
- Import/export PIF configurations
- Test different fingerprint profiles

#### 3. **Tricky Store** (`/webroot/TrickyStore/`)
- Manage target package list
- Configure blacklist
- Update TEE status
- Refresh keybox

#### 4. **Play Integrity Fork** (`/webroot/PlayIntegrityFork/`)
- Configure PIF module settings
- Enable/disable advanced spoofing
- Set custom props

#### 5. **Device Certification** (`/webroot/Certified/`)
- Fix "Device not certified" error
- Manage certification status

#### 6. **Boot Hash** (`/webroot/BootHash/`)
- Fix abnormal boot hash issues
- Configure verified boot settings

#### 7. **Risky Apps** (`/webroot/Risky/`)
- View detected flagged apps
- Check spoofed applications
- Manage app detection

#### 8. **Support** (`/webroot/Support/`)
- Report bugs/issues
- Access documentation
- View changelog

## Module Settings

### PIF Advanced Mode
**Location:** WebUI > Flags > PIF Advanced

- **ON**: Fetches fingerprint with advanced settings, automatically spoofs values for strong integrity
- **OFF**: Uses basic fingerprint without advanced spoofing

When to use:
- Use ON if you need to pass Strong integrity for banking apps
- Use OFF if you only need Basic/Device integrity

### Playstore Pixelify
Disables Play Store spoofing as a Pixel device. Useful on Android 16 ROMs where Play Store is spoofed even when GMS spoofing is disabled.

### Lineage Props Spoofing
Hides LineageOS-specific properties to avoid custom ROM detection.

- **Spoof Lineage Props**: Software-level hiding
- **Override Lineage Props**: Force hide using resetprop (more aggressive)

### Debug Fingerprint
Cleans debug tags from device fingerprint to pass Play Integrity with stock fingerprint.

### Storage Encryption
Spoofs device storage as encrypted to fool banking apps.

### SELinux Status
Spoofs SELinux status as "enforcing" for devices running permissive SELinux.

### Auto-Update Settings

- **Pif.json on boot**: Download latest Pixel fingerprint on device restart
- **Target.txt on boot**: Update Tricky Store's package list on device restart

## Testing Play Integrity

### Using the WebUI
1. Open the WebUI dashboard
2. Click "Run Integrity Test"
3. View results for:
   - BASIC verdict
   - DEVICE verdict  
   - STRONG verdict

### Using Third-Party Apps
Install one of these apps to test:
- [Play Integrity API Checker](https://play.google.com/store/apps/details?id=gr.nikolasspyr.integritycheck)
- [YASNAC](https://play.google.com/store/apps/details?id=rikka.safetynetchecker)
- [Play Integrity Fork test page](https://play.google.com/store/apps/details?id=eu.chainfire.safetynettest)

### Expected Results
- ✅ **BASIC**: Should always pass
- ✅ **DEVICE**: Should pass with proper configuration
- ✅ **STRONG**: Requires valid keybox and proper fingerprint

## Advanced Configuration

### File Locations

Important directories:
```
/data/adb/modules/playintegrity/          # Module installation
/data/adb/Box-Brain/                       # Configuration files
/data/adb/Box-Brain/Integrity-Box-Logs/   # Log files
/data/adb/tricky_store/                    # Tricky Store data
```

Key configuration files:
```
/data/adb/Box-Brain/advanced               # Flag for advanced mode
/data/adb/Box-Brain/gms                    # GMS spoofing flag
/data/adb/Box-Brain/patch                  # Security patch flag
/data/adb/Box-Brain/blacklist.txt          # Package blacklist
/data/adb/Box-Brain/hash.txt               # Boot hash config
/data/adb/tricky_store/keybox.xml         # Device keybox
/data/adb/tricky_store/target.txt         # Target packages
```

### Manual Configuration via Terminal

Enable advanced mode:
```bash
su -c "touch /data/adb/Box-Brain/advanced"
```

Disable GMS spoofing optimization:
```bash
su -c "touch /data/adb/Box-Brain/gms"
```

Use stock security patch:
```bash
su -c "touch /data/adb/Box-Brain/patch"
```

Add package to blacklist:
```bash
su -c "echo 'com.example.app' >> /data/adb/Box-Brain/blacklist.txt"
```

### Refreshing Configuration

After making changes, refresh services:
```bash
su -c "sh /data/adb/modules/playintegrity/action.sh"
```

Or reboot the device for complete refresh.

## Logs and Debugging

### Log Files

View installation logs:
```bash
cat /data/adb/Box-Brain/Integrity-Box-Logs/Installation.log
```

View spoofing logs:
```bash
cat /data/adb/Box-Brain/Integrity-Box-Logs/spoofing.log
```

View security patch logs:
```bash
cat /data/adb/Box-Brain/Integrity-Box-Logs/patch.log
```

### Using the WebUI
Access logs through WebUI > Support > View Logs

### Enable Verbose Logging
Add to PIF configuration:
```bash
su -c "echo 'verboseLogs=true' >> /data/adb/modules/playintegrityfix/custom.pif.prop"
```

## Common Tasks

### Update Keybox Manually
```bash
su -c "sh /data/adb/modules/playintegrity/webroot/common_scripts/key.sh"
```

### Refresh Target Packages
```bash
su -c "sh /data/adb/modules/playintegrity/action.sh"
```

### Clear Google Play Services Cache
```bash
su -c "pm clear com.google.android.gms"
su -c "pm clear com.android.vending"
```

### Kill GMS Processes (Force Refresh)
```bash
su -c "killall -9 com.google.android.gms.unstable"
su -c "killall -9 com.google.android.gms"
su -c "killall -9 com.android.vending"
```

### Check Current Fingerprint
```bash
su -c "getprop ro.build.fingerprint"
```

### Check Security Patch Level
```bash
su -c "getprop ro.build.version.security_patch"
```

## Troubleshooting

### Play Integrity Failing

1. **Wait 2-3 minutes after boot**
   - Services need time to initialize

2. **Clear Google Play Services data**
   ```bash
   su -c "pm clear com.google.android.gms"
   su -c "pm clear com.android.vending"
   ```

3. **Check module is active**
   - Verify in Magisk/KernelSU modules list
   - Check logs for errors

4. **Update Google Play Services**
   - Go to Settings > Apps > Google Play Services
   - Update to latest version

5. **Check for conflicting modules**
   - Disable other root hiding/integrity modules
   - Avoid Xposed modules that hook Play Services

6. **Verify SELinux is enforcing**
   ```bash
   su -c "getenforce"
   ```

7. **Check keybox validity**
   - Use WebUI to update keybox
   - Verify keybox.xml exists and is not empty

### WebUI Not Accessible

1. **Verify module is installed and active**
2. **Reboot and wait 2-3 minutes**
3. **Check if port 1024 is in use**
   ```bash
   su -c "netstat -tuln | grep 1024"
   ```
4. **Restart WebUI service manually**
   ```bash
   su -c "sh /data/adb/modules/playintegrity/service.sh"
   ```

### "Device not certified" Error

1. Open WebUI > Certified
2. Follow the fix instructions
3. Clear Play Store cache
4. Wait 24 hours (Google needs time to update status)

### Banking Apps Still Detecting Root

1. Enable all detection spoofing in WebUI > Flags
2. Check Risky Apps page for detected apps
3. Add problematic apps to Tricky Store target list
4. Ensure Shamiko/Deny list is configured properly

### Strong Integrity Failing

1. **Check keybox validity**
   - Update keybox from WebUI
   - Verify TEE module is working

2. **Try advanced mode**
   - Enable PIF Advanced in WebUI > Flags

3. **Update fingerprint**
   - Enable "Pif.json on boot"
   - Reboot to get latest fingerprint

4. **Check for flagged apps**
   - View in WebUI > Risky Apps
   - Remove or hide flagged apps

## Best Practices

1. **Keep modules updated**
   - Check for Integrity Box updates regularly
   - Update Tricky Store and PIF modules

2. **Maintain Google apps**
   - Keep Play Store and Play Services updated
   - Don't freeze or disable Google services

3. **Minimize root exposure**
   - Use Zygisk DenyList or Shamiko
   - Only grant root to trusted apps

4. **Clean installation**
   - Avoid too many system modifications
   - Keep ROM as close to stock as possible

5. **Regular maintenance**
   - Clear Play Services cache monthly
   - Refresh keybox when integrity fails

## Getting Help

If you're still having issues:

1. **Report via WebUI**
   - Use WebUI > Support > Report Bug
   - Include logs and device information

2. **Join Telegram Group**
   - [Telegram: @MeowDump](https://t.me/MeowDump)
   - Ask for help from the community

3. **Check Changelog**
   - Review recent changes and known issues
   - See if your issue is already addressed

4. **GitHub Issues**
   - Search existing issues
   - Create a new issue with detailed information

## Multi-Language Support

The WebUI supports multiple languages:
- English (Default)
- Spanish (es)
- German (de)
- French (fr)
- Italian (it)
- Portuguese (pt-br)
- Russian (ru)
- Chinese (zh-CH, zh-TW)
- Japanese (ja)
- Korean (ko)
- And many more!

Change language from WebUI settings or by modifying `config.json`.

---

**Remember:** Play Integrity checks can be unpredictable. Even with perfect configuration, some apps may still detect modifications. This is normal and not a bug with the module.
