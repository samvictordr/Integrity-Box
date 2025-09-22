#!/system/bin/sh

placeholder="/data/adb/modules/playintegrity/webroot/common_scripts"

if [ -f "/data/adb/modules/playintegrity/customize.sh" ]; then
  rm -rf "/data/adb/modules/playintegrity/customize.sh"
fi

# create dummy placeholder files to fix broken translations in webui
touch "$placeholder/meowverse.sh"
touch "$placeholder/report.sh"
touch "$placeholder/vending.sh"
touch "$placeholder/start.sh"
touch "$placeholder/stop.sh"