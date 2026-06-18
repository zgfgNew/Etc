#!/bin/sh

# Crawl recursively and test custom JSON files for PIF module,
# Copywright by zgfg @ xda, 2024 - 

echo "Crawl recursively and test custom JSON files for PIF module\
     \nCopywright by zgfg @ xda, 2024 - \n"


FOLDERS_DEPTH="4"             # Increase for crawling deeper than to sub-sub-sub-sub-folders 

TEST_PI="TEST_PIC"            # For testing PI with Play Integrity Checker 
TEST_PI="TEST_SPIC"           # Default, for testing PI with Simple Play Integrity Checker
#TEST_PI="TEST_PICHECK"       # For testing PI with Play Integrity API Checker

# No more using these checkers:
#TEST_PI="TEST_AIC"           # For testing PI with Android Integrity Checker
#TEST_PI="TEST_IAPI"          # For testing PI with Integrity API

#MIGRATE_JSON="yes"           # Enable to pre-process JSON files by migrate.sh script from Osm0sis, migration script must be in this script's folder or in the PI Fork module's folder
#DELETE_FAILED="yes"          # Enable to automatically delete JSON files that fail to pass Device Integrity

PIF_JSON="*pif.json"          # Default, PIF JSON mask to test all *.json files
#PIF_JSON="custom.pif.json"   # PIF JSON mask to test only custom.pif.json files
PI_WAIT_VERDICT="15"          # Play Integrity verdict usually returns in 5-6 seconds, but if you decrease and verdict arrives later, script will miss to read

#DISPLAY_FACTOR_PERCENT="95"  # Low Resolution Display adjustement factor for all coordinates
DISPLAY_FACTOR_PERCENT="100"  # Default Display adjustement factor for all coordinates
#DISPLAY_FACTOR_PERCENT="115" # High Resolution Display adjustement factor for all coordinates


# Change the code beyond this line only on your own risk

X_COORD="550"                 # x coordinate for Check buttons in SPIC, PI API Checker, TB-Checker, Android Integrity Checker and Integrity API
SWIPE_Y_COORD="1560"          # y coordinate for swiping the screen

PIC_Y_COORD="980"             # y coordinate for "Check" button in PI API Checker
PIC_V_X_COORD="875"           # x coordinate for "Show Verdict" button in PI API Checker
PIC_V_Y_COORD="200"           # y coordinate for "Show Verdict" button in PI API Checker

SPIC_Y_COORD="940"            # y coordinate for "Make Play Integrity request" button in SPIC

PICHECK_Y_COORD="1545"        # y coordinate for "Check" button in PI API Checker
PICHECK_V_X_COORD="890"       # x coordinate for "Show Verdict" button in PI API Checker
PICHECK_V_Y_COORD="180"       # y coordinate for "Show Verdict" button in PI API Checker

AIC_Y_COORD="1410"            # y coordinate for "Check Device Integrity" button in Android Integrity Checker
IAPI_Y_COORD="340"            # y coordinate for "Request A Universal Integrity Token With The Cloud Project" button in Integrity API


module_path="/data/adb/modules/playintegrityfix"
custom_json="$module_path/custom.pif.json"

script_path=${0%/*}
migrate_script="$script_path/migrate.sh"
[ ! -f "$migrate_script" ] || [ ! -s "$migrate_script" ] && migrate_script="$module_path/migrate.sh"
[ ! -f "$migrate_script" ] || [ ! -s "$migrate_script" ] && migrate_script=""

test_path="$1"; [ -z "$test_path" ] && test_path="$script_path"
custom_bak="$test_path/custom.pif.bak"

results="$test_path/pif-test-results.txt"; rm -f "$results"
echo "results=$results"
echo "PID=$$" | tee -a "$results"
echo "script_path=$script_path, test_path=$test_path" | tee -a "$results"
echo "custom_json=$custom_json" | tee -a "$results"
echo "MIGRATE_JSON=$MIGRATE_JSON, migrate_script=$migrate_script, DELETE_FAILED=$DELETE_FAILED" | tee -a "$results"
echo "TEST_PI=$TEST_PI, PIF_JSON=$PIF_JSON" | tee -a "$results"
echo "" | tee -a "$results"

log="$test_path/pif.log"
pi_xml="$test_path/pi.xml"

pic="com.kblack.demo_play_integrity_api"
spic="com.henrikherzig.playintegritychecker"
picheck=gr.nikolasspyr.integritycheck
aic="com.thend.integritychecker"
iapi="com.test.integrity.api.qa.googlemanaged"

integrities="NO_INTEGRITY MEETS_VIRTUAL_INTEGRITY MEETS_BASIC_INTEGRITY MEETS_DEVICE_INTEGRITY MEETS_STRONG_INTEGRITY"

rm -f "$custom_bak"; cp "$custom_json" "$custom_bak" >/dev/null 2>&1

orient=$(settings get system user_rotation)
auto_rot=$(settings get system accelerometer_rotation)
settings put system user_rotation 0
settings put system accelerometer_rotation 0

folders="0"; tested="0"; migrated="0"; passed="0"; failed="0"; inconclusive="0"


function f_remove_file()
{
  local file="$1"
  rm -f "$file" >/dev/null 2>&1
}

function f_start_activity()
{
  local activity="$1"
  am start -n "$activity" >/dev/null 2>&1
}

function f_kill_app()
{
  local app="$1"
  am force-stop "$app" >/dev/null 2>&1
}

function f_kill_gms()
{
  logcat -c
  killall com.google.android.gms.unstable >/dev/null 2>&1
  killall com.android.vending >/dev/null 2>&1
}

function f_tap()
{
  local x_coord="$1"
  local y_coord="$2"
  
  (( x_coord = x_coord * DISPLAY_FACTOR_PERCENT / 100 ))
  (( y_coord = y_coord * DISPLAY_FACTOR_PERCENT / 100 ))
#  echo "tap x_coord=$x_coord, y_coord=$y_coord" | tee -a "$results" 

  input touchscreen tap "$x_coord" "$y_coord" >/dev/null 2>&1
}

function f_swipe()
{
  local y_coord="$1"
  (( x_coord = X_COORD * DISPLAY_FACTOR_PERCENT / 100 ))
  (( y_coord = y_coord * DISPLAY_FACTOR_PERCENT / 100 ))
#  echo "swipe x_coord=$x_coord, y_coord=$y_coord" | tee -a "$results" 

  input touchscreen swipe "$x_coord" "$y_coord" "$x_coord" "$x_coord" >/dev/null 2>&1
}

function f_dump_xml()
{
  local xml="$1"
  uiautomator dump "$xml" >/dev/null 2>&1
}

function f_read_integrities()
{
  local xml="$1"
  local raw="$2"

  if [ -n "$raw" ]; then
    local deviceInt=$(cat "$xml" | grep -o "deviceIntegrity")
    local deviceRec=$(cat "$xml" | grep -o "legacyDeviceRecognitionVerdict")
    
    [ -z "$deviceRec" ] &&  deviceRec=$(cat "$xml" | grep -o "deviceRecognitionVerdict")
    [ -z "$deviceRec" ] &&  deviceRec=$(cat "$xml" | grep -o "Device recognition verdict") 
    [ -z "$deviceInt" ] &&  deviceInt=$(cat "$xml" | grep -o "Device Integrity")

#    local unEval=$(cat "$xml" | grep -o "UNEVALUATED") 
#    echo "deviceInt=$deviceInt, deviceRec=$deviceRec, unEval=$unEval" | tee -a "$results"

    [ -z "$deviceInt" ] &&  return 0
    [ -z "$deviceRec" ] &&  echo NO_INTEGRITY | tee -a "$results" && return 1
  fi

  (( i = 0 )); (( val = i++ ))
  for meets in $integrities
  do
    found=$(cat "$xml" | grep $meets)
    [ -n "$found" ] && echo $meets | tee -a "$results" && (( val = i ))
    (( i++ ))
  done
  (( val > 0 )) && return $val

  echo NO_INTEGRITY | tee -a "$results"
  return 1
}

function f_test_pic()
{
  local json="$1"
  cp "$json" $custom_json
  f_remove_file "$log"; f_remove_file "$pi_xml"

  f_start_activity $pic/$pic.MainActivity
  sleep 2

  f_kill_gms
  f_tap $X_COORD $PIC_Y_COORD

  sleep $PI_WAIT_VERDICT
  f_tap $PIC_V_X_COORD $PIC_V_Y_COORD
  f_swipe $SWIPE_Y_COORD
  f_swipe $SWIPE_Y_COORD

  sleep 2
  f_dump_xml "$pi_xml"
  f_kill_app $pic
  logcat -d | grep -e PIF -e TrickyStore -e TEESimulator >> "$log"
  
  f_read_integrities "$pi_xml" "yes"
  (( val = $? )); return $val
}

function f_test_spic()
{
  local json="$1"
  cp "$json" $custom_json
  f_remove_file "$log"; f_remove_file "$pi_xml"

  f_start_activity $spic/$spic.MainActivity
  sleep 2

  f_kill_gms
  f_tap $X_COORD $SPIC_Y_COORD

  sleep $PI_WAIT_VERDICT
  f_dump_xml "$pi_xml"
  f_kill_app $spic
  logcat -d | grep -e PIF -e TrickyStore -e TEESimulator >> "$log"

# verdict not shown: deviceIntegrity, deviceRecognitionVerdict, etc, not available
  f_read_integrities "$pi_xml"
  (( val = $? )); return $val
}

function f_test_picheck()
{
  local json="$1"
  cp "$json" $custom_json
  f_remove_file "$log"; f_remove_file "$pi_xml"

  f_start_activity $picheck/$picheck.MainActivity
  sleep 2

  f_kill_gms
  f_tap $X_COORD $PICHECK_Y_COORD

  sleep $PI_WAIT_VERDICT
  f_tap $PICHECK_V_X_COORD $PICHECK_V_Y_COORD
  f_swipe $SWIPE_Y_COORD
  f_swipe $SWIPE_Y_COORD

  sleep 2
  f_dump_xml "$pi_xml"
  f_kill_app $picheck
  logcat -d | grep -e PIF -e TrickyStore -e TEESimulator >> "$log"
  
  f_read_integrities "$pi_xml" "yes"
  (( val = $? )); return $val
}

function f_test_aic()
{
  local json="$1"
  cp "$json" $custom_json
  f_remove_file "$log"; f_remove_file "$pi_xml"

  f_start_activity $aic/$aic.MainActivity
  sleep 2

  f_kill_gms
  f_tap $X_COORD $AIC_Y_COORD

  sleep $PI_WAIT_VERDICT
  f_swipe $SWIPE_Y_COORD
  f_swipe $SWIPE_Y_COORD
  f_swipe $SWIPE_Y_COORD
  
  sleep 2
  f_dump_xml "$pi_xml"
  f_kill_app $aic
  logcat -d | grep -e PIF -e TrickyStore -e TEESimulator >> "$log"
  
  f_read_integrities "$pi_xml" "yes"
  (( val = $? )); return $val
}

function f_test_iapi()
{
  local json="$1"
  cp "$json" $custom_json
  f_remove_file "$log"; f_remove_file "$pi_xml"

  f_start_activity $iapi/com.dynamic.integrity.MainActivity
  sleep 2

  f_kill_gms
  f_tap $X_COORD $IAPI_Y_COORD

  sleep $PI_WAIT_VERDICT
  f_swipe $SWIPE_Y_COORD
  f_swipe $SWIPE_Y_COORD
  f_swipe $SWIPE_Y_COORD
  
  sleep 2
  f_dump_xml "$pi_xml"
  f_kill_app $iapi
  logcat -d | grep -e PIF -e TrickyStore -e TEESimulator >> "$log"
  
  f_read_integrities "$pi_xml" "yes"
  (( val = $? )); return $val
}

function f_test_pi()
{
  local json="$1"; local verbose="$2"

  local prop="$(cat "$json" | grep -o '"SECURITY_PATCH"[^,}]*')"
  [ -n "$verbose" ] && [ -n "$prop" ] && echo "$prop" | tee -a "$results"

  prop="$(cat "$json" | grep -o '"\*.security_patch"[^,}]*')"
  [ -n "$prop" ] && echo "$prop" | tee -a "$results"

  prop=$(cat "$json" | grep -o '"_ORIGINAL_FIRST_API_LEVEL"[^,}]*')
  [ -n "$verbose" ] && [ -n "$prop" ] && echo "$prop" | tee -a "$results"

  prop=$(cat "$json" | grep -o '"\*api_level"[^,}]*')
  [ -n "$prop" ] && echo "$prop" | tee -a "$results"

  prop=$(cat "$json" | grep -o '"DEVICE_INITIAL_SDK_INT"[^,}]*')
  [ -n "$prop" ] && echo "$prop" | tee -a "$results"

  prop=$(cat "$json" | grep -o '"FIRST_API_LEVEL"[^,}]*')
  [ -n "$prop" ] && echo "$prop" | tee -a "$results"

  case "$TEST_PI" in
    TEST_AIC) f_test_aic "$json"
    ;;
    TEST_IAPI) f_test_iapi "$json"
    ;;
    TEST_PIC) f_test_pic "$json"
    ;;
    TEST_SPIC) f_test_spic "$json"
    ;;
    TEST_PICHECK|*) f_test_picheck "$json"
    ;;
  esac
  (( val = $? )); return $val
}

function f_migrate_json()
{
  local json="$1"; local folder="$2"

  local custom=""
  [ -f "$migrate_script" ] && sh "$migrate_script" -i -f -o -a "$json" && custom="$folder/custom.pif.json"
  [ -f "$custom" ] && mv "$custom" "$json" && (( migrated++ ))
}

function f_prep_json()
{
  local json="$1"; local folder="$2"
  
  [ -n "$MIGRATE_JSON" ] && f_migrate_json "$json" "$folder"
  
#  sed -i 's/"VNDK_VERSION"/"ignore-VNDK_VERSION"/' "$json"
}

function f_test_json()
{
  local json="$1"; local folder="$2"
  echo "$json" | tee -a "$results"
  (( tested++ ))
  
  f_prep_json "$json" "$folder"

  (( val = 0 )); local changeApi=""

#  echo "changeApi=$changeApi" | tee -a "$results"

  (( val != 1 )) && f_test_pi "$json" "yes" && (( val = $? ))
  (( val > 0 )) && (( val < 4 )) && (( failed++ ))
  (( val > 0 )) && (( val < 4 )) && [ -n "$DELETE_FAILED" ] && echo "Deleted" | tee -a "$results" && f_remove_file "$json"  

  (( val == 0 )) && echo "Inconclusive" | tee -a "$results" && (( inconclusive++ ))
  (( val >= 4 )) && (( passed++ ))
  
#  echo "tested=$tested, passed=$passed" | tee -a "$results"
#  echo "failed=$failed, inconclusive=$inconclusive" | tee -a "$results"
  echo "" | tee -a "$results"
  return $val
}

function f_test_folder()
{
  local folder="$1"
  
  local list="$( ls "$folder"/$PIF_JSON 2>/dev/null )"
  [ -z "$list" ] && return

  (( folders++ ))
  for json in $list
  do
    [ -n "$json" ] && [ -f "$json" ] && [ -r "$json" ] && [ -s "$json" ] && f_test_json "$json" "$folder"
  done
}

list="$( find "$test_path" -maxdepth $FOLDERS_DEPTH -type d 2>/dev/null )"
for folder in $list
do
  [ -n "$folder" ] && [ -e "$folder" ] && f_test_folder "$folder"
done
  
echo "folders=$folders" | tee -a "$results"
echo "tested=$tested, migrated=$migrated" | tee -a "$results"
echo "passed=$passed, failed=$failed, inconclusive=$inconclusive" | tee -a "$results"
echo "" | tee -a "$results"

f_remove_file "$custom_json"; cp "$custom_bak" "$custom_json" >/dev/null 2>&1
f_kill_gms

f_kill_app $pic; f_kill_app $spic; f_kill_app $picheck; f_kill_app $iapi; f_kill_app $aic
f_remove_file "$pi_xml"

settings put system user_rotation "$orient"
settings put system accelerometer_rotation "$auto_rot"
