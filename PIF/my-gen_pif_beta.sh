#!/system/bin/sh

#https://developer.android.com/topic/generic-system-image/releases
#https://source.android.com/docs/security/bulletin/pixel
#https://developer.android.com/about/versions/15/get-qpr1
#https://developer.android.com/about/versions/15/download-qpr1

# Module's own path (local path)
MODPATH="${0%/*}"

# Log file for debugging
LogFile="$MODPATH/my-gen_pif_beta.log"
#exec 3>&1 4>&2 2>$LogFile 1>&2
#set -x

# Log info
date +%c
whoami
magisk -c
echo $APATCH

if [ "$USER" != "root" -a "$(whoami 2>/dev/null)" != "root" ]; then
  echo "my-gen_pif_beta: need root permissions";
  exit 1;
fi;

echo "Pixel Beta crawler-dumper custom.pif.json generator \
  \n  based on autopif2.sh from osm0sis @ xda-developers \
  \n  (modified by zgfg @ xda for Android shell)";

case "$0" in
  *.sh) DIR="$0";;
  *) DIR="$(lsof -p $$ 2>/dev/null | grep -o '/.*my-gen_pif_beta.sh$')";;
esac;
DIR=$(dirname "$(readlink -f "$DIR")");
cd "$DIR";

if [ ! -f migrate.sh ]; then
  echo "migrate.sh not found";
  exit 1;
fi;

item() { echo "\n- $@"; }
die() { echo "\nError: $@, install busybox!"; exit 1; }

find_busybox() {
  [ -n "$BUSYBOX" ] && return 0;
  local path;
  for path in /data/adb/modules/BuiltIn-BusyBox/busybox /data/adb/modules/busybox-ndk/system/*/busybox /data/adb/magisk/busybox /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox; do
    if [ -f "$path" ]; then
      BUSYBOX="$path";
      return 0;
    fi;
  done;
  return 1;
}

if ! which wget >/dev/null || grep -q "wget-curl" $(which wget); then
  if ! find_busybox; then
    die "wget not found";
  elif $BUSYBOX ping -c1 -s2 android.com 2>&1 | grep -q "bad address"; then
    die "wget broken";
  else
    wget() { $BUSYBOX wget "$@"; }
  fi;
fi;

if date -D '%s' -d "$(date '+%s')" 2>&1 | grep -q "bad date"; then
  if ! find_busybox; then
    die "date broken";
  else
    date() { $BUSYBOX date "$@"; }
  fi;
fi;

rm -f Pixel*.json;

item "Crawling Android Developers for latest Pixel Beta ...";
wget -q -O PIXEL_GSI_HTML --no-check-certificate https://developer.android.com/topic/generic-system-image/releases 2>&1 || exit 1;
grep -m1 -o 'li>.*(Beta)' PIXEL_GSI_HTML | cut -d\> -f2;

BETA_REL_DATE="$(date -D '%B %e, %Y' -d "$(grep -m1 -o 'Date:.*' PIXEL_GSI_HTML | cut -d\  -f2-4)" '+%Y-%m-%d')";
BETA_EXP_DATE="$(date -D '%s' -d "$(($(date -D '%Y-%m-%d' -d "$BETA_REL_DATE" '+%s') + 60 * 60 * 24 * 7 * 6))" '+%Y-%m-%d')";
echo "Beta Released: $BETA_REL_DATE \
  \nEstimated Expiry: $BETA_EXP_DATE";

RELEASE="$(grep -m1 'corresponding Google Pixel builds' PIXEL_GSI_HTML | grep -o '/versions/.*' | cut -d\/ -f3)";
ID="$(grep -m1 -o 'Build:.*' PIXEL_GSI_HTML | cut -d\  -f2)";
INCREMENTAL="$(grep -m1 -o "$ID-.*-" PIXEL_GSI_HTML | cut -d- -f2)";

wget -q -O PIXEL_GET_HTML --no-check-certificate https://developer.android.com$(grep -m1 'corresponding Google Pixel builds' PIXEL_GSI_HTML | grep -o 'href.*' | cut -d\" -f2) 2>&1 || exit 1;
wget -q -O PIXEL_BETA_HTML --no-check-certificate https://developer.android.com$(grep -m1 'Factory images for Google Pixel' PIXEL_GET_HTML | grep -o 'href.*' | cut -d\" -f2) 2>&1 || exit 1;

MODEL_LIST="$(grep -A1 'tr id=' PIXEL_BETA_HTML | grep 'td' | sed 's;.*<td>\(.*\)</td>;\1;')";
PRODUCT_LIST="$(grep -o 'factory/.*_beta' PIXEL_BETA_HTML | cut -d\/ -f2)";

wget -q -O PIXEL_SECBULL_HTML --no-check-certificate https://source.android.com/docs/security/bulletin/pixel 2>&1 || exit 1;

SECURITY_PATCH="$(grep -A15 "$(grep -m1 -o 'Security patch level:.*' PIXEL_GSI_HTML | cut -d\  -f4-)" PIXEL_SECBULL_HTML | grep -m1 -B1 '</tr>' | grep 'td' | sed 's;.*<td>\(.*\)</td>;\1;')";

item "Dumping values to minimal pif.json ...";
LIST_COUNT="$(echo "$MODEL_LIST" | wc -l)";
IFS=$'\n';
(( INDEX = 0 ));
while ((( INDEX++ < LIST_COUNT ))); do
  set -- $MODEL_LIST;
  MODEL="$(eval echo \${$INDEX})";

  set -- $PRODUCT_LIST;
  PRODUCT="$(eval echo \${$INDEX})";
  DEVICE=$(echo "$PRODUCT" | sed 's/_beta$//i');
  
  NAME=$(echo "$MODEL-$DEVICE" | sed 's/ /_/g');
  echo "NAME: $NAME";
  
  cat <<EOF | tee pif.json;
{
  "MANUFACTURER": "Google",
  "MODEL": "$MODEL",
  "FINGERPRINT": "google/$PRODUCT/$DEVICE:$RELEASE/$ID/$INCREMENTAL:user/release-keys",
  "PRODUCT": "$PRODUCT",
  "DEVICE": "$DEVICE",
  "SECURITY_PATCH": "$SECURITY_PATCH",
  "DEVICE_INITIAL_SDK_INT": "32"
}
EOF

  item "Converting pif.json to custom.pif.json with migrate.sh:";
  rm -f custom.pif.json;
  sh ./migrate.sh -i -f -a pif.json;

  sed -i "s;};\n  // Beta Released: $BETA_REL_DATE\n  // Estimated Expiry: $BETA_EXP_DATE\n};" custom.pif.json;
  cp custom.pif.json "$NAME"-custom.pif.json;
done;

rm -f pif.json;
mv "PIXEL_GSI_HTML" "PIXEL_GSI.HTML";
mv "PIXEL_GET_HTML" "PIXEL_GET.HTML";
mv "PIXEL_BETA_HTML" "PIXEL_BETA.HTML";
mv "PIXEL_SECBULL_HTML" "PIXEL_SECBULL.HTML";

PIXEL_BETA_LIST=PIXEL_BETA_"$INCREMENTAL"-LIST.txt;
item "Creating $PIXEL_BETA_LIST:";
rm -f "$PIXEL_BETA_LIST";
item "$(date +%c): generated $LIST_COUNT custom.pif.json files" | tee "$PIXEL_BETA_LIST";
ls Pixel*.json | tee "$PIXEL_BETA_LIST";

#set +x
#exec 1>&3 2>&4 3>&- 4>&-
