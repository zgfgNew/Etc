#!/system/bin/sh

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

if [ ! -f old_migrate.sh ]; then
  echo "old_migrate.sh not found";
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

# Uncomment to enable A16 Canary prints
#CANARY=1

if [ -n "$CANARY" ]; then

  # A16 CANARY Jun 3:
  RELEASE="CANARY";
  PREVIEW="A16-$RELEASE-Jun3";
  BETA_REL_DATE="2026-06-03";
  BETA_EXP_DATE="2026-07-15";

  SEC_PATCH="2026-05-05";
  ID="ZP11.260515.009";
  INCREMENTAL="15513807";

# Different parameters for exceptional devices
#  EX_DEVICES_LIST="oriole raven bluejay panther cheetah lynx tangorpro felix";
  EX_SEC_PATCH="2026-05-05";
  EX_ID="ZP11.260515.009";
  EX_INCREMENTAL="15513807";

else

  # A17 Beta 4.1:
  RELEASE="CinnamonBun";
  #RELEASE="17";
  PREVIEW="$RELEASE-QPR1-Beta4";
  #PREVIEW="A$RELEASE-Beta4.1";
  BETA_REL_DATE="2026-06-10";
  BETA_EXP_DATE="2026-07-22";

  SEC_PATCH="2026-05-05";
  ID="CP31.260522.006";
  INCREMENTAL="15591510";

# Different parameters for exceptional devices
  EX_DEVICES_LIST="oriole raven bluejay panther cheetah";
  EX_SEC_PATCH="2026-05-05";
  EX_ID="CP31.260522.006.A1";
  EX_INCREMENTAL="15591683";

fi
item "PREVIEW: $PREVIEW, BETA_REL_DATE: $BETA_REL_DATE, BETA_EXP_DATE: $BETA_EXP_DATE";

MODEL_LIST="Pixel_6 
Pixel_6_Pro 
Pixel_6a 
Pixel_7 
Pixel_7_Pro 
Pixel_7a 
Pixel_8 
Pixel_8_Pro 
Pixel_8a 
Pixel_9 
Pixel_9a 
Pixel_9_Pro 
Pixel_9_Pro_Fold 
Pixel_9_Pro_XL 
Pixel_10 
Pixel 10a 
Pixel_10_Pro 
Pixel_10_Pro_XL 
Pixel_10_Pro_Fold 
Pixel_Fold 
Pixel_Tablet ";

DEVICE_LIST="oriole  
raven 
bluejay 
panther 
cheetah 
lynx 
shiba 
husky 
akita 
tokay 
tegu 
caiman 
comet 
komodo 
frankel 
stallion 
blazer 
mustang 
rango 
felix 
tangorpro ";

LIST_COUNT="$(echo "$MODEL_LIST" | wc -l)";
item "LIST_COUNT: $LIST_COUNT";
item "MODEL_LIST: $MODEL_LIST";
item "DEVICE_LIST: $DEVICE_LIST";

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

  NAME="$PREVIEW-$DEVICE-$MODEL";
  MODEL=$(echo "$MODEL" | sed 's/_/ /g');
  echo "NAME: $NAME";
    
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
  "DEVICE_INITIAL_SDK_INT": "32"
}
EOF

  item "Converting pif.json to custom.pif.json with old_migrate.sh:";
  rm -f custom.pif.json;
  sh ./old_migrate.sh -i -f -a pif.json;

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
