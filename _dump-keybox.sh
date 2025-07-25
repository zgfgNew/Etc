#!/system/bin/sh

# If using Termux: Remove the first hash below and move the line to the top instead of the existing first line
##!/data/data/com.termux/files/usr/bin/sh

# zgfg @ xda © Jan 2025- All Rights Reserved

# Helper functions
myPrint() { echo "-- $@"; }
myWarn() { echo "!!!! $@"; }
myRemove() { if [ -n "$@" -a  -f "$@" ]; then rm -f "$@"; fi; }

clean() {
# Remove temporary files
  myPrint "Removing temporary files";
  myRemove "$TMP";
  myRemove "$P7B";
  myRemove "$CER";
#  myRemove "$TXT";
#  deleteJSON="";
  if [ -n "$deleteJSON" ]; then myRemove "$JSON"; fi;
}
error() { myWarn "ERROR: $@, cannot proceed"; clean; exit 1; }

# Check for working directory
DIR=${0%/*};
if [ -z "$DIR" -o "$DIR" == "/" ]; then
  DIR="/sdcard/Download";
fi;

# Debug logging
#LogFile="$DIR/_dump-keybox.log";
if [ -n "$LogFile" ]; then
  exec 3>&1 4>&2 2>$LogFile 1>&2;
  set -x;
fi;

cd "$DIR";
myPrint "Working directory: $(pwd)";

# Check for root permissions
if [ "$USER" != "root" -a "$(whoami 2>/dev/null)" != "root" ]; then
  error "root permissions missing";
fi;

# Check for KB file to dump
LOCALKB="$DIR/keybox.xml";
if [ -n "$1" ]; then
  KB="$1";
elif [ -f "$LOCALKB" ]; then
  KB="$LOCALKB";
else
  KB="/data/adb/tricky_store/keybox.xml";
fi;

myPrint "KeyBox file: $KB";
if [ ! -f "$KB" ]; then
  error "$KB file to dump not found";
fi;

# Reformat KB
TMP="_keybox.tmp.txt";
rm -f "$TMP";
cat "$KB" | \
  sed 's!">-----BEGIN!">\n-----BEGIN!g' | \
  sed 's!CERTIFICATE-----</!CERTIFICATE-----\n</!g' | \
  sed 's!^[ \t]*!!' >> "$TMP";

if [ ! -f "$TMP" ]; then
  error "failed to reformat $KB";
fi;

# Check for OpenSSL
if [ -n $(which openssl) ]; then
  myOpenSSL() { openssl "$@"; }
elif [ -n $(which OPENSSL) ]; then
  myOpenSSL() { OPENSSL "$@"; }
else
  error "openssl executable not found";
fi;

# Convert KB to P7B format
P7B="_keybox.p7b";
rm -f "$P7B";
myOpenSSL crl2pkcs7 -nocrl -certfile "$TMP" -out "$P7B";

if [ ! -f "$P7B" ]; then
  error "failed to convert $KB to pkcs7";
fi;

# Dump KB to CER format
CER="_keybox.cer.txt";
rm -f "$CER";
myOpenSSL pkcs7 -print_certs -text -in "$P7B" -out "$CER";

if [ ! -f "$CER" ]; then
  error "failed to dump $KB";
fi;

# Extract info from KB to text file
TXT="_keybox.txt";
rm -f "$TXT";
myPrint "KeyBox file: $KB" >> "$TXT";

cat "$CER" | sed 's/^[ \t]*//' | \
  sed '/^Serial Number/N;s/:[ \t]*\n/: /' | \
  grep -Es '^Certificate:|^Serial Number:|^Issuer:|^Not After|^Subject:|^Public Key Algorithm:|CA:' | \
  sed 's/^Not After :/Not After:/' | \
  sed 's/^/  /' | sed 's/^[ ]*Certificate:/\nCERTIFICATE:/' >> "$TXT";
echo "" >> "$TXT";

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
    (( J = i ));
    myWarn "Certificate $J is AOSP type - COMMON NAME: $CN" >> "$TXT";
  fi;
done;
if (( J > 0 )); then
  echo "" >> "$TXT";
fi;

# Extract Serial Numbers
SNList=$(cat "$TXT" | grep 'Serial Number:' | \
  sed 's/^.*Serial Number://' | sed 's/(.*$//' | \
  sed 's/[ :]//g' | sed 's/0x//' | sed 's/^[0]*//');
echo "Serial Numbers:\n$SNList" >> "$TXT";
echo "" >> "$TXT";

if [ -z "$SNList" ]; then
  error "Serial Numbers not extracted";
fi;

# Check for BusyBox
if [ -z $(which busybox) ]; then
  error "busybox executable not found";
fi;
myDate() { busybox date "$@"; }
myWGet() { busybox wget "$@"; }


# Extract Not After dates
UTC=$(myDate --utc);
Epoch=$(myDate -D "$UTC" +"%s");
Year=$(myDate -D "$UTC" +"%Y");
NAList=$(cat "$TXT" | grep 'Not After:' | \
  sed 's/^.*Not After://' | sed 's/^[ ]*//' | \
  sed 's/ G.*$//' | sed 's/ /_/g');

if [ -z "$NAList" ]; then
  error "Not After dates not extracted";
fi;

# Check Not After dates
(( i = 0 )); (( K = i ));
for NA in $NAList; do
  (( i++ ));
  NA=$(echo "$NA" | sed 's/_/ /g');
  NAEpoch=$(myDate -d "$NA" +"%s");
  NAYear=$(myDate -d "$NA" +"%Y");
  if (( Year >= NAYear )) && (( Epoch > NAEpoch )); then
    (( K = i ));
    myWarn "Certificate $K has expired - NOT AFTER: $NA" >> "$TXT";
  fi;
done;
if (( K > 0 )); then
  echo "" >> "$TXT";
fi;

# Check Serial Numbers
JSON="_status.json";
if [ ! -f "$JSON" ]; then
  deleteJSON=1;
  myWGet -q -O "$JSON" --no-check-certificate --no-cache --header="Cache-Control: max-age=80" https://android.googleapis.com/attestation/status 2>&1 || error "failed to downolad revoked certificates list";
fi;

(( i = 0 )); (( L = i ));
for SN in $SNList; do
  (( i++ ));
  Revoked=$(cat "$JSON" | grep -w "$SN");
  if [ -n "$Revoked" ]; then
    (( L = i ));
    myWarn "Certificate $L is revoked - SERIAL NUMBER: $SN" >> "$TXT";
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

if (( L > 0 )); then
  myWarn "KeyBox is REVOKED" >> "$TXT";
elif (( J > 0 )); then
  myWarn "KeyBox is AOSP type" >> "$TXT";
else
  myPrint "KeyBox is not revoked" >> "$TXT";
fi;
echo "" >> "$TXT";

# Print results
cat "$TXT" | grep -v 'KeyBox file:';

clean;

# Finish debug logging
if [ -n "$LogFile" ]; then
  set +x;
  exec 1>&3 2>&4 3>&- 4>&-;
fi;
