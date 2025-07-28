#!/system/bin/sh

# Run with /vendor/build.prop (vendor-build.prop) from the stock ROM, from a Xiaomi device,
# to generate custom vendor.pif.json for PIF module
# https://xdaforums.com/t/tools-zips-scripts-osm0sis-odds-and-ends-multiple-devices-platforms.2239421/post-89173470

echo "Generate custom vendor.pif.json file for PIF module from Xiaomi stock vendor-build.prop file\
     \n - provided by osm0sis @ xda-developers, modified for Xiaomi vendor-build.prop files by zgfg @ xda\n";

function item() { echo "\n- $@"; }
function die() { echo "\n\n! $@"; exit 1; }
function file_getprop() { grep "^$2=" "$1" 2>/dev/null | tail -n1 | cut -d= -f2-; }

shdir=${0%/*};
dir="$1";
[ -z "$dir" ] || [ ! -d "$dir" ] && dir="$shdir";

vendor_prop="$dir/vendor-build.prop";
[ ! -f "$vendor_prop" ] || [ ! -r "$vendor_prop" ] || [ ! -s "$vendor_prop" ] && dir='.' && vendor_prop="$dir/vendor-build.prop";
[ ! -f "$vendor_prop" ] || [ ! -r "$vendor_prop" ] || [ ! -s "$vendor_prop" ] && die "$vendor_prop file not found, unable to continue";
vendor_json="$dir/vendor.pif.json";


item "Parsing MANUFACTURER, MODEL, FINGERPRINT, BRAND, PRODUCT and DEVICE from $vendor_prop ...";
MANUFACTURER=$(file_getprop "$vendor_prop" ro.vendor.product.manufacturer);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$vendor_prop" ro.product.vendor.manufacturer);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$vendor_prop" ro.company.name);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$vendor_prop" ro.product.manufacturer);

MODEL=$(file_getprop "$vendor_prop" ro.vendor.product.model);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$vendor_prop" ro.product.vendor.model);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$vendor_prop" ro.product.vendor.cert);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$vendor_prop" ro.product.model);

FINGERPRINT=$(file_getprop "$vendor_prop" ro.vendor.build.fingerprint);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$vendor_prop" ro.bootimage.build.fingerprint);

BRAND=$(file_getprop "$vendor_prop" ro.vendor.product.brand);
[ -z "$BRAND" ] && BRAND=$(file_getprop "$vendor_prop" ro.product.vendor.brand);

PRODUCT=$(file_getprop "$vendor_prop" ro.vendor.product.name);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$vendor_prop" ro.product.vendor.name);

DEVICE=$(file_getprop "$vendor_prop" ro.vendor.product.device);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$vendor_prop" ro.product.vendor.device);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$vendor_prop" ro.product.board);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$vendor_prop" ro.product.mod_device);

[ -z "$MANUFACTURER" ] && MANUFACTURER="$BRAND";
#[ -z "$MODEL" ] && MODEL="$PRODUCT";


[ -z "$MANUFACTURER" ] && die "MANUFACTURER not found, unable to continue";
LIST="MANUFACTURER";
echo "MANUFACTURER=$MANUFACTURER";

[ -n "$MODEL" ] && LIST="$LIST MODEL" && echo "MODEL=$MODEL";

[ -z "$FINGERPRINT" ] && die "FINGERPRINT not found, unable to continue";
LIST="$LIST FINGERPRINT";
echo "FINGERPRINT=$FINGERPRINT";

[ -n "$BRAND" ] && LIST="$LIST BRAND" && echo "BRAND=$BRAND";
[ -n "$PRODUCT" ] && LIST="$LIST PRODUCT" && echo "PRODUCT=$PRODUCT";
[ -n "$DEVICE" ] && LIST="$LIST DEVICE" && echo "DEVICE=$DEVICE";


item "Parsing BUILD_DATE_UTC ...";
BUILD_DATE_UTC=$(file_getprop "$vendor_prop" ro.vendor.build.date.utc);
[ -z "$BUILD_DATE_UTC" ] && BUILD_DATE_UTC=$(file_getprop "$vendor_prop" ro.bootimage.build.date.utc);
[ -z "$BUILD_DATE_UTC" ] && echo "! BUILD_DATE_UTC not found";
date -u -d @"$BUILD_DATE_UTC";

if [ -n "$BUILD_DATE_UTC" ] && [ "$BUILD_DATE_UTC" -gt 1521158400 ]; then
  item "BUILD_DATE_UTC newer than March 2018, adding SECURITY_PATCH ...";
  SECURITY_PATCH=$(file_getprop "$vendor_prop" ro.vendor.build.security_patch);
  [ -z "$SECURITY_PATCH" ] && echo "! SECURITY_PATCH not found";
  [ -n "$SECURITY_PATCH" ] && LIST="$LIST SECURITY_PATCH" && echo "SECURITY_PATCH=$SECURITY_PATCH";
fi;

item "Parsing VNDK_VERSION ...";
VNDK_VERSION=$(file_getprop "$vendor_prop" ro.vndk.version);
[ -n "$VNDK_VERSION" ] && LIST="$LIST VNDK_VERSION" && echo "VNDK_VERSION=$VNDK_VERSION";


item "Parsing FIRST_API_LEVEL ...";
FIRST_API_LEVEL=$(file_getprop "$vendor_prop" ro.product.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$vendor_prop" ro.board.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$vendor_prop" ro.board.api_level);

if [ -n "$FIRST_API_LEVEL" ] && [ "$FIRST_API_LEVEL" -gt 33 ]; then
  item "FIRST_API_LEVEL higher than 33, resetting to 33 ...";
  FIRST_API_LEVEL=33;
fi;

item "Parsing DEVICE_INITIAL_SDK_INT ...";
DEVICE_INITIAL_SDK_INT=$(file_getprop "$vendor_prop" ro.vendor.build.version.sdk);

if [ -n "$DEVICE_INITIAL_SDK_INT" ] && [ "$DEVICE_INITIAL_SDK_INT" -gt 33 ]; then
  item "DEVICE_INITIAL_SDK_INT higher than 33, resetting to 33 ...";
  DEVICE_INITIAL_SDK_INT=33;
fi;

[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL="$DEVICE_INITIAL_SDK_INT";
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT="$FIRST_API_LEVEL";
[ -z "$FIRST_API_LEVEL" ] && echo "! FIRST_API_LEVEL not found";

[ -n "$FIRST_API_LEVEL" ] && LIST="$LIST FIRST_API_LEVEL" && echo "FIRST_API_LEVEL=$FIRST_API_LEVEL";
[ -n "$DEVICE_INITIAL_SDK_INT" ] && LIST="$LIST DEVICE_INITIAL_SDK_INT" && echo "DEVICE_INITIAL_SDK_INT=$DEVICE_INITIAL_SDK_INT";


if [ -f $vendor_json ]; then
  item "Removing present $vendor_json ...";
  mv -f "$vendor_json" "$vendor_json.bak";
fi;

item "Generating $vendor_json ...";
echo '{' | tee -a "$vendor_json";
for PROP in $LIST; do
  eval echo '\ \ \"$PROP\": \"'\$$PROP'\",';
done | sed '$s/,//' | tee -a "$vendor_json";
echo '}' | tee -a "$vendor_json";

[ -z "$BRAND" ] || [ -z "$PRODUCT" ] || [ -z "$DEVICE" ] && item "Run migration script to generate BRAND, PRODUCT and DEVICE";

exit 0;
