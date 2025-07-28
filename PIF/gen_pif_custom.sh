#!/bin/sh
#
# To be run with the /system/build.prop (build.prop) and
# /vendor/build.prop (vendor-build.prop) from the stock
# ROM of a device you want to spoof values from

# Command line options:
# "prop" forces prop format instead of default json
# "all" forces sometimes optional fields like SECURITY_PATCH to always be included
# "deprecated" forces the use of extra/incorrect chiteroman PIF fields and names
# "advanced" adds the verbose logging module setting entry

N="
";

echo "system build.prop to custom.pif.json/.prop creator \
  $N  by osm0sis @ xda-developers";

item() { echo "$N- $@"; }
die() { echo "$N$N! $@"; exit 1; }
file_getprop() {
  case $FORMAT in
    json) grep -m1 "^$2=" "$1" 2>/dev/null | cut -d= -f2- | sed 's|"|\\"|g';;
    prop) grep -m1 "^$2=" "$1" 2>/dev/null | cut -d= -f2-;;
  esac;
}

if [ -d "$1" ]; then
  DIR="$1/dummy";
  LOCAL="$(readlink -f "$PWD")";
  shift;
else
  case "$0" in
    *.sh) DIR="$0";;
    *) DIR="$(lsof -p $$ 2>/dev/null | grep -o '/.*gen_pif_custom.sh$')";;
  esac;
fi;
DIR=$(dirname "$(readlink -f "$DIR")");
if [ "$LOCAL" ]; then
  item "Using prop directory: $DIR";
  item "Using output directory: $LOCAL";
  LOCAL="$LOCAL/";
fi;
cd "$DIR";

FORMAT=json;
ALLFIELDS=false;
OLDFIELDS=false;
ADVANCED=false;
until [ -z "$1" ]; do
  case $1 in
    json|prop) FORMAT=$1; shift;;
    all) ALLFIELDS=true; shift;;
    deprecated) OLDFIELDS=true; STYLE="(Deprecated)"; shift;;
    advanced) ADVANCED=true; [ -z "$STYLE" ] && STYLE="(Advanced)"; shift;;
    *) die "Invalid argument: $1";;
  esac;
done;
item "Using format: $FORMAT $STYLE";

if [ ! -f build.prop ] && [ ! -f system-build.prop ]; then
  [ ! -f product-build.prop -a ! -f vendor-build.prop ] \
  && die "No build.prop files found in script directory";
fi;

item "Parsing build.prop(s) ...";

MANUFACTURER=$(file_getprop build.prop ro.product.manufacturer);
MODEL=$(file_getprop build.prop ro.product.model);
FINGERPRINT=$(file_getprop build.prop ro.build.fingerprint);
BRAND=$(file_getprop build.prop ro.product.brand);
PRODUCT=$(file_getprop build.prop ro.product.name);
DEVICE=$(file_getprop build.prop ro.product.device);
RELEASE=$(file_getprop build.prop ro.build.version.release);
ID=$(file_getprop build.prop ro.build.id);
INCREMENTAL=$(file_getprop build.prop ro.build.version.incremental);
TYPE=$(file_getprop build.prop ro.build.type);
TAGS=$(file_getprop build.prop ro.build.tags);

[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop build.prop ro.product.system.manufacturer);
[ -z "$MODEL" ] && MODEL=$(file_getprop build.prop ro.product.system.model);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop build.prop ro.system.build.fingerprint);
[ -z "$BRAND" ] && BRAND=$(file_getprop build.prop ro.product.system.brand);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop build.prop ro.product.system.name);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop build.prop ro.product.system.device);
[ -z "$RELEASE" ] && RELEASE=$(file_getprop build.prop ro.system.build.version.release);
[ -z "$ID" ] && ID=$(file_getprop build.prop ro.system.build.id);
[ -z "$INCREMENTAL" ] && INCREMENTAL=$(file_getprop build.prop ro.system.build.version.incremental);
[ -z "$TYPE" ] && TYPE=$(file_getprop build.prop ro.system.build.type);
[ -z "$TAGS" ] && TAGS=$(file_getprop build.prop ro.system.build.tags);

[ -z "$DEVICE" ] && DEVICE=$(file_getprop build.prop ro.build.product);

case $DEVICE in
  generic) die 'Generic Google/AOSP "generic" system build.prop values found, rename to system-build.prop and add product-build.prop';;
esac;

[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop product-build.prop ro.product.product.manufacturer);
[ -z "$MODEL" ] && MODEL=$(file_getprop product-build.prop ro.product.product.model);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop product-build.prop ro.product.build.fingerprint);
[ -z "$BRAND" ] && BRAND=$(file_getprop product-build.prop ro.product.product.brand);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop product-build.prop ro.product.product.name);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop product-build.prop ro.product.product.device);
[ -z "$RELEASE" ] && RELEASE=$(file_getprop product-build.prop ro.product.build.version.release);
[ -z "$ID" ] && ID=$(file_getprop product-build.prop ro.product.build.id);
[ -z "$INCREMENTAL" ] && INCREMENTAL=$(file_getprop product-build.prop ro.product.build.version.incremental);
[ -z "$TYPE" ] && TYPE=$(file_getprop product-build.prop ro.product.build.type);
[ -z "$TAGS" ] && TAGS=$(file_getprop product-build.prop ro.product.build.tags);

case $DEVICE in
  missi|qssi) die 'Generic Qualcomm "qssi/missi" system and/or product build.prop values found, rename to system-build.prop and add vendor-build.prop';;
  mssi) die 'Generic MediaTek "mssi" system and/or product build.prop values found, rename to system-build.prop and add vendor-build.prop';;
  essi) die 'Generic Samsung "essi" system and/or product build.prop values found, rename to system-build.prop and add vendor-build.prop';;
esac;

[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop vendor-build.prop ro.product.vendor.manufacturer);
[ -z "$MODEL" ] && MODEL=$(file_getprop vendor-build.prop ro.product.vendor.model);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop vendor-build.prop ro.vendor.build.fingerprint);
[ -z "$BRAND" ] && BRAND=$(file_getprop vendor-build.prop ro.product.vendor.brand);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop vendor-build.prop ro.product.vendor.name);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop vendor-build.prop ro.product.vendor.device);
[ -z "$RELEASE" ] && RELEASE=$(file_getprop vendor-build.prop ro.vendor.build.version.release);
[ -z "$ID" ] && ID=$(file_getprop vendor-build.prop ro.vendor.build.id);
[ -z "$INCREMENTAL" ] && INCREMENTAL=$(file_getprop vendor-build.prop ro.vendor.build.version.incremental);
[ -z "$TYPE" ] && TYPE=$(file_getprop vendor-build.prop ro.vendor.build.type);
[ -z "$TAGS" ] && TAGS=$(file_getprop vendor-build.prop ro.vendor.build.tags);

if [ -z "$FINGERPRINT" ]; then
  if [ -f build.prop ]; then
    die "No fingerprint found, use a /system/build.prop to start";
  else
    die "No fingerprint found, unable to continue";
  fi;
fi;
echo "$FINGERPRINT";

LIST="MANUFACTURER MODEL FINGERPRINT BRAND PRODUCT DEVICE";
if $OLDFIELDS; then
  BUILD_ID=$ID;
  LIST="$LIST BUILD_ID";
else
  LIST="$LIST RELEASE ID INCREMENTAL TYPE TAGS";
fi;

if ! $ALLFIELDS; then
  item "Parsing build UTC date ...";
  UTC=$(file_getprop build.prop ro.build.date.utc);
  [ -z "$UTC" ] && UTC=$(file_getprop system-build.prop ro.build.date.utc);
  date -u -d @$UTC;
fi;

if [ "$UTC" -gt 1521158400 ] || $ALLFIELDS; then
  $ALLFIELDS || item "Build date newer than March 2018, adding SECURITY_PATCH ...";
  SECURITY_PATCH=$(file_getprop build.prop ro.build.version.security_patch);
  [ -z "$SECURITY_PATCH" ] && SECURITY_PATCH=$(file_getprop system-build.prop ro.build.version.security_patch);
  LIST="$LIST SECURITY_PATCH";
  $ALLFIELDS || echo "$SECURITY_PATCH";
fi;

item "Parsing build first API level ...";
DEVICE_INITIAL_SDK_INT=$(file_getprop build.prop ro.product.first_api_level);
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop build.prop ro.board.first_api_level);
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop build.prop ro.board.api_level);
if [ -z "$DEVICE_INITIAL_SDK_INT" ]; then
  [ ! -f vendor-build.prop ] && die "No first API level found, add vendor-build.prop or create empty vendor-build.prop if the device does not have one";
  DEVICE_INITIAL_SDK_INT=$(file_getprop vendor-build.prop ro.product.first_api_level);
  [ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop vendor-build.prop ro.board.first_api_level);
  [ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop vendor-build.prop ro.board.api_level);
fi;

if [ -z "$DEVICE_INITIAL_SDK_INT" ]; then
  item "No first API level found, falling back to build SDK version ...";
  DEVICE_INITIAL_SDK_INT=$(file_getprop build.prop ro.build.version.sdk);
  [ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop build.prop ro.system.build.version.sdk);
  [ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop system-build.prop ro.build.version.sdk);
  [ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop system-build.prop ro.system.build.version.sdk);
  [ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop vendor-build.prop ro.vendor.build.version.sdk);
  [ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT=$(file_getprop product-build.prop ro.product.build.version.sdk);
fi;
echo "$DEVICE_INITIAL_SDK_INT";

if [ "$DEVICE_INITIAL_SDK_INT" -gt 32 ]; then
  item "First API level 33 or higher, resetting to 32 ...";
  DEVICE_INITIAL_SDK_INT=32;
fi;
if $OLDFIELDS; then
  FIRST_API_LEVEL=$DEVICE_INITIAL_SDK_INT;
  LIST="$LIST FIRST_API_LEVEL";
else
  LIST="$LIST DEVICE_INITIAL_SDK_INT";
fi;

if $OLDFIELDS; then
  VNDK_VERSION=$(file_getprop vendor-build.prop ro.vndk.version);
  [ -z "$VNDK_VERSION" ] && VNDK_VERSION=$(file_getprop product-build.prop ro.product.vndk.version);
  if [ -z "$VNDK_VERSION" ]; then
    [ ! -f vendor-default.prop ] && die "No VNDK version found, add vendor-default.prop";
    VNDK_VERSION=$(file_getprop vendor-build.prop ro.vndk.version);
  fi;
  LIST="$LIST VNDK_VERSION";
fi;

if [ -f "$LOCAL"custom.pif.$FORMAT ]; then
  item "Removing existing custom.pif.$FORMAT ...";
  rm -f "$LOCAL"custom.pif.$FORMAT;
fi;

item "Writing new custom.pif.$FORMAT ...";
case $FORMAT in
  json) CMNT='  //'; EVALPRE='\ \ \ \ \"'; PRE='    "'; MID='": "'; POST='",';;
  prop) CMNT='#'; MID='=';;
esac;
([ "$FORMAT" = "json" ] && echo '{';
$OLDFIELDS || echo "$CMNT Build Fields";
for PROP in $LIST; do
  eval echo "$EVALPRE$PROP\$MID\$$PROP\$POST";
done;
if ! $OLDFIELDS; then
  echo "$N$CMNT System Properties";
  echo "$PRE"'*.build.id'"$MID$ID$POST";
  case $LIST in
    *SECURITY_PATCH*) echo "$PRE"'*.security_patch'"$MID$SECURITY_PATCH$POST";;
  esac;
  echo "$PRE"'*api_level'"$MID$DEVICE_INITIAL_SDK_INT$POST";
  if $ADVANCED; then
    echo "$N$CMNT Advanced Settings";
    echo "$PRE"'verboseLogs'"$MID"'0'"$POST";
  fi;
fi) | sed '$s/,/\n}/' | tee "$LOCAL"custom.pif.$FORMAT;

