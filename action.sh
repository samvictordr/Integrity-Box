#!/system/bin/sh

# Paths
MODULE="/data/adb/modules"
MODDIR="$MODULE/playintegrity"
SCRIPT_DIR="$MODDIR/webroot/common_scripts"
TARGET="$SCRIPT_DIR/user.sh"
KILL="$SCRIPT_DIR/kill.sh"
UPDATE="$SCRIPT_DIR/key.sh"
PIF="$MODULE/playintegrityfix"
PROP="/data/adb/modules/playintegrity/module.prop"
URL="https://raw.githubusercontent.com/MeowDump/Integrity-Box/refs/heads/main/DUMP/notice.md"
BAK="$PROP.bak"

# Random quote
quotes="Hated by many, Defeated by none.
Every scar tells a story of survival.
The darkest nights produce the brightest stars.
Healing takes time, but every day is progress.
Your past does not define your future.
Even broken crayons can still color.
Be proud of how far you’ve come, and have faith in how far you can go.
The strongest people fight battles we never see.
Storms make trees take deeper roots.
World doesn't revolves around play integrity.
Be good for nothing.
Do good to others, and goodness will come back to you.
You are what you think.
What you go through grows you."

rand=$((RANDOM % 14 + 1))
echo " "
echo "💭 $(echo "$quotes" | sed -n "${rand}p")"
echo " "
echo " "
echo " "

# Connectivity check
megatron() {
  hosts="8.8.8.8 1.1.1.1 8.8.4.4"
  max_attempts=5
  attempt=1
  while [ $attempt -le $max_attempts ]; do
    for h in $hosts; do
      ping -c 1 -W 5 $h >/dev/null 2>&1 && return 0
    done
    if command -v curl >/dev/null 2>&1; then
      curl -s --max-time 5 http://clients3.google.com/generate_204 >/dev/null 2>&1 && return 0
    fi
    attempt=$((attempt + 1))
    sleep 1
  done
  return 1
}

if ! megatron; then exit 1; fi

{
  # BusyBox finder
  for p in /data/adb/modules/busybox-ndk/system/*/busybox \
           /data/adb/ksu/bin/busybox \
           /data/adb/ap/bin/busybox \
           /data/adb/magisk/busybox \
           /system/bin/busybox \
           /system/xbin/busybox; do
    [ -x "$p" ] && bb=$p && break
  done
  [ -z "$bb" ] && return 0

  # Download
  C=$($bb wget -qO- "$URL" 2>/dev/null)

  if [ -n "$C" ]; then
    # Update if content present
    $bb cp "$PROP" "$BAK"
    $bb sed -i '/^description=/d' "$PROP"
    echo "description=$C" >> "$PROP"
  else
    # Restore if empty or failed
    [ -f "$BAK" ] && $bb cp "$BAK" "$PROP"
  fi
} || true

# Result formatting
OK="[ ✔ ]"
FAIL="[ ✖ failed ]"
MISS="[ ✖ missing ]"

show_step() {
  printf "▶ %-30s" "$1"
}
show_result() {
  case "$1" in
    ok)   echo " $OK" ;;
    fail) echo " $FAIL" ;;
    miss) echo " $MISS" ;;
  esac
}

# Steps
show_step "Updating Target List"
if [ -f "$TARGET" ]; then
  sh "$TARGET" >/dev/null 2>&1 && show_result ok || show_result fail
else
  show_result miss
fi

show_step "Downloading Fingerprint"
if [ -f "$PIF/autopif2.sh" ]; then FP_SCRIPT="$PIF/autopif2.sh"
elif [ -f "$PIF/autopif.sh" ]; then FP_SCRIPT="$PIF/autopif.sh"
else FP_SCRIPT=""; fi
if [ -n "$FP_SCRIPT" ]; then
  sh "$FP_SCRIPT" >/dev/null 2>&1 && show_result ok || show_result fail
else
  show_result miss
fi

show_step "Applying Advanced PIF Settings"
if [ -f "$PIF/migrate.sh" ]; then
  sh "$PIF/migrate.sh" -a -f >/dev/null 2>&1 && show_result ok || show_result fail
else
  show_result miss
fi

show_step "Updating Keybox"
if [ -f "$UPDATE" ]; then
  sh "$UPDATE" >/dev/null 2>&1 && show_result ok || show_result fail
else
  show_result miss
fi

show_step "Restarting GMS Services"
if [ -f "$KILL" ]; then
  sh "$KILL" >/dev/null 2>&1 && show_result ok || show_result fail
else
  show_result miss
fi

exit 0