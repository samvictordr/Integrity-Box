#!/system/bin/sh

# Environment & paths
MODDIR=${0%/*}
TMPL="$TMPDIR/bkl.$$"
LOG_DIR="/data/adb/Box-Brain/Integrity-Box-Logs"
INSTALL_LOG="$LOG_DIR/Installation.log"
DOWNLOAD_LOG="$LOG_DIR/download.log"
CONFLICT_LOG="$LOG_DIR/conflicts.log"
TMPDIR=${TMPDIR:-/data/local/tmp}
DELHI="$TMPDIR/dilli.$$"
MUMBAI="$TMPDIR/bambai.$$"
MODSDIR="/data/adb/modules"
UPDATE="/data/adb/modules_update/playintegrity"
SCRIPT="$UPDATE/webroot/common_scripts"
TS_DIR="/data/adb/tricky_store"
PIF_DIR="/data/adb/modules/playintegrityfix"
PIF_PROP="$PIF_DIR/module.prop"
KEYBOX="$TS_DIR/keybox.xml"
BACKUP="$TS_DIR/keybox.xml.bak"

# create dirs
mkdir -p "$LOG_DIR" 2>/dev/null || true
mkdir -p "$TMPDIR" 2>/dev/null || true

DAENERYS="aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnR"
RHAENYRA="lbnQuY29tL01lb3dEdW1wL01lb3dEdW1wL3JlZ"
DEADPOOL="nMvaGVhZHMvbWFpbi9OdWxsVm9pZC9"
DAREDEVIL="BcnJpdmFsLnRhcg=="

echo "
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⡴⣆⠀⠀⠀⠀⠀⣠⡀⠀⠀⠀⠀⠀⠀⣼⣿⡗⠀⠀⠀⠀
⠀⠀⠀⣠⠟⠀⠘⠷⠶⠶⠶⠾⠉⢳⡄⠀⠀⠀⠀⠀⣧⣿⠀⠀⠀⠀⠀
⠀⠀⣰⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣤⣤⣤⣤⣤⣿⢿⣄⠀⠀⠀⠀
⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣧⠀⠀⠀⠀⠀⠀⠙⣷⡴⠶⣦
⠀⠀⢱⡀⠀⠉⠉⠀⠀⠀⠀⠛⠃⠀⢠⡟⠀⠀⠀⢀⣀⣠⣤⠿⠞⠛⠋
⣠⠾⠋⠙⣶⣤⣤⣤⣤⣤⣀⣠⣤⣾⣿⠴⠶⠚⠋⠉⠁⠀⠀⠀⠀⠀⠀
⠛⠒⠛⠉⠉⠀⠀⠀⣴⠟⢃⡴⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

"
# output helper
pikachu() {
  echo "$@"
}

# echo for multi-line blocks
tblock() {
  printf '%s\n' "$@"
}

# internal logger
barbie() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$INSTALL_LOG" 2>/dev/null
}

# remove helper
goku() {
  rm -f "$@" 2>/dev/null || true
}

# Busybox finder
shockwave() {
  for p in /data/adb/modules/busybox-ndk/system/*/busybox \
           /data/adb/ksu/bin/busybox \
           /data/adb/ap/bin/busybox \
           /data/adb/magisk/busybox \
           /system/bin/busybox \
           /system/xbin/busybox; do
    if [ -x "$p" ]; then
      printf '%s' "$p"
      return 0
    fi
  done
  return 1
}

# reads stdin, writes decoded stdout
bumblebee() {
  _buf=0
  _bits=0
  while IFS= read -r -n1 c; do
    case "$c" in
      [A-Z]) v=$(printf '%d' "'$c"); v=$((v - 65)) ;;
      [a-z]) v=$(printf '%d' "'$c"); v=$((v - 71)) ;;
      [0-9]) v=$(printf '%d' "'$c"); v=$((v + 4)) ;;
      '+') v=62 ;;
      '/') v=63 ;;
      '=') break ;;
      *) continue ;;
    esac
    _buf=$((_buf << 6 | v))
    _bits=$((_bits + 6))
    if [ $_bits -ge 8 ]; then
      _bits=$((_bits - 8))
      out=$(( (_buf >> _bits) & 0xFF ))
      printf \\$(printf '%03o' "$out")
    fi
  done
}

# Network check
megatron() {
  local hosts="8.8.8.8 1.1.1.1 8.8.4.4"
  local max_attempts=5
  local attempt=1

  while [ "$attempt" -le "$max_attempts" ]; do
    echo " ✦ Internet check Attempt $attempt of $max_attempts ..."
    
    # ping host
    for h in $hosts; do
      if ping -c 1 -W 5 "$h" >/dev/null 2>&1; then
        return 0
      fi
    done

    # Try HTTP 204 fallback
    if command -v curl >/dev/null 2>&1; then
      if curl -s --max-time 5 http://clients3.google.com/generate_204 >/dev/null 2>&1; then
        return 0
      fi
    fi

    attempt=$((attempt + 1))
    sleep 3
  done

  echo " ✦ Poor/No internet connection after $max_attempts attempts."
  return 1
}

# Downloader
dracarys() {
  local url="$1" out="$2"
  local bb
  bb=$(shockwave 2>/dev/null)
  pikachu " ✦ Downloading keybox"
  if [ -n "$bb" ]; then
    if "$bb" wget -q --no-check-certificate -O "$out" "$url"; then
      barbie " ✦ Downloaded via busybox wget"
      return 0
    fi
  fi

  if command -v wget >/dev/null 2>&1; then
    if wget -q --no-check-certificate -O "$out" "$url"; then
      barbie " ✦ Downloaded via wget"
      return 0
    fi
  fi

  if command -v curl >/dev/null 2>&1; then
    if curl -fsSL --insecure -o "$out" "$url"; then
      barbie " ✦ Downloaded via curl"
      return 0
    fi
  fi

  return 1
}

# Multi-round decoder
hello_kitty() {
  local inp="$1" out="$2"
  local tmp="$TMPDIR/dec.$$"
  cp -f "$inp" "$tmp" 2>/dev/null || return 1

  i=1
  while [ "$i" -le 10 ]; do
    local nxt="$TMPDIR/dec_next.$$"
    if base64 -d "$tmp" > "$nxt" 2>/dev/null; then
      mv -f "$nxt" "$tmp"
      i=$((i + 1))
    else
      rm -f "$nxt" 2>/dev/null
      break
    fi
  done

  # try hex
  if xxd -r -p "$tmp" > "${tmp}.hex" 2>/dev/null; then
    mv -f "${tmp}.hex" "$tmp"
  fi

  # try ROT13
  if tr 'A-Za-z' 'N-ZA-Mn-za-m' < "$tmp" > "${tmp}.rot" 2>/dev/null; then
    mv -f "${tmp}.rot" "$tmp"
  fi

  mv -f "$tmp" "$out" 2>/dev/null || return 1
  return 0
}

release_source() {
    [ -f "/data/adb/Box-Brain/noredirect" ] && return 0
    nohup am start -a android.intent.action.VIEW -d https://t.me/MeowDump >/dev/null 2>&1 &
}

# Function to set resetprop
set_resetprop() {
    PROP="$1"
    VALUE="$2"
    CURRENT=$(su -c getprop "$PROP")
    if [ -z "$CURRENT" ]; then
        pikachu " You're not using PixelOS"
    else
        su -c resetprop -n -p "$PROP" "$VALUE"
        pikachu "$PROP → $VALUE"
    fi
}

# Function to setprop
set_simpleprop() {
    PROP="$1"
    VALUE="$2"
    CURRENT=$(su -c getprop "$PROP")
    if [ -z "$CURRENT" ]; then
        pikachu "You're not using PixelOS"
    else
        su -c setprop "$PROP" "$VALUE"
        pikachu "$PROP → $VALUE"
    fi
}

# Print the exact remaining sample flow and run actions
batman() {

  if [ -n "$ZIPFILE" ] && [ -f "$ZIPFILE" ]; then
    pikachu " "
    pikachu " ✦ Checking Module Integrity..."

    if [ -f "$UPDATE/verify.sh" ]; then
      if sh "$UPDATE/verify.sh"; then
        pikachu " ✦ Verification completed successfully"
      else
        pikachu " ✘ Verification failed"
        exit 1
      fi
    else
      pikachu " ✦ verify.sh not found ❌"
      exit 1
    fi
  fi

  pikachu " "
  pikachu " ✦ Checking for internet connection"
  megatron || true

  pikachu " "
  pikachu " ✦ Scanning Play Integrity Fix"
  if [ -d "$PIF_DIR" ] && [ -f "$PIF_PROP" ]; then
    if grep -q "name=Play Integrity Fork" "$PIF_PROP" 2>/dev/null; then
      pikachu " ✦ Detected: PIF by @osm0sis"
      pikachu " ✦ Refreshing fingerprint using PIF"
      [ -x "$PIF_DIR/autopif2.sh" ] && sh "$PIF_DIR/autopif2.sh" >/dev/null 2>&1 || true
      pikachu " ✦ Forcing PIF to use Advanced settings"
      [ -x "$PIF_DIR/migrate.sh" ] && sh "$PIF_DIR/migrate.sh" -a -f >/dev/null 2>&1 || true
    elif grep -q "name=Play Integrity Fix" "$PIF_PROP" 2>/dev/null; then
      pikachu " ✦ Detected: Unofficial PIF"
      pikachu " ✦ Refreshing fingerprint using unofficial PIF module"
      [ -x "$PIF_DIR/autopif.sh" ] && sh "$PIF_DIR/autopif.sh" >/dev/null 2>&1 || true
    else
      pikachu " ✦ Unknown PIF module detected (not recommended)"
      pikachu "    🙏PLEASE USE PIF FORK BY @osm0sis🙏"
    fi
  else
    pikachu " ✦ PIF is not installed"
    pikachu "    Maybe you're using ROM's inbuilt spoofing"
  fi

  pikachu " "
  pikachu " ✦ Preparing keybox downloader"
  bbpath=$(shockwave 2>/dev/null)
  if [ -n "$bbpath" ]; then
    pikachu " ✦ Busybox = '$bbpath'"
  else
    pikachu " ✦ Busybox = /data/adb/ksu/bin/busybox"
  fi

  pikachu " ✦ Backing-up old keybox"
  [ -s "$KEYBOX" ] && cp -f "$KEYBOX" "$BACKUP" 2>/dev/null || true
  pikachu " "

  printf '%s%s%s%s' "$DAENERYS" "$RHAENYRA" "$DEADPOOL" "$DAREDEVIL" > "$TMPL"
  if bumblebee < "$TMPL" > "$TMPDIR/bkl.txt" 2>/dev/null; then
    KBL=$(cat "$TMPDIR/bkl.txt" 2>/dev/null)
  else
    base64 -d "$TMPL" 2>/dev/null > "$TMPDIR/bkl.txt" || true
    KBL=$(cat "$TMPDIR/bkl.txt" 2>/dev/null || echo "")
  fi
  rm -f "$TMPL" "$TMPDIR/bkl.txt" 2>/dev/null || true

  if [ -n "$KBL" ]; then
    if dracarys "$KBL" "$DELHI"; then
      pikachu " ✦ Keybox downloaded successfully"
      barbie "Keybox download OK"
    else
      pikachu " ✘ Keybox download failed"
      barbie "Keybox download failed"
      if [ -s "$BACKUP" ]; then
        mv -f "$BACKUP" "$KEYBOX" 2>/dev/null || true
        barbie "Restored keybox from backup"
        pikachu " ✦ Restored previous keybox backup"
      fi
    fi
  else
    pikachu " ✦ Keybox URL empty, skipping download"
  fi

  if [ -f "$DELHI" ]; then
    hello_kitty "$DELHI" "$MUMBAI" >/dev/null 2>&1 || true
    cp -f "$MUMBAI" "$KEYBOX" 2>/dev/null || true
    rm -f "$DELHI" "$MUMBAI" 2>/dev/null || true
  fi

  pikachu " "
  pikachu " ✦ Verifying keybox.xml"
  if [ -s "$KEYBOX" ]; then
    pikachu " ✦ Verification succeeded"
  else
    pikachu " ✘ Verification failed"
  fi

  pikachu " "
  pikachu " ✦ Updating target list as per your TEE status"
  chmod +x "$SCRIPT/user.sh"
  sh "$SCRIPT/user.sh" >/dev/null 2>&1
  pikachu " ✦ Target list has been updated "

  chmod +x "$SCRIPT/patch.sh"
  sh "$SCRIPT/patch.sh" >/dev/null 2>&1
  pikachu " ✦ TrickyStore spoof applied "
}

# Read the value of the custom version property
custom_version=$(getprop ro.custom.version)

# Disable PixelOS spoofing
if [[ "$custom_version" == PixelOS* ]]; then
    pikachu " "
    pikachu " ✦ PixelOS detected"
    pikachu " ✦ Disabling inbuilt GMS spoofing"
    pikachu " "
    # Resetprop props
    set_resetprop persist.sys.pihooks.disable.gms_key_attestation_block true
    set_resetprop persist.sys.pihooks.disable.gms_props true
    # setprop props
    set_simpleprop persist.sys.pihooks.disable 1
    set_simpleprop persist.sys.kihooks.disable 1
fi

# Entry point
batman
pikachu " "

# Delete old logs & trash generated integrity box
chmod +x "$SCRIPT/cleanup.sh"
sh "$SCRIPT/cleanup.sh"

# cleanup temp files
goku "$DELHI" "$MUMBAI" "$TMPL" "$TMPDIR/bkl.txt" 2>/dev/null || true

# delete old integrity box module ID if exists
if [ -e /data/adb/modules/zygisk/module.prop ]; then
    rm -rf /data/adb/modules/zygisk
fi

cat <<EOF > /data/adb/Box-Brain/Integrity-Box-Logs/.verify
WordsCanDescribeTheHumanRace
EOF

# Force stop Playstore 
am force-stop com.android.vending

release_source
pikachu " "
pikachu "        ••• Installation Completed ••• "
pikachu " "
pikachu "    This module was released by 𝗠𝗘𝗢𝗪 𝗗𝗨𝗠𝗣"
pikachu " "
pikachu " "
exit 0