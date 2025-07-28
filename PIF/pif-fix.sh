#!/bin/sh

SPIC_Y_COORD="1000"         # Try with lower y if script fails to automatically kick "Make Play Integrity request" button in SPIC
X_COORD="500"               # Should fit for all YASNAC, SPIC, TB-Checker and PI API Checker
PI_WAIT_VERDICT="10"        # Play Integrity verdict usually returns in 5-6 seconds, but if you decrease and verdict arrives later, script will miss to read

spic="com.henrikherzig.playintegritychecker"
gms="com.google.android.gms.unstable"

module_path="/data/adb/modules/playintegrityfix"
custom_json="$module_path/custom.pif.json"
custom_bak="$custom_json.bak"

test_path=${0%/*}
spic_xml="$test_path/spic.xml"; log="$test_path/pif.log"

integrities="NO_INTEGRITY MEETS_VIRTUAL_INTEGRITY MEETS_BASIC_INTEGRITY MEETS_DEVICE_INTEGRITY MEETS_STRONG_INTEGRITY"

settings put system user_rotation 0
settings put system accelerometer_rotation 0

rm -f "$log"; rm -f "$spic_xml"
rm -f "$custom_json"; cp "$custom_bak" "$custom_json"

am start -n $spic/$spic.MainActivity >/dev/null 2>&1
sleep 2

killall $gms >/dev/null 2>&1
logcat -c
input tap $X_COORD $SPIC_Y_COORD

sleep $PI_WAIT_VERDICT
uiautomator dump "$spic_xml" >/dev/null 2>&1
am force-stop $spic >/dev/null 2>&1
logcat -d | grep PIF >> "$log"

for meets in $integrities
do
    found=$(cat "$spic_xml" | grep $meets)
    [ -n "$found" ] && echo $meets
done

rm -f "$spic_xml"

settings put system accelerometer_rotation 1
