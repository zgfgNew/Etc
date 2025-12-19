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

# Uncomment to enable A16 Canary prints
#CANARY=1

# Read RELEASE, INCREMENTAL, SECURITY_PATCH (and BETA_REL_DATE)
# https://developer.android.com/topic/generic-system-image/releases#android-gsi-16
# https://9to5google.com/2025/07/10/android-canary-channel-developer-previews/

# Pixel Factory Images Tracker
#https://t.me/pixelfactoryimagestracker

# Pixel Canary Images
#https://gist.github.com/ItzLevvie/1a82ba4b8c9e978baeea68342c1f92c5#file-readme-md

if [ -n "$CANARY" ]; then

 # A16 QPR2 CANARY Dec 8:
  RELEASE="CANARY";
  PREVIEW="A16-QPR2-$RELEASE-Dec8";
  BETA_REL_DATE="2025-12-08";
  BETA_EXP_DATE="2026-01-19";

  SECURITY_PATCH="2025-12-05";
  ID="ZP11.251121.010";
  INCREMENTAL="14518957";

else

  # A16 QPR3 Beta 1:
  RELEASE="16";
  PREVIEW="A$RELEASE-QPR3-Beta1";
  BETA_REL_DATE="2025-12-17";
  BETA_EXP_DATE="2026-01-28";

  SECURITY_PATCH="2025-12-05";
  ID="CP1.251114.006​";
  INCREMENTAL="14560987";

# Only for Pixel 7a lynx
#  SECURITY_PATCH="2025-11-05";
#  ID="CP1.251114.006.A1";
#  INCREMENTAL="14394155";

fi

item "PREVIEW: $PREVIEW, BETA_REL_DATE: $BETA_REL_DATE, BETA_EXP_DATE: $BETA_EXP_DATE";
item "RELEASE: $RELEASE, ID: $ID, INCREMENTAL: $INCREMENTAL, SECURITY_PATCH: $SECURITY_PATCH";

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

  NAME="$PREVIEW-$MODEL-$DEVICE";
  MODEL=$(echo "$MODEL" | sed 's/_/ /g');
  echo "NAME: $NAME";
  
  item "INDEX: $INDEX, NAME: $NAME, MODEL: $MODEL, DEVICE: $DEVICE, PRODUCT: $PRODUCT";
  
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

  item "Converting pif.json to custom.pif.json with old_migrate.sh:";
  rm -f custom.pif.json;
  sh ./old_migrate.sh -i -f -a pif.json;

  sed -i "s;};\n  // Name: $NAME\n  // Beta Released: $BETA_REL_DATE\n  // Estimated Expiry: $BETA_EXP_DATE\n};" custom.pif.json;
  mv custom.pif.json "$NAME-custom.pif.json";
done;

PIXEL_BETA_LIST="Pixel-$PREVIEW-List.txt";
item "Creating $PIXEL_BETA_LIST:";
rm -f "$PIXEL_BETA_LIST";
item "$(date +%c): generated $LIST_COUNT custom.pif.json files";
ls *Pixel*.json | tee "$PIXEL_BETA_LIST";

rm -f pif.json;
