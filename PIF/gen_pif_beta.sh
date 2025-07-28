#!/bin/bash
#
# Command line options:
# "advanced" adds the module advanced settings entries
# "strong" same as "advanced" but with spoofProvider set to 0 (disabled) and *.security_patch commented out
# "force" dumps despite a mismatch of build ID between the GSI and Beta sites
# "debug" dumps the parsed sites' HTML for debugging purposes

N="
";

echo "Desktop Pixel Beta crawler-dumper custom.pif.json generator \
  $N  by osm0sis @ xda-developers";

item() { echo "$N- $@"; }
debug() {
  if $DEBUG; then
    item "Dumping debugging files ...";
    mkdir -p debug;
    cd debug;
    echo "$GSI_HTML" > PIXEL_GSI_HTML;
    echo "$GET_HTML" > PIXEL_GET_HTML;
    echo "$BETA_HTML" > PIXEL_BETA_HTML;
    echo "$SECBULL_HTML" > PIXEL_SECBULL_HTML;
  fi;
}
die() { echo "$N! $@"; debug; exit 1; }

DIR=$(dirname "$(readlink -f "$0")");
cd "$DIR";

ADVANCED=false;
FORCE=false;
DEBUG=false;
until [ -z "$1" ]; do
  case $1 in
    advanced) ADVANCED=true; PROVIDER=1; shift;;
    strong) ADVANCED=true; PROVIDER=0; STRONG_COMMENT=//; shift;;
    force) FORCE=true; shift;;
    debug) DEBUG=true; shift;;
    *) die "Invalid argument: $1";;
  esac;
done;

item "Crawling Android Developers for latest Pixel Beta ...";

GSI_HTML="$(wget -q -O - --no-check-certificate https://developer.android.com/topic/generic-system-image/releases)";
[ -z "$GSI_HTML" ] && die "Failed to download GSI HTML";

RELEASE="$(echo "$GSI_HTML" | grep -m1 'corresponding Google Pixel builds' | grep -o '/versions/.*' | cut -d\/ -f3)";
ID="$(echo "$GSI_HTML" | grep -m1 -o 'Build:.*' | cut -d\  -f2)";
INCREMENTAL="$(echo "$GSI_HTML" | grep -m1 -o "$ID-.*-" | cut -d- -f2)";

BETA_NAME="$(echo "$GSI_HTML" | grep -m1 -o 'li>.*(Beta)' | cut -d\> -f2)";
BETA_REL_DATE="$(date -d "$(echo "$GSI_HTML" | grep -m1 -o 'Date:.*' | cut -d\  -f2-4)" '+%Y-%m-%d')";
BETA_EXP_DATE="$(date -d "$BETA_REL_DATE +6 weeks" '+%Y-%m-%d')";
echo "$BETA_NAME \
  ${N}Build ID: $ID \
  ${N}Beta Released: $BETA_REL_DATE \
  ${N}Estimated Expiry: $BETA_EXP_DATE";

GET_HTML="$(wget -q -O - --no-check-certificate https://developer.android.com`echo "$GSI_HTML" | grep -m1 'corresponding Google Pixel builds' | grep -o 'href.*' | cut -d\" -f2`)";
[ -z "$GET_HTML" ] && die "Failed to download GET HTML";

BETA_HTML="$(wget -q -O - --no-check-certificate https://developer.android.com`echo "$GET_HTML" | grep -m1 'Factory images for Google Pixel' | grep -o 'href.*' | cut -d\" -f2`)";
[ -z "$BETA_HTML" ] && die "Failed to download BETA HTML";

MODEL_LIST="$(echo "$BETA_HTML" | grep -A1 'tr id=' | grep 'td' | sed 's;.*<td>\(.*\)</td>;\1;')";
PRODUCT_LIST="$(echo "$BETA_HTML" | grep -o 'factory/.*_beta' | cut -d\/ -f2)";

SECBULL_HTML="$(wget -q -O - --no-check-certificate https://source.android.com/docs/security/bulletin/pixel)";
[ -z "$SECBULL_HTML" ] && die "Failed to download SECBULL HTML";

SECURITY_PATCH="$(echo "$SECBULL_HTML" | grep -A15 "$(echo "$GSI_HTML" | grep -m1 -o 'Security patch level:.*' | cut -d\  -f4-)" | grep -m1 -B1 '</tr>' | grep 'td' | sed 's;.*<td>\(.*\)</td>;\1;')";

BETA_ID="$(echo "$BETA_HTML" | grep -m1 -o 'factory/.*_beta.*-factory' | cut -d- -f2)";
if [ "$BETA_ID" != "${ID,,}" ]; then
  echo "$N! GSI ID (${ID,,}) does not match BETA ID ($BETA_ID) \
    $N  Beta device list could be inaccurate until GSI updated";
  if ! $FORCE; then
    debug;
    exit 1;
  fi;
fi;

item "Dumping Pixel Beta device values to custom.pif.json ...";

BETA_DIR="$(echo "$BETA_NAME" | sed -e 's/Android /a/' -e 's/ QPR/ qpr/' -e 's/ (Beta)/ beta/' -e 's/ /_/g')_${ID,,}";
rm -rf "$BETA_DIR";
mkdir -p "$BETA_DIR";
cd "$BETA_DIR";

dump_device() {
  cat <<EOF > $PRODUCT-${ID,,}.json;
{
  // Build Fields
    "MANUFACTURER": "Google",
    "MODEL": "$MODEL",
    "FINGERPRINT": "google/$PRODUCT/$DEVICE:$RELEASE/$ID/$INCREMENTAL:user/release-keys",
    "BRAND": "google",
    "PRODUCT": "$PRODUCT",
    "DEVICE": "$DEVICE",
    "RELEASE": "$RELEASE",
    "ID": "$ID",
    "INCREMENTAL": "$INCREMENTAL",
    "TYPE": "user",
    "TAGS": "release-keys",
    "SECURITY_PATCH": "$SECURITY_PATCH",
    "DEVICE_INITIAL_SDK_INT": "32",

  // System Properties
    "*.build.id": "$ID",
    $STRONG_COMMENT"*.security_patch": "$SECURITY_PATCH",
    "*api_level": "32"$ADVANCED_SETTINGS

  // Beta Released: $BETA_REL_DATE
  // Estimated Expiry: $BETA_EXP_DATE
}
EOF
}

if $ADVANCED; then
  ADVANCED_SETTINGS=",

  // Advanced Settings
    \"spoofBuild\": \"1\",
    \"spoofProps\": \"1\",
    \"spoofProvider\": \"$PROVIDER\",
    \"spoofSignature\": \"0\",
    \"verboseLogs\": \"0\"";
fi;

IFS="$N" MODEL_ARRAY=($MODEL_LIST);
IFS="$N" PRODUCT_ARRAY=($PRODUCT_LIST);

for i in ${!MODEL_ARRAY[@]}; do
  MODEL="${MODEL_ARRAY[i]}";
  PRODUCT="${PRODUCT_ARRAY[i]}";
  DEVICE="$(echo "$PRODUCT" | sed 's/_beta//')";
  echo "$MODEL ($PRODUCT)";
  dump_device;
done;

debug;

echo "${N}Done!";

