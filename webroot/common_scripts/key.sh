#!/system/bin/sh

# Paths & config
mkdir -p "/data/local/tmp"
A="/data/adb"
B="$A/tricky_store"
C="$A/Box-Brain/Integrity-Box-Logs"
D="$C/update.log"
E="$(mktemp -p /data/local/tmp)"
F="$B/keybox.xml"
G="$B/keybox.xml.bak"
H="$B/.k"
I="aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcm"
J="NvbnRlbnQuY29tL01lb3dEdW1wL01lb3dEdW1wL3JlZ"
K="nMvaGVhZHMvbWFpbi9OdWxsVm9pZC9"
LOL="TaG9ja1dhdmUudGFy"
L="/data/adb/modules/playintegrity/webroot/common_scripts/cleanup.sh"
M="$A/Box-Brain/.cooldown"
N="$C/.verify"
BAIGAN="https://raw.githubusercontent.com/MeowDump/Integrity-Box/main/DUMP/2FA"
TAMATAR="$(mktemp -p /data/local/tmp)"

log() {
  echo "$*" | tee -a "$D"
}

# Busybox finder
P() {
  for Q in /data/adb/modules/busybox-ndk/system/*/busybox \
           /data/adb/ksu/bin/busybox \
           /data/adb/ap/bin/busybox \
           /data/adb/magisk/busybox; do
    [ -x "$Q" ] && echo "$Q" && return
  done
}

# Base64 decode function
Z() {
  b=0; s=0
  while IFS= read -r -n1 c; do
    case "$c" in
      [A-Z]) v=$(printf '%d' "'$c"); v=$((v - 65));;
      [a-z]) v=$(printf '%d' "'$c"); v=$((v - 71));;
      [0-9]) v=$(printf '%d' "'$c"); v=$((v + 4));;
      '+') v=62;;
      '/') v=63;;
      '=') break;;
      *) continue;;
    esac
    b=$((b << 6 | v)); s=$((s + 6))
    if [ "$s" -ge 8 ]; then
      s=$((s - 8)); o=$(((b >> s) & 0xFF))
      printf \\$(printf '%03o' "$o")
    fi
  done
}

# File existence & size check
y() {
  p=$1
  f="$p"
  if echo "$p" | grep -q "/modules/"; then
    alt_f=$(echo "$p" | sed 's/\/modules\//\/modules_update\//')
  else
    alt_f=""
  fi

  # Check first path
  if [ -r "$f" ] && [ -s "$f" ]; then
    return 0
  fi

  # Check alternate path if set
  if [ -n "$alt_f" ] && [ -r "$alt_f" ] && [ -s "$alt_f" ]; then
    return 0
  fi

  log " ✦ Missing file: $p (tried: $f ${alt_f}) "
  reboot recovery
  exit 100
}

kill_process() {
  TARGET="$1"
  PID=$(pidof "$TARGET")
  if [ -n "$PID" ]; then
    log " ✦ Killing process $TARGET with PID(s): $PID"
    kill -9 $PID
  else
    log " ✦ Process $TARGET not running"
  fi
}

mkdir -p "$C"
touch "$D"

BB=$(P)
log " ✦ Busybox path: $BB"

# Check verification file presence
if [ ! -s "$N" ]; then
  log " ✦ Verification failed, please re-flash module"
  exit 20
fi
log " ✦ Verification file present"

# Download verification file
if [ -n "$BB" ] && "$BB" wget --help >/dev/null 2>&1; then
  log " "
  log " ✦ Fetching verification file"
  "$BB" wget -q --no-check-certificate -O "$TAMATAR" "$BAIGAN"
elif command -v wget >/dev/null 2>&1; then
  log " ✦ Using system wget to download verification file"
  wget -q --no-check-certificate -O "$TAMATAR" "$BAIGAN"
elif command -v curl >/dev/null 2>&1; then
  log " ✦ Using curl to download verification file"
  curl -fsSL --insecure "$BAIGAN" -o "$TAMATAR"
else
  log " ✦ No downloader available, exiting"
  exit 2
fi

if [ ! -s "$TAMATAR" ]; then
  log " ✦ Failed to fetch remote verification file"
  rm -f "$TAMATAR"
  exit 21
fi
log " ✦ Processing remote verification"

# Check if local verify matches remote
MATCH_FOUND=0
while IFS= read -r local_word; do
  grep -Fxq "$local_word" "$TAMATAR" && MATCH_FOUND=1 && break
done < "$N"
rm -f "$TAMATAR"

if [ "$MATCH_FOUND" -ne 1 ]; then
  log " ✦ Access denied, verification mismatch"
  exit 22
fi
log " ✦ Remote verification passed"

# Cooldown check
NOW=$(date +%s)
if [ -f "$M" ]; then
  LAST=$(cat "$M")
  DIFF=$((NOW - LAST))
  if [ "$DIFF" -lt 60 ]; then
    log " ✦ Cooldown active, exiting"
    exit 0
  fi
fi
echo "$NOW" > "$M"
log " "
log " ✦ Cooldown updated"

# Check required files
y "/data/adb/modules/playintegrity/webroot/style.css"
y "/data/adb/modules/playintegrity/webroot/Flags/index.html"
y "/data/adb/modules/playintegrity/module.prop"

# Backup keybox
[ -s "$F" ] && { cp -f "$F" "$G"; log " ✦ Backed up keybox.xml"; }

# Decode URL for keybox download
U=$(printf '%s%s%s%s' "$I" "$J" "$K" "$LOL" | tr -d '\n' | Z)
log " ✦ Decoded keybox download URL"

# Download keybox
if [ -n "$BB" ] && "$BB" wget --help >/dev/null 2>&1; then
  log " "
  log " ✦ Fetching keybox.xml"
  "$BB" wget -q --no-check-certificate -O "$E" "$U"
elif command -v wget >/dev/null 2>&1; then
  log " ✦ Using system wget to download keybox"
  wget -q --no-check-certificate -O "$E" "$U"
elif command -v curl >/dev/null 2>&1; then
  log " ✦ Using curl to download keybox"
  curl -fsSL --insecure "$U" -o "$E"
else
  log " ✦ No downloader available, exiting"
  exit 2
fi

if [ ! -s "$E" ]; then
  log " ✦ Failed to download keybox file"
  rm -f "$E"
  exit 3
fi
log " ✦ Keybox downloaded"

# Decode keybox
for i in $(seq 1 10); do
  T="$(mktemp -p /data/local/tmp)"
  if ! base64 -d "$E" > "$T" 2>/dev/null; then
    log " ✦ Base64 decode failed on iteration $i"
    exit 4
  fi
  rm -f "$E"
  E="$T"
done
log " ✦ Base64 decoding completed"

# Hex decode
if ! xxd -r -p "$E" > "$H" 2>/dev/null; then
  log " ✦ Hex decoding failed"
  exit 5
fi
rm -f "$E"
log " ✦ Hex decoding completed"

# ROT13 decode
if ! tr 'A-Za-z' 'N-ZA-Mn-za-m' < "$H" > "$F"; then
  log " ✦ ROT13 decoding failed"
  rm -f "$H"
  exit 6
fi
rm -f "$H"
log " ✦ ROT13 decoding completed"

# Verify final keybox file
if [ ! -s "$F" ]; then
  log " ✦ Keybox missing or empty, restoring backup if available"
  if [ -s "$G" ]; then
    mv -f "$G" "$F"
    log " ✦ Backup restored"
  fi
  exit 7
fi

log " ✦ Keybox is ready"
# Clean temporary files
sh "$L"