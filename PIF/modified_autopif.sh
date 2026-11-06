#!/system/bin/sh

# https://github.com/Vagelis1608/get_the_canary_miner/tree/main/devices

if [ "$USER" != "root" -a "$(whoami 2>/dev/null)" != "root" ]; then
  echo "script needs root permissions";
#  exit 1;
fi;

echo "Pixel Beta dumper custom.pif.json generator \
  \n  based on autopif2.sh from osm0sis @ xda-developers \
  \n  (quick'n'dirty modified by zgfg @ xda)";

DIR="$0";
DIR=$(dirname "$(readlink -f "$DIR")");
cd "$DIR";

if [ ! -f migrate.sh ]; then
  echo "migrate.sh not found";
  exit 1;
fi;

item() { echo "\n- $@"; }

# Read RELEASE, INCREMENTAL, SECURITY_PATCH (and BETA_REL_DATE)
# https://developer.android.com/topic/generic-system-image/releases#android-gsi-16
# https://9to5google.com/2025/07/10/android-canary-channel-developer-previews/

# Pixel Factory Images Tracker
#https://t.me/pixelfactoryimagestracker

# Pixel Canary Images
#https://gist.github.com/ItzLevvie/1a82ba4b8c9e978baeea68342c1f92c5#file-readme-md

# Uncomment to enable A17 Canary prints
CANARY=1

if [ -n "$CANARY" ]; then

  # A17 CANARY Nov 4:
  RELEASE="CANARY";
  PREVIEW="A17-$RELEASE-Nov4";
  BETA_REL_DATE="2026-11-04";
  BETA_EXP_DATE="2026-12-16";

  SEC_PATCH="2026-11-05";
  ID="ZP11.261016.008";
  INCREMENTAL="16754936";

# Different parameters for exceptional devices
#  EX_DEVICES_LIST="cubs grizzly kodiak yogi";
  EX_SEC_PATCH="2026-11-05";
  EX_ID="ZP11.261016.008";
  EX_INCREMENTAL="16754936";

else

  # A17 QPR3 Beta2
  RELEASE="17";
  PREVIEW="A$RELEASE-QPR3-Beta2";
  BETA_REL_DATE="2026-10-20";
  BETA_EXP_DATE="2026-12-01";

  SEC_PATCH="2026-10-05";
  ID="DP11.261002.005";
  INCREMENTAL="16594701";

fi
item "PREVIEW: $PREVIEW, BETA_REL_DATE: $BETA_REL_DATE, BETA_EXP_DATE: $BETA_EXP_DATE";

MODEL_LIST="Pixel_6a 
Pixel_7 
Pixel_7_Pro 
Pixel_7a 
Pixel_Fold 
Pixel_Tablet 
Pixel_8 
Pixel_8_Pro 
Pixel_8a 
Pixel_9 
Pixel_9_Pro 
Pixel_9_Pro_Fold 
Pixel_9_Pro_XL 
Pixel_9a 
Pixel_10a 
Pixel_10 
Pixel_10_Pro 
Pixel_10_Pro_XL 
Pixel_10_Pro_Fold 
Pixel_11 
Pixel_11_Pro 
Pixel_11_Pro_XL 
Pixel_11_Pro_Fold ";

DEVICE_LIST="bluejay 
panther 
cheetah 
lynx 
felix 
tangorpro 
shiba 
husky 
akita 
tokay 
caiman 
comet 
komodo 
tegu 
stallion 
frankel 
blazer 
mustang 
rango 
cubs 
grizzly 
kodiak 
yogi ";

API_LIST="32 
33 
33 
33 
33 
33 
34 
34 
34 
34 
34 
34 
34 
35 
35 
36 
36 
36 
36 
37 
37 
37 
37 ";

LIST_COUNT="$(echo "$MODEL_LIST" | wc -l)";
item "LIST_COUNT: $LIST_COUNT";
item "MODEL_LIST: $MODEL_LIST";
item "DEVICE_LIST: $DEVICE_LIST";
item "API_LIST: $API_LIST";

item "Dumping values to pif.json";

rm -f *Pixel*.json;
IFS=$'\n';

(( INDEX = 0 ));
while ((( INDEX++ < LIST_COUNT ))); do
  set -- $MODEL_LIST;
  MODEL="$(eval echo \${$INDEX})";
  MODEL=$(echo "$MODEL" | sed 's/ //g');

  set -- $DEVICE_LIST;
  DEVICE="$(eval echo \${$INDEX})";
  DEVICE=$(echo "$DEVICE" | sed 's/ //g');
  PRODUCT="$DEVICE"_beta;

  set -- $API_LIST;
  API="$(eval echo \${$INDEX})";
  API=$(echo "$API" | sed 's/ //g');

  NAME="$PREVIEW-$DEVICE-$MODEL";
  MODEL=$(echo "$MODEL" | sed 's/_/ /g');
  echo "NAME: $NAME, API: $API";
    
  EX=$(echo " $EX_DEVICES_LIST " | grep -o " $DEVICE ");
  if [ -z "$EX" ]; then
    sec_patch="$SEC_PATCH";
    id="$ID";
    incremental="$INCREMENTAL";
  else
    sec_patch="$EX_SEC_PATCH";
    id="$EX_ID";
    incremental="$EX_INCREMENTAL";
    NAME="_$NAME";
  fi
  item "INDEX: $INDEX, NAME: $NAME, MODEL: $MODEL, DEVICE: $DEVICE, PRODUCT: $PRODUCT";
  item "RELEASE: $RELEASE, ID: $id, INCREMENTAL: $incremental, SECURITY_PATCH: $sec_patch";

  cat <<EOF | tee pif.json;
{
  "MANUFACTURER": "Google",
  "MODEL": "$MODEL",
  "FINGERPRINT": "google/$PRODUCT/$DEVICE:$RELEASE/$id/$incremental:user/release-keys",
  "PRODUCT": "$PRODUCT",
  "DEVICE": "$DEVICE",
  "SECURITY_PATCH": "$sec_patch",
  "DEVICE_INITIAL_SDK_INT": "$API"
}
EOF

  item "Converting pif.json to custom.pif.json with migrate.sh:";
  rm -f custom.pif.json;
  sh ./migrate.sh -i -f -a pif.json;

  sed -i "s;};\n  // Name: $NAME\n  // Beta Released: $BETA_REL_DATE\n  // Estimated Expiry: $BETA_EXP_DATE\n};" custom.pif.json;
  mv custom.pif.json "$NAME-custom.pif.json";
done;

PIXEL_BETA="Pixel-$PREVIEW";
PIXEL_BETA_DIR="$DIR/$PIXEL_BETA";
PIXEL_BETA_LIST="_$PIXEL_BETA-List.txt";
item "Creating $PIXEL_BETA_LIST:";
rm -f "$PIXEL_BETA_LIST";
item "$(date +%c): generated $LIST_COUNT custom.pif.json files";
ls *Pixel*.json | tee "$PIXEL_BETA_LIST";

item "Moving to $PIXEL_BETA_DIR";
if [  ! -d "$PIXEL_BETA_DIR" ]; then
  mkdir "$PIXEL_BETA_DIR";
fi
rm -f "$PIXEL_BETA_DIR/*Pixel*.pif.json";
rm -f "$PIXEL_BETA_DIR/*Pixel*-List.txt";
mv *Pixel*.json "$PIXEL_BETA_DIR";
mv "$PIXEL_BETA_LIST" "$PIXEL_BETA_DIR";
rm -f pif.json;
