# 🚀 Quick Start

**New to Integrity Box?** Get started quickly:

1. 📖 **[Installation Guide](INSTALLATION.md)** - Complete installation instructions
2. 🎯 **[Usage Guide](USAGE.md)** - Learn how to use the module and WebUI
3. 💬 **[Support](https://t.me/MeowDump)** - Join our Telegram group for help

## What is Integrity Box?

Integrity Box is a powerful Magisk/KernelSU module that helps Android devices pass Google Play Integrity checks. It provides free, legitimate keyboxes and advanced spoofing features without requiring payment or leaked credentials.

### Key Features
✅ Pass Play Integrity (Basic, Device & Strong)  
✅ Free valid keyboxes - no hidden charges  
✅ Powerful WebUI for easy configuration  
✅ Automatic updates and maintenance  
✅ Multi-language support  
✅ Compatible with banking and payment apps  

---

<details>
<summary><strong>Notes</strong></summary>

> Please make sure you have the following **modules installed** before using Integrity Box:

- [**Tricky Store**](https://github.com/5ec1cff/TrickyStore/releases) or [**Tricky Store OOS**](https://github.com/beakthoven/TrickyStoreOSS/releases) or [**Tricky Store FOSS**](https://github.com/qwq233/TrickyStore/releases) or [**TEE Simulator**](https://github.com/JingMatrix/TEESimulator/releases) (use any one)

- [**Play Integrity Fork**](https://github.com/osm0sis/PlayIntegrityFork/releases) (optional)

Integrity Box has inbuilt PIF for users who are not able to pass Play Integrity with PIF module or don’t want to use Zygisk. This lets you pass Play Integrity without PIF or Zygisk modules. However, It’s still recommended to use Play Integrity Fork (PIF)

`Que: Won't it conflict with PIF?`

`Ans: No, because it works only when PIF module is not installed`

`Note:` 
- Play Integrity checks can fail on outdated or heavily modified systems. To reduce false negatives, run a ROM with SELinux set to `enforcing`, keep Google Play Store and Google Play Services up to date, and avoid Xposed modules or other system-level hooks that modify Play Store or Play Services.

- Use Report a bug/issue button in WebUI to report bugs/issues
  
- Avoid conflicting or unnecessary modules that expose your root environment
> 
</details>

<details>
<summary><strong>Module Features</strong></summary>
  
> This module offers the following features:  

-  Spoofs security patch ( android + boot)
-  Spoofs LineageOS props detection
-  Spoofs debug fingerprint detection
-  Fixes abnormal boot hash
-  Hides PIF Hook detection
-  Spoofs build tag
-  Spoofs storage encryption
-  Spoofs SE Linux status
-  Spoofs custom recovery detection
-  Updates valid `keybox.xml`  
-  Updates `target.txt` as per your TEE status
-  Blacklists unnecessary packages from target.txt
-  Re-freshes fingerprint on every reboot for seamless exprience
-  Re-freshes TS target packages on every reboot
-  Switch Shamiko & Nohello modes
-  Disables EU injector by default  
-  Disables GMS ROM spoofing for various cROMs 
-  Spoofs ROM release key  
-  Can set custom Fingerprints
-  Spoofs Tricky Store's Security Patch
-  Fixes Device not certified error
-  Kills GMS Vending process
-  Detects flagged & spoofed apps
> `NOTE:` Every single feature is customisable, you can choose what to use and what to skip as per your requirements

</details>

<details>
<summary><strong>About Module Settings</strong></summary>

- `PIF Advanced :` Controls play integrity fork behaviour, `ON=` fetch fingerprint with advanced settings & automatically spoof values to pass strong integrity verdicts. `OFF=` fetch fingerprint without advanced settings & disable incorrect spoofing values to pass strong integrity verdicts.

- `Playstore Pixelify :` Disables Play Store spoofing as a Pixel device (the Play Store used to be spoofed even when inbuilt GMS spoofing was disabled on some A16 ROMs)
  
- `Spoof Lineage Props :` hides lineageos props detection
  
- `Override Lineage Props :` force hide lineageos props detection via reset prop
- `Debug Fingerprint :` cleans debug tag from fingerprint to bypass custom rom detection and pass play integrity with stock fingerprint
- `Debug Build :` spoofs developement build as user
- `Build Tag :` spoofs build tag to bypass custom rom detection
- `Storage Encryption :` spoofs device storage as encrypted to fool banking apps
- `Selinux Status :` spoofs selinux status enforcing to pass play integrity on ROMs with permissive selinux
- `TWRP detection :` spoofs custom recovery folder to bypass root detection
- `Pif.json on boot :` download latest pixel fingerprint on device restart
- `Target.txt on boot :` update tricky store's package list on device restart
</details>

<details>
<summary><strong>Why I Built This Module</strong></summary>
  
*I noticed a lot of people either selling leaked keyboxes or paying for modules that claim to pass strong Play Integrity but only offer leaked keyboxes. I created this module to give you **real**, **working keyboxes** completely **free**, no hidden charges, no scams, just **legit access** along with several useful features. 🚫🔑*

![Ibox](https://raw.githubusercontent.com/MeowDump/Integrity-Box/refs/heads/main/DUMP/ibox.png)
</details>

<details>
<summary><strong>Why No Commit Messages?</strong></summary>

**The entire purpose of this repository is transparency.
I upload my code here because some people believe that anything on GitHub is automatically open source. HAHA and honestly, I don’t have the time (or patience) to debate that. So, I joined this beautiful platform and decided to let the code speak for itself** 
I don’t write code directly on GitHub. I use Notepad++ locally and upload the files on Github when they’re ready, **for transparency.** I focus on getting things done, not polishing every line for spectators. **Every commits is visible**, and you can compare changes anytime. There’s even a [changelog](https://raw.githubusercontent.com/MeowDump/MeowDump/refs/heads/main/playintegrity/changelog.md), for those brave enough to read. If that’s still too much effort, feel free to rewrite the commit messages and send a pull request. Otherwise, $#@%&*

![Commit](https://raw.githubusercontent.com/MeowDump/Integrity-Box/refs/heads/main/DUMP/commit.gif)

</details>

<details>
<summary><strong>Acknowledgement & Credit</strong></summary>

- [ezme-nodebug](https://github.com/ez-me/ezme-nodebug) (dead)
- [PlayIntegrityFork](https://github.com/osm0sis/PlayIntegrityFork)
- Everyone who translated the WEBUI & supported me
- GOD, for everything
</details>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" alt="Catppuccin Footer" />
</p>

<div align="center">
  <a href="https://github.com/MeowDump/Integrity-Box/releases" target="_blank">
    <img src="DUMP/download.png" alt="Download Button" width="600" />
  </a>
</div>

## Support
<table align="center" cellspacing="20" style="border: none;">
  <tr align="center">
    <td style="border: none;">
      <a href="https://t.me/MeowDump" target="_blank" style="border: none;">
        <img src="https://upload.wikimedia.org/wikipedia/commons/8/82/Telegram_logo.svg" alt="Join our Telegram Group" width="150" style="border: none;"><br>
        <code>Join help group</code>
      </a>
    </td>
    <td style="border: none;">
      <a href="https://github.com/MeowDump/Integrity-Box/blob/main/support.md" target="_blank" style="border: none;">
        <img src="https://www.svgrepo.com/show/194198/donate-donation.svg" alt="Support Developer" width="150" style="border: none;"><br>
        <code>Donate to Developer</code>
      </a>
    </td>
  </tr>
</table>

## Preview
<p align="center">
  <a href="https://github.com/MeowDump/Integrity-Box/stargazers">
    <img 
      src="https://m3-markdown-badges.vercel.app/stars/7/1/MeowDump/Integrity-Box" 
      alt="GitHub Stars" 
    />
  </a>
  <br />
  <a href="https://github.com/MeowDump/Integrity-Box/releases">
    <img 
      src="https://img.shields.io/github/downloads/MeowDump/Integrity-Box/total?label=Downloads%20%28excluding%20telegram%20release%29&color=%23ff1493&style=flat" 
      alt="GitHub Releases" 
    />
  </a>
</p>

<table align="center">
  <tr>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/PreviewHome.gif" alt="1" style="max-width: 100%; height: auto;" /></td>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview2.png" alt="2" style="max-width: 100%; height: auto;" /></td>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview7.png" alt="3" style="max-width: 100%; height: auto;" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview5.png" alt="4" style="max-width: 100%; height: auto;" /></td>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview4.png" alt="5" style="max-width: 100%; height: auto;" /></td>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview8.png" alt="6" style="max-width: 100%; height: auto;" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview3.png" alt="7" style="max-width: 100%; height: auto;" /></td>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview6.png" alt="8" style="max-width: 100%; height: auto;" /></td>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview13.png" alt="9" style="max-width: 100%; height: auto;" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview9.png" alt="10" style="max-width: 100%; height: auto;" /></td>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/Preview14.png" alt="11" style="max-width: 100%; height: 2400;" /></td>
    <td><img src="https://github.com/MeowDump/Integrity-Box/blob/main/DUMP/8.png" alt="12" style="max-width: 100%; height: auto;" /></td>
  </tr>
</table>
