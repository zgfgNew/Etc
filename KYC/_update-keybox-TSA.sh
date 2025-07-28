#!/system/bin/sh

# Hijacked by zgfg@xda.com
# Extracted and modified from TS-Advanced module r250016 (Citra-Standalone)
# To download and create a leaked KB from https://github.com/Citra-Standalone/Citra-Standalone/tree/main/bin

# Indicator
echo -e "\n=== CIT Beebox Retriever ==="

# Setting Directory
DIR="$(dirname "$(readlink -f "$0")")"
cd "$DIR" || exit 1

# Default URL (this can be overridden by the argument)
# Note: KBs from zipball must be base64 decrypted and then formatted to XML
URL="https://raw.githubusercontent.com/citra-standalone/Citra-Standalone/main/bin"
#URL="https://raw.githubusercontent.com/citra-standalone/Citra-Standalone/main/zipball/sanctuary.tar"
URL="https://raw.githubusercontent.com/citra-standalone/Citra-Standalone/main/zipball/blackbox.tar"
URL="https://raw.githubusercontent.com/citra-standalone/Citra-Standalone/main/zipball/blackbox1.tar"

# Check if a URL argument is provided
if [ -n "$1" ]; then
    URL="$1"
fi

abort() {
    echo -e "$@"
    exit 1
}

# Define cleaner
cleaner() {
    [ -f $DIR/key ] && rm -rf "$DIR/key"
#    [ -f $DIR/keybox.xml ] && rm -rf "$DIR/keybox.xml"
}

# DroidGuard Killer
killer() {
    killall -v com.google.android.gms >> /dev/null
    killall -v com.google.android.gms.unstable >> /dev/null
    killall -v com.google.android.gsf >> /dev/null
    killall -v com.google.android.apps.walletnfcrel >> /dev/null
    killall -v com.android.vending >> /dev/null
}

# Detect busybox
get_busybox() {
    BUSYBOX=""
    for potential_path in /data/adb/modules/busybox-ndk/system/*/busybox /data/adb/magisk/busybox /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox; do
        if [ -f "$potential_path" ]; then
            BUSYBOX="$potential_path"
            break  # Stop the loop after finding the first valid BusyBox
        fi
    done

    if [ -z "$BUSYBOX" ]; then
        echo "! BusyBox not found"
        exit 1  # Exit if BusyBox is not found
    fi
}

random() {
  result="Hijacked"
  echo "$result"
}

# Call the function to detect BusyBox
get_busybox

# Define wget using the detected BusyBox
wget() {
    if [ -n "$BUSYBOX" ]; then
        su -c "$BUSYBOX" wget "$@"  # Use the found BusyBox to execute wget
    else
        echo "! BusyBox is not set. Cannot define wget."
        exit 1
    fi
}

key() {
    local option_name=$1
    local option1=$2
    local option2=$3
    local result_var=$4

    echo -e "\n[ VOL+ ] = [ $option1 ]"
    echo "[ VOL- ] = [ $option2 ]"
    echo "[ POWR ] = [ ABORT ]"
    echo -e "\nYour selection for $option_name ?"

    local maxtouch=3  # Set the touch
    local touches=0  # Initialize elapsed time

    while true; do
        keys=$(getevent -lqc1)
        
        # Check for timeout
        if [ "$touches" -ge "$maxtouch" ]; then
            echo "! No response"  # Print timeout message
            cleaner
            echo "! Aborted"
            sleep 1
            echo "=== ENDED ==="
            exit 0  # Exit if power key is pressed
        fi

        if echo "$keys" | grep -q 'KEY_VOLUMEUP.*DOWN'; then
            echo "> Backup overwritten"
            # eval "$result_var=\"$option1\""  # Store the result in the provided variable
            result=1
            return 1  # Return with success status for option1
        elif echo "$keys" | grep -q 'KEY_VOLUMEDOWN.*DOWN'; then
            echo "> Backup skiped"
            # eval "$result_var=\"$option2\""  # Store the result in the provided variable
            result=0
            return 0  # Return with success status for option2
        elif echo "$keys" | grep -q 'KEY_POWER.*DOWN'; then
            echo -e "> Power key detected! Aborting..."
            cleaner
            echo "! Aborted"
            sleep 1
            echo "=== ENDED ==="
            exit 0  # Exit if power key is pressed
        fi
        sleep 1
        touches=$((touches + 1))  # Increment the elapsed time
    done
}

# Download key using the URL from argument or default
echo "- Retrieving latest key ..."
wget -q -O key --no-check-certificate "$URL" 2>&1 || curl -s -o key --insecure "$URL" 2>&1 || exit 1

# Decrypt and delete
base64 -d key > keys && sleep 1 && cat keys > key && rm keys

# Read file content
file_content=$(cat key)

# Filtering and set variable
ID=$(grep '^ID=' key | cut -d'=' -f2-)
TYPE=$(grep '^TYPE=' key | cut -d'=' -f2-)
ecdsa_key=$(echo "$file_content" | sed -n '/<Key algorithm="ecdsa">/,/<\/Key>/p')
rsa_key=$(echo "$file_content" | sed -n '/<Key algorithm="rsa">/,/<\/Key>/p')

# Getting Information
echo -e "- Getting information ~ Key: $ID"
sleep 0.5
echo "- Dumping latest key information ..."
sleep 0.5
if echo $TYPE | grep -qi "PRIVATE"; then
    echo """
===========================================
Unauthorized data leakage to the public is strictly prohibited.
Data may only be accessed and retrieved through the proper methods provided by the account owner, Citra Standalone.
Any data leakage to the public, regardless of the reason, will result in the deletion of the data and permanent denial of future access.
This is a firm prohibition for anyone granted access to this data.
===========================================
"""
fi

if echo "$ID" | grep -qi "Hardware Attestation" ; then
    ID="HW"
else
    ID="SW"
fi

# Check for missing variables
if [ -z "$ID" ]; then
    echo "! WARNING: ID not found."
    ID="UNKNOWN"
fi

if [ -z "$ecdsa_key" ]; then
    echo "! Error: ECDSA key not found in key file"
    cleaner
    exit 1
fi

if [ -z "$rsa_key" ]; then
    echo "! Warning: RSA key not found in key file"
fi

# Generate keybox.xml
if [ -d /data/adb/tricky_store ]; then
    echo "- Saving to keybox.xml ..."
    cat <<EOF > keybox.xml
<?xml version="1.0"?>
<AndroidAttestation>
<NumberOfKeyboxes>1</NumberOfKeyboxes>
<Keybox DeviceID="${ID}_$(random)">
$ecdsa_key
$rsa_key
</Keybox>
</AndroidAttestation>
# Citra-Standalone - For the BRAVE to Advance. CITraces - https://t.me/citraintegritytrick/98 - Citra, a standalone implementation, leaves a trace in IoT.
EOF
fi
    
# Clean up
cleaner
#killer
echo "=== ENDED ==="
