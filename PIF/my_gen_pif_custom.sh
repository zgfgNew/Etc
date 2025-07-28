#!/system/bin/sh

# Run with build.prop files from stock ROM to generate custom.pif.json for PI Fork module
# https://xdaforums.com/t/tools-zips-scripts-osm0sis-odds-and-ends-multiple-devices-platforms.2239421/post-89173470

echo "Generate custom.pif.json file for PI Fork module from build.prop files\
     \n - provided by osm0sis @ xda-developers, modified for vendor-build.prop files by zgfg @ xda\n";

function item() { echo "\n- $@"; }
function die() { echo "\n\n! $@"; exit 1; }
function file_getprop() { grep "^$2=" "$1" 2>/dev/null | tail -n1 | cut -d= -f2-; }

shdir=${0%/*};
dir="$1";
[ -z "$dir" ] || [ ! -d "$dir" ] && dir="$shdir";

build_prop="$dir/build.prop";
system_prop="$dir/system-build.prop";
product_prop="$dir/product-build.prop";
vendor_prop="$dir/vendor-build.prop";

custom_json="$dir/custom.pif.json";


item "Parsing MANUFACTURER, MODEL, FINGERPRINT, BRAND, PRODUCT and DEVICE from $build_prop ...";
MANUFACTURER=$(file_getprop "$build_prop" ro.product.manufacturer);
MODEL=$(file_getprop "$build_prop" ro.product.model);
FINGERPRINT=$(file_getprop "$build_prop" ro.build.fingerprint);
BRAND=$(file_getprop "$build_prop" ro.product.brand);
PRODUCT=$(file_getprop "$build_prop" ro.product.name);
DEVICE=$(file_getprop "$build_prop" ro.product.device);

[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$build_prop" ro.product.system.manufacturer);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$build_prop" ro.product.system.model);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$build_prop" ro.system.build.fingerprint);
[ -z "$BRAND" ] && BRAND=$(file_getprop "$build_prop" ro.product.system.brand);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$build_prop" ro.product.system.name);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$build_prop" ro.product.system.device);

item "Parsing MANUFACTURER, MODEL, FINGERPRINT, BRAND, PRODUCT and DEVICE from $product_prop ...";
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$product_prop" ro.product.product.manufacturer);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$product_prop" ro.product.product.model);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$product_prop" ro.product.build.fingerprint);
[ -z "$BRAND" ] && BRAND=$(file_getprop "$product_prop" ro.product.product.brand);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$product_prop" ro.product.product.name);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$product_prop" ro.product.product.device);

item "Parsing MANUFACTURER, MODEL, FINGERPRINT, BRAND, PRODUCT and DEVICE from $vendor_prop ...";
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$vendor_prop" ro.vendor.product.manufacturer);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$vendor_prop" ro.product.vendor.manufacturer);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$vendor_prop" ro.company.name);

[ -z "$MODEL" ] && MODEL=$(file_getprop "$vendor_prop" ro.vendor.product.model);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$vendor_prop" ro.product.vendor.model);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$vendor_prop" ro.product.vendor.cert);

[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$vendor_prop" ro.vendor.build.fingerprint);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$vendor_prop" ro.bootimage.build.fingerprint);

[ -z "$BRAND" ] && BRAND=$(file_getprop "$vendor_prop" ro.vendor.product.brand);
[ -z "$BRAND" ] && BRAND=$(file_getprop "$vendor_prop" ro.product.vendor.brand);

[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$vendor_prop" ro.vendor.product.name);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$vendor_prop" ro.product.vendor.name);

[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$vendor_prop" ro.vendor.product.device);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$vendor_prop" ro.product.vendor.device);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$vendor_prop" ro.product.board);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$vendor_prop" ro.product.mod_device);


item "Parsing MANUFACTURER, MODEL, FINGERPRINT, BRAND, PRODUCT and DEVICE from $product_prop named as $build_prop ...";
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$build_prop" ro.product.product.manufacturer);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$build_prop" ro.product.product.model);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$build_prop" ro.product.build.fingerprint);
[ -z "$BRAND" ] && BRAND=$(file_getprop "$build_prop" ro.product.product.brand);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$build_prop" ro.product.product.name);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$build_prop" ro.product.product.device);


item "Parsing MANUFACTURER, MODEL, FINGERPRINT, BRAND, PRODUCT and DEVICE from $vendor_prop named as $build_prop ...";
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$build_prop" ro.product.vendor.manufacturer);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$build_prop" ro.vendor.product.manufacturer);
[ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$build_prop" ro.company.name);

[ -z "$MODEL" ] && MODEL=$(file_getprop "$build_prop" ro.vendor.product.model);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$build_prop" ro.product.vendor.model);
[ -z "$MODEL" ] && MODEL=$(file_getprop "$build_prop" ro.product.vendor.cert);

[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$build_prop" ro.vendor.build.fingerprint);
[ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$build_prop" ro.bootimage.build.fingerprint);

[ -z "$BRAND" ] && BRAND=$(file_getprop "$build_prop" ro.vendor.product.brand);
[ -z "$BRAND" ] && BRAND=$(file_getprop "$build_prop" ro.product.vendor.brand);

[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$build_prop" ro.vendor.product.name);
[ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$build_prop" ro.product.vendor.name);

[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$build_prop" ro.vendor.product.device);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$build_prop" ro.product.vendor.device);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$build_prop" ro.product.board);
[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$build_prop" ro.product.mod_device);

[ -z "$DEVICE" ] && DEVICE=$(file_getprop "$build_prop" ro.build.product);


item "Taking MANUFACTURER and MODEL from BRAND and PRODUCT...";
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
BUILD_DATE_UTC=$(file_getprop "$build_prop" ro.build.date.utc);
[ -z "$BUILD_DATE_UTC" ] && BUILD_DATE_UTC=$(file_getprop "$system_prop" ro.build.date.utc);
[ -z "$BUILD_DATE_UTC" ] && BUILD_DATE_UTC=$(file_getprop "$vendor_prop" ro.vendor.build.date.utc);
[ -z "$BUILD_DATE_UTC" ] && BUILD_DATE_UTC=$(file_getprop "$vendor_prop" ro.bootimage.build.date.utc);
[ -z "$BUILD_DATE_UTC" ] && BUILD_DATE_UTC=$(file_getprop "$build_prop" ro.vendor.build.date.utc);
[ -z "$BUILD_DATE_UTC" ] && BUILD_DATE_UTC=$(file_getprop "$build_prop" ro.bootimage.build.date.utc);

[ -z "$BUILD_DATE_UTC" ] && echo "! BUILD_DATE_UTC not found";
[ -n "$BUILD_DATE_UTC" ] && date -u -d @"$BUILD_DATE_UTC";

if [ -z "$BUILD_DATE_UTC" ] || [ "$BUILD_DATE_UTC" -gt 1521158400 ]; then
  item "BUILD_DATE_UTC newer than March 2018, adding SECURITY_PATCH ...";
  SECURITY_PATCH=$(file_getprop "$build_prop" ro.build.version.security_patch);
  [ -z "$SECURITY_PATCH" ] && SECURITY_PATCH=$(file_getprop "$vendor_prop" ro.vendor.build.security_patch);
  [ -z "$SECURITY_PATCH" ] && SECURITY_PATCH=$(file_getprop "$build_prop" ro.vendor.build.security_patch);
  [ -z "$SECURITY_PATCH" ] && echo "! SECURITY_PATCH not found";
  [ -n "$SECURITY_PATCH" ] && LIST="$LIST SECURITY_PATCH" && echo "SECURITY_PATCH=$SECURITY_PATCH";
fi;

item "Parsing VNDK_VERSION ...";
VNDK_VERSION=$(file_getprop "$vendor_prop" ro.vndk.version);
[ -z "$VNDK_VERSION" ] && VNDK_VERSION=$(file_getprop "$product_prop" ro.product.vndk.version);
[ -z "$VNDK_VERSION" ] && VNDK_VERSION=$(file_getprop "$build_prop" ro.vndk.version);
[ -z "$VNDK_VERSION" ] && VNDK_VERSION=$(file_getprop "$build_prop" ro.product.vndk.version);
[ -n "$VNDK_VERSION" ] && LIST="$LIST VNDK_VERSION" && echo "VNDK_VERSION=$VNDK_VERSION";


item "Parsing FIRST_API_LEVEL ...";
FIRST_API_LEVEL=$(file_getprop "$build_prop" ro.product.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$build_prop" ro.board.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$build_prop" ro.board.api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$vendor_prop" ro.product.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$vendor_prop" ro.board.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$vendor_prop" ro.board.api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$build_prop" ro.product.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$build_prop" ro.board.first_api_level);
[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$build_prop" ro.board.api_level);

if [ -n "$FIRST_API_LEVEL" ] && [ "$FIRST_API_LEVEL" -gt 33 ]; then
  item "FIRST_API_LEVEL higher than 33, resetting to 33 ...";
  FIRST_API_LEVEL=33;
fi;

item "Parsing DEVICE_INITIAL_SDK_INT ...";
DEVICE_INITIAL_SDK_INT=$(file_getprop "$vendor_prop" ro.vendor.build.version.sdk);
[ -z "$DEVICE_INITIAL_SDK_INT" ] && FDEVICE_INITIAL_SDK_INT=$(file_getprop "$build_prop" ro.vendor.build.version.sdk);

if [ -n "$DEVICE_INITIAL_SDK_INT" ] && [ "$DEVICE_INITIAL_SDK_INT" -gt 33 ]; then
  item "DEVICE_INITIAL_SDK_INT higher than 33, resetting to 33 ...";
  DEVICE_INITIAL_SDK_INT=33;
fi;

[ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL="$DEVICE_INITIAL_SDK_INT";
[ -z "$DEVICE_INITIAL_SDK_INT" ] && DEVICE_INITIAL_SDK_INT="$FIRST_API_LEVEL";
[ -z "$FIRST_API_LEVEL" ] && echo "! FIRST_API_LEVEL not found";

[ -n "$FIRST_API_LEVEL" ] && LIST="$LIST FIRST_API_LEVEL" && echo "FIRST_API_LEVEL=$FIRST_API_LEVEL";
[ -n "$DEVICE_INITIAL_SDK_INT" ] && LIST="$LIST DEVICE_INITIAL_SDK_INT" && echo "DEVICE_INITIAL_SDK_INT=$DEVICE_INITIAL_SDK_INT";


if [ -f $custom_json ]; then
  item "Removing present $custom_json ...";
  mv -f "$custom_json" "$custom_json.bak";
fi;

item "Generating $custom_json ...";
echo '{' | tee -a "$custom_json";
for PROP in $LIST; do
  eval echo '\ \ \"$PROP\": \"'\$$PROP'\",';
done | sed '$s/,//' | tee -a "$custom_json";
echo '}' | tee -a "$custom_json";

[ -z "$BRAND" ] || [ -z "$PRODUCT" ] || [ -z "$DEVICE" ] && item "Run migration script to generate BRAND, PRODUCT and DEVICE";

exit 0;
