#!/system/bin/sh

# Hijacked by zgfg@xda 241207, updated by osm0sis@xda
# Extracted and modified from TSAdvanced module r241207 (Citra-Standalone)
# To download and create a leaked KB from https://github.com/Citra-Standalone/Citra-Standalone/tree/main/zipball/

# Note: KBs from zipball must be base64 decrypted, and then must be formatted to XML

echo -e "\n=== CIT Beebox Retriever ==="

# Setting directory
case "$0" in
    *.sh) DIR="$0";;
    *) DIR="$(lsof -p $$ 2>/dev/null | grep -o '/.*key-TSA-.*.sh$')";;
esac
DIR=$(dirname "$(readlink -f "$DIR")")
cd "$DIR" || exit 1

# Check if --dumpraw / -d argument is provided
case $1 in
  --dumpraw|-d) DUMPRAW=1; shift;;
esac

URLS="
# AOSP KB
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/bin
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/bin

# Soft-banned KB
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/bin1

# Revoked KB - URL from customize.sh
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox1.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox2.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox3.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox4.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox5.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox6.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox7.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox8.tar
#https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/blackbox9.tar

# Leaked - hijacked URL, forcing always the leaked KB
https://raw.githubusercontent.com/Citra-Standalone/Citra-Standalone/main/zipball/sanctuary.tar
"

# Check if a URL argument is provided
[ -n "$1" ] && URLS="$1"

# Define abort
abort() {
    echo "! Error: $@"
    exit 1
}

# Define skip
skip() {
    echo "! Error: $@, skipping"
}

# Define warn
warn() {
    echo "! Warning: $@"
}

# Detect busybox
for i in /data/adb/modules/busybox-ndk/system/*/busybox /data/adb/magisk/busybox /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox; do
    if [ -f "$i" ]; then
        BUSYBOX="$i"
        break
    fi
done
[ -z "$BUSYBOX" ] && abort "BusyBox not found"

# Define wget using the detected BusyBox
wget() {
    $BUSYBOX wget "$@"
}

for URL in $(echo "$URLS" | grep -v '^#'); do

unset KEY_CONTENT ID ECDSA_KEY RSA_KEY

# Name based on GitHub URL file commit date
USER=$(echo "$URL" | cut -d/ -f4)
REPO=$(echo "$URL" | cut -d/ -f5)
BRANCH=$(echo "$URL" | cut -d/ -f6)
FILE=$(echo "$URL" | cut -d/ -f7-)
echo -e "\n> Retrieving latest $(basename "$URL" .tar) key ... \
    \n  Repo: $USER/$REPO \
    \n  Branch: $BRANCH \
    \n  File: $FILE"
DATE=$(wget -q -O - --no-check-certificate "https://api.github.com/repos/$USER/$REPO/commits?sha=$BRANCH&path=/$FILE&page=1&per_page=1" | grep -m1 -oE 'date":.*' | cut -d\  -f2 | tr -d '\"\-\:Z' | tr 'T' '_')

# Don't dump if the output filename already exists
NAME=$USER-$(basename "$URL" .tar)_$DATE-keybox.xml
[ -f $NAME ] && skip "Previously dumped" && continue

# Download key from URL, decrypt and save to variable
KEY_CONTENT="$(wget -q -O - --no-check-certificate "$URL" | grep -vE '===| |$^' | base64 -d)"
[ "$DUMPRAW" ] && echo "$KEY_CONTENT" > $USER-$(basename "$URL" .tar).raw

# Filter and set variables from key content
ID=$(echo "$KEY_CONTENT" | grep '^ID=' | cut -d= -f2-)
echo -e "> Dumping key information ... \
    \n  Key: $ID"
ECDSA_KEY=$(echo "$KEY_CONTENT" | sed -n '/<Key algorithm="ecdsa">/,/<\/Key>/p')
RSA_KEY=$(echo "$KEY_CONTENT" | sed -n '/<Key algorithm="rsa">/,/<\/Key>/p')

# Check for missing variables
[ -z "$ECDSA_KEY" ] && skip "ECDSA key not found in key data" && continue
if [ -z "$RSA_KEY" ]; then
    warn "RSA key not found in key data"
else
    RSA_KEY="\n$RSA_KEY"
fi

# Reset ID as dump date for nothing unnecessarily traceable
sleep 0.5
ID=$(date '+%Y%m%d_%H%M%S')

# Generate keybox.xml
echo "> Saving keybox.xml ..."
cat <<EOF > $NAME
<?xml version="1.0"?>
<AndroidAttestation>
<NumberOfKeyboxes>1</NumberOfKeyboxes>
<Keybox DeviceID="$ID">
$ECDSA_KEY$RSA_KEY
</Keybox>
</AndroidAttestation>
EOF

# Fix inconsistencies
echo "> Cleaning improper formatting ..."
sed -i -e 's;\\n;\n;g' -e 's;</Key></Keybox>;</Key>;' $NAME

done

echo -e "\n=== ENDED ==="
