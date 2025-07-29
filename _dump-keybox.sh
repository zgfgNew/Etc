#!/system/bin/bash

# Android shell script _dump-keybox.sh for analyzing and dumping info from a keybox file.
# Script only reads the KB file, it does not install KB file and does not make any changes to the KB file.
 
# zgfg @ xda © Jan 2025- All Rights Reserved

# Usage on rooted phones:
#
# BusyBox and OpenSSL modules must be installed.
# Terminal app must be granted root access.
#
# Calling:
# (ba)sh ./_dump-keybox <KB-FILE>
#
# If KB-FILE not provided, it will look for the local KB file ./keybox.xml
# If local KB File not found, it will look for Tricky Store KB file /data/adb/tricky_store/keybox.file.

# MiXPlorer:
#
# Select the script in folder and take Execute from the top-right Menu.
# It will dump KB file from the same folder or the Tricky Store KB file.

# Termux:
# Root is not required but without root it cannot dump /data/adb/tricky_store/keybox.xml
#
# Install the packages:
# pkg install openssl-tool
# pkg install busybox
# pkg install wget
#
# Grant storage access:
# termux-setup-storage
# When popping-up, enable Storage access to Termux app
#
# Call with bash shell, like:
# bash ./_dump-keybox <KB-FILE>

# Public revocation json status list:
#
# If local _status.json file is not provided, script will download the status from:
# https://android.googleapis.com/attestation/status
#
# Upon checking the revocations, script will delete the downloaded status file.
# That way it forces each time downloading and using the latest available status file.
#
# It can happen that a particular Intenet connection downloads a cached version (up to a day old) of the status file.
# Try to download a newer (bigger, with additional revocations added to the bottom of the list) from another connection,
# and provide the downloaded status file as the local file renamed to _status.json
#
# In that case, script will not download but will use the provided status file.
# Also, it won't delete that given status file, it will leave it and reuse for the next dumping.

# Note:
# Script prints that the whole KB is revoked when at least one ECDSA certificate was found revoked.
# Hence, if only RSA certificates are revoked, the KB will not be printed as revoked.

# Resources:
# https://tryigit.dev/android-keybox-attestation-analysis/
# https://docs.openssl.org/3.4/man1/openssl/
# https://github.com/openssl


# Helper functions
myPrint() { echo "-- $@"; }
myWarn() { echo "!!! $@"; }
myRemove() { if [ -n "$@" -a  -f "$@" ]; then rm -f "$@"; fi; }

myClean() {
# Remove temporary files
  myPrint "Removing temporary files";
  if [ -n "$myKB" -a "$myKB" != "$KB" ]; then
    myRemove "$myKB";
  fi;
  myRemove "$TMP";
  myRemove "$P7B";
  myRemove "$CER";
#  myRemove "$TXT";
#  deleteJSON="";
  if [ -n "$deleteJSON" ]; then myRemove "$JSON"; fi;
}
myError() { myWarn "ERROR: $@, cannot proceed"; myClean; exit 1; }

# Check for working directory
PWD=$(pwd);
myPrint "Arguments 0=$0, @=$@, pwd=$PWD";
DIR="$0";
DIR=$(dirname "$(readlink -f "$DIR")");
if [ -z "$DIR" -o "$DIR" == "/" -o "$DIR" == "/data/data/com.mixplorer/cache" ]; then
  DIR="$PWD";
fi;
if [ -z "$DIR -o "$DIR" == "/"" ]; then
  DIR="/sdcard/Download";
fi;
cd "$DIR";
myPrint "Working directory: $(pwd)";

# Debug logging
#LogFile="$DIR/_dump-keybox.log";
if [ -n "$LogFile" ]; then
  exec 3>&1 4>&2 2>$LogFile 1>&2;
  set -x;
fi;

# Check for root permissions
WHOAMI="$(whoami 2>/dev/null)";
myPrint "USER=$USER, whoami=$WHOAMI";
if [ "$USER" != "root" -a "$WHOAMI" != "root" ]; then
  myWarn "root permissons not provided";
fi;

# Check for KB file to dump
LOCALKB="$DIR/keybox.xml";
if [ -n "$1" -a -f "$1" ]; then
  KB="$1";
  myKB="$KB";
elif [ -f "$LOCALKB" ]; then
  KB="$LOCALKB";
  myKB="$KB";
else
  KB="/data/adb/tricky_store/keybox.xml";
  myKB="$LOCALKB";
  su -c "cp $KB $myKB";
fi;

myPrint "KeyBox file: $KB";
if [ ! -f "$myKB" ]; then
  myError "$KB file to dump not found";
fi;

# Reformat KB
TMP="_keybox.tmp.txt";
rm -f "$TMP";
cat "$myKB" | \
  sed 's!">-----BEGIN!">\n-----BEGIN!g' | \
  sed 's!CERTIFICATE-----</!CERTIFICATE-----\n</!g' | \
  sed 's!^[ \t]*!!' >> "$TMP";

if [ ! -f "$TMP" ]; then
  myError "failed to reformat $KB";
fi;

# Check for OpenSSL
OPENSSL=$(which openssl);
myPrint "openssl=$OPENSSL";
if [ -n "$OPENSSL"  ]; then
  myOpenSSL() { "$OPENSSL" "$@"; }
else
  myError "openssl executable not found";
fi;

# Convert KB to P7B format
P7B="_keybox.p7b";
rm -f "$P7B";
myOpenSSL crl2pkcs7 -nocrl -certfile "$TMP" -out "$P7B";

if [ ! -f "$P7B" ]; then
  myError "failed to convert $KB to pkcs7";
fi;

# Dump KB to CER format
CER="_keybox.cer.txt";
rm -f "$CER";
myOpenSSL pkcs7 -print_certs -text -in "$P7B" -out "$CER";

if [ ! -f "$CER" ]; then
  myError "failed to dump $KB";
fi;

# Extract info from KB to text file
TXT="_keybox.txt";
rm -f "$TXT";
myPrint "KeyBox file: $KB" >> "$TXT";

cat "$CER" | sed 's/^[ \t]*//' | \
  sed '/^Serial Number/N;s/:[ \t]*\n/: /' | \
  grep -Es '^Certificate:|^Serial Number:|^Issuer:|^Not Before|^Not After|^Subject:|^Public Key Algorithm:|CA:' | \
  sed 's/^Not After :/Not After:/' | \
  sed 's/^/  /' | sed 's/^[ ]*Certificate:/\nCERTIFICATE:/' >> "$TXT";
echo "" >> "$TXT";

# Extract Algorithms
AlgorithmsList=$(cat "$TXT" | grep 'Public Key Algorithm:' | \
  sed 's/^.*Public Key Algorithm://' | sed 's/^[ ]*//' | sed 's/ /_/g');

if [ -z "$AlgorithmsList" ]; then
  myWarn "Public Key Algorithms not extracted" >> "$TXT";
  echo "" >> "$TXT";
fi;

# Extract Subjects
SubjectList=$(cat "$TXT" | grep 'Subject:' | \
  sed 's/^.*Subject://' | sed 's/^[ ]*//' | sed 's/ /_/g');

if [ -z "$SubjectList" ]; then
  myWarn "Subjects not extracted" >> "$TXT";
  echo "" >> "$TXT";
fi;

# Check Common Names in Subjects
(( i = 0 )); (( J = i ));
for Subject in $SubjectList; do
  (( i++ ));
  CN=$(echo "$Subject" | grep 'CN=' | \
    sed 's/^.*CN=//' | sed 's/_/ /g' | sed 's/^[ ]*//');
  AOSP=$(echo "$CN" | grep 'Android.*Software Attestation');
  if [ -n "$AOSP" ]; then
    myWarn "Certificate $i is AOSP type - COMMON NAME: $CN" >> "$TXT";
    (( J = i ));
  fi;
done;
if (( J > 0 )); then
  echo "" >> "$TXT";
fi;

# Extract Serial Numbers
SNList=$(cat "$TXT" | grep 'Serial Number:' | \
  sed 's/^.*Serial Number://' | sed 's/(.*$//' | \
  sed 's/[ :]//g' | sed 's/0x//' | sed 's/^[0]*//');
echo "Serial Numbers:" >> "$TXT";
echo "$SNList" >> "$TXT";
echo "" >> "$TXT";

if [ -z "$SNList" ]; then
  myError "Serial Numbers not extracted";
fi;

BUSYBOX=$(which busybox);
myPrint "busybox=$BUSYBOX";
if [ -n "$BUSYBOX"  ]; then
  myBusyBox() { "$BUSYBOX" "$@"; }
else
  myError "busybox executable not found";
fi;
myDate() { busybox date "$@"; }
if [ -z "$TERMUX_VERSION" ]; then
  myWGet() { "$BUSYBOX" wget "$@"; }
else
   myWGet() { wget "$@"; }
fi;

# Extract Not After dates
UTC=$(myDate --utc);
Epoch=$(myDate -D "$UTC" +"%s");
Year=$(myDate -D "$UTC" +"%Y");
NAList=$(cat "$TXT" | grep 'Not After:' | \
  sed 's/^.*Not After://' | sed 's/^[ ]*//' | \
  sed 's/ G.*$//' | sed 's/ /_/g');

if [ -z "$NAList" ]; then
  myError "Not After dates not extracted";
fi;

# Check Not After dates
(( i = 0 )); (( K = i ));
for NA in $NAList; do
  (( i++ ));
  NA=$(echo "$NA" | sed 's/_/ /g');
  NAEpoch=$(myDate -d "$NA" +"%s");
  NAYear=$(myDate -d "$NA" +"%Y");
  if (( Year >= NAYear )) && (( Epoch > NAEpoch )); then
    myWarn "Certificate $i has expired - NOT AFTER: $NA" >> "$TXT";
    (( K = i ));
  fi;
done;
if (( K > 0 )); then
  echo "" >> "$TXT";
fi;

# Check Serial Numbers
JSON="_status.json";
if [ ! -f "$JSON" ]; then
  deleteJSON=1;
  myWGet -q -O "$JSON" --no-check-certificate --no-cache --header="Cache-Control: max-age=80" https://android.googleapis.com/attestation/status 2>&1 || myError "failed to downolad revoked certificates list";
fi;

(( i = 0 )); (( L = i ));
for SN in $SNList; do
  (( i++ ));
  Revoked=$(cat "$JSON" | grep -w "$SN");
  if [ -n "$Revoked" ]; then
    myWarn "Certificate $i is revoked - SERIAL NUMBER: $SN" >> "$TXT";
    (( L = i ));
    set -- $AlgorithmsList;
    Algorithm="$(eval echo \${$i})";
    ECDSA=$(echo "$Algorithm" | grep 'id-ecPublicKey');
    if [ -n "$ECDSA" ]; then
      (( M = i ));
    fi;
  fi;
done;
if (( L > 0 )); then
  echo "" >> "$TXT";
fi;

if (( K > 0 )); then
  myWarn "KeyBox has EXPIRED" >> "$TXT";
else
  myPrint "KeyBox has not expired" >> "$TXT";
fi;

if (( M > 0 )); then
  myWarn "KeyBox is REVOKED" >> "$TXT";
elif (( J > 0 )); then
  myWarn "KeyBox is AOSP type" >> "$TXT";
else
  myPrint "KeyBox is not revoked" >> "$TXT";
fi;
echo "" >> "$TXT";

# Print results
cat "$TXT" | grep -v 'KeyBox file:';

myClean;

# Finish debug logging
if [ -n "$LogFile" ]; then
  set +x;
  exec 1>&3 2>&4 3>&- 4>&-;
fi;

exit 0;
