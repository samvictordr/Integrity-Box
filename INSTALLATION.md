# Installation Guide for Integrity Box

## Prerequisites

Before installing Integrity Box, ensure you have the following:

### Required:
1. **Rooted Android Device** with one of the following:
   - [Magisk](https://github.com/topjohnwu/Magisk) (recommended version 24.0+)
   - [KernelSU](https://github.com/tiann/KernelSU)
   - [APatch](https://github.com/bmax121/APatch)

2. **TEE (Trusted Execution Environment) Module** - Install **ONE** of the following:
   - [Tricky Store](https://github.com/5ec1cff/TrickyStore/releases) (recommended)
   - [Tricky Store OOS](https://github.com/beakthoven/TrickyStoreOSS/releases)
   - [Tricky Store FOSS](https://github.com/qwq233/TrickyStore/releases)
   - [TEE Simulator](https://github.com/JingMatrix/TEESimulator/releases)

3. **Internet Connection** - Required during installation and first boot

### Optional (Recommended):
- [Play Integrity Fork (PIF)](https://github.com/osm0sis/PlayIntegrityFork/releases) - For better compatibility
  
  > **Note:** Integrity Box has built-in PIF support for users who cannot use or don't want to use Zygisk. However, using the PIF module is still recommended for best results.

## Installation Steps

### Step 1: Download Integrity Box

1. Go to the [Releases page](https://github.com/MeowDump/Integrity-Box/releases)
2. Download the latest `.zip` file (e.g., `Integrity-Box-vXX.zip`)

### Step 2: Install Prerequisites

Install your chosen TEE module first:

1. Open Magisk Manager/KernelSU app
2. Go to **Modules** section
3. Tap the **Install from storage** button
4. Select your TEE module `.zip` file (Tricky Store recommended)
5. Wait for installation to complete
6. Reboot your device

If using Play Integrity Fork (optional but recommended):
1. Follow the same steps to install PIF module
2. Reboot after installation

### Step 3: Install Integrity Box

1. Open Magisk Manager/KernelSU app
2. Go to **Modules** section
3. Tap the **Install from storage** button
4. Select the `Integrity-Box-vXX.zip` file
5. Wait for the installation process to complete
   - The installer will check network connectivity
   - It will verify module integrity
   - It will set up the environment automatically
6. **Reboot your device** when prompted

### Step 4: First Boot Configuration

After rebooting, the module will automatically:
- Download the latest keybox
- Update fingerprint database
- Configure Tricky Store target packages
- Set up security patches
- Optimize GMS spoofing settings

This process may take 1-2 minutes on first boot.

## Verification

To verify the installation was successful:

1. Wait 2-3 minutes after boot for all services to start
2. Check if the module is active in your root manager app
3. Access the WebUI (see [USAGE.md](USAGE.md) for details)
4. Run a Play Integrity test

## Troubleshooting Installation

### Module not showing as active
- Ensure you rebooted after installation
- Check Magisk/KernelSU logs for errors
- Verify all prerequisites are installed

### Installation fails
- Check that you have internet connectivity
- Ensure SELinux is set to enforcing
- Make sure no conflicting modules are installed
- Check installation logs at `/data/adb/Box-Brain/Integrity-Box-Logs/Installation.log`

### Play Integrity still failing
- Wait a few minutes after reboot for all services to initialize
- Clear Google Play Store cache and data
- Update Google Play Services and Play Store to latest versions
- Check the troubleshooting section in [USAGE.md](USAGE.md)

## Important Notes

- **SELinux**: Keep SELinux in `enforcing` mode for best results. The module handles temporary permissive mode when needed.
- **Conflicting Modules**: Remove any modules that modify Play Store, Play Services, or expose root environment
- **Updates**: Keep Google Play Store and Google Play Services up to date
- **Xposed Modules**: Avoid Xposed modules that hook into Play Store or Play Services

## Uninstallation

To uninstall Integrity Box:

1. Open Magisk Manager/KernelSU app
2. Go to **Modules** section
3. Find **Integrity Box**
4. Tap **Remove** or **Uninstall**
5. Reboot your device

The uninstaller will clean up:
- Module files
- Configuration files in `/data/adb/Box-Brain`
- Log files

## Next Steps

Once installed, proceed to [USAGE.md](USAGE.md) to learn how to:
- Access the WebUI
- Configure module settings
- Test Play Integrity
- Customize fingerprints
- Manage target packages

## Support

If you encounter issues:
- Join the [Telegram Support Group](https://t.me/MeowDump)
- Use the "Report a bug/issue" button in the WebUI
- Check the [Support page](support.md) for donation options

## System Requirements

- **Android Version**: Android 8.0+ (recommended Android 10+)
- **Root**: Magisk 24.0+ / KernelSU / APatch
- **Architecture**: ARM64, ARM, x86_64 (most modern devices)
- **Storage**: ~10 MB free space
- **RAM**: Minimal impact (<50 MB)
