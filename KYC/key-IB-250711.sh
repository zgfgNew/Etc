#!/system/bin/sh

# Modified from Integrity Box (MeowDump/TempMeow)
# Adapted by dosbuddy@xda, updated by osm0sis@xda

# See customize.sh and de-obfuscated keybox_downloader.sh (kd_mbt60)

echo -e "\n=== IB Keybox Retriever ===";

case "$0" in
  *.sh) DIR="$0";;
  *) DIR="$(lsof -p $$ 2>/dev/null | grep -o '/.*key-IB-.*.sh$')";;
esac;
DIR=$(dirname "$(readlink -f "$DIR")");
cd "$DIR" || exit 1;

case $1 in
  --dumpraw|-d) DUMPRAW=1; shift;;
esac

URLS="
# Valid Keybox URL
https://raw.githubusercontent.com/hellomona69/orangecat.github.io/lmao/meow.tar
";

[ -n "$1" ] && URLS="$1";

abort() { echo "! Error: $@"; exit 1; }
skip() { echo "! Error: $@, skipping"; }

for i in /data/adb/modules/busybox-ndk/system/*/busybox /data/adb/magisk/busybox /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox; do
  if [ -f "$i" ]; then
    BUSYBOX="$i";
    break;
  fi;
done;
[ -z "$BUSYBOX" ] && abort "Busybox not found";

wget() { $BUSYBOX wget "$@"; }

for URL in $(echo "$URLS" | grep -v '^#'); do
  USER=$(echo "$URL" | cut -d/ -f4);
  REPO=$(echo "$URL" | cut -d/ -f5);
  BRANCH=$(echo "$URL" | cut -d/ -f6);
  FILE=$(echo "$URL" | cut -d/ -f7-);
  echo -e "\n> Retrieving latest $(basename "$URL" .tar) key ... \
    \n  Repo: $USER/$REPO \
    \n  Branch: $BRANCH \
    \n  File: $FILE";
  DATE=$(wget -q -O - --no-check-certificate "https://api.github.com/repos/$USER/$REPO/commits?sha=$BRANCH&path=/$FILE&page=1&per_page=1" | grep -m1 -oE 'date":.*' | cut -d\  -f2 | tr -d '\"\-\:Z' | tr 'T' '_');
  NAME=$USER-$(basename "$URL" .tar)_$DATE-keybox.xml;
  [ -f $NAME ] && skip "Previously dumped" && continue;
  unset KEY_CONTENT;
  KEY_CONTENT="$(wget -q -O - --no-check-certificate "$URL" | base64 -d | base64 -d | base64 -d | base64 -d | base64 -d | base64 -d | base64 -d | base64 -d | base64 -d | base64 -d | xxd -r -p | tr '[a-zA-Z]' '[n-za-mN-ZA-M]')";
  [ "$DUMPRAW" ] && echo "$KEY_CONTENT" > $USER-$(basename "$URL" .tar).raw
  echo "> Saving keybox.xml ...";
  echo "$KEY_CONTENT" > $NAME;
  sleep 0.5;
  sed -i "s|DeviceID=\".*\"|DeviceID=\"$(date '+%Y%m%d_%H%M%S')\"|" $NAME;
  echo "> Cleaning improper formatting ...";
  sed -i -e 's/bina//' -e 's/module//' -e 's/kekeybox//' -e 's/karne//' -e 's/download//' -e 's/wale//' -e 's/kima//' -e 's/randi//' -e 's/mona.sh//' -e '/<IntegrityNote>/,/<\/IntegrityNote>/d' $NAME;
done;

echo -e "\n=== ENDED ===";
