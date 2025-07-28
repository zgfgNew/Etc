#!/bin/sh

FOLDERS_DEPTH="4"  # Increase for crawling deeper than to sub-sub-sub-sub-folders 

script_path=${0%/*}
test_path="$1"; [ -z "$test_path" ] && test_path="$script_path"
results="$test_path/pif-test-migrate.txt"; rm -f "$results"

echo "results=$results"
exec 4>&2 3>&1 2>"$results" 1>&2 

module_path="/data/adb/modules/playintegrityfix"
migrate_script="$script_path/migrate.sh"
[ ! -f "$migrate_script" ] && migrate_script="$module_path/migrate.sh"
[ ! -f "$migrate_script" ] && migrate_script=""

echo "script_path=$script_path" | tee -a "$results"
echo "test_path=$test_path" | tee -a "$results"
echo "migrate_script=$migrate_script" | tee -a "$results"
echo "" | tee -a "$results"

(( folders = 0 )); (( tested = 0 ))

function f_test_json()
{
  local json="$1"; local folder="$2"
  echo "$json" | tee -a "$results"

  local custom=""
  [ -f "$migrate_script" ] && custom="$folder/custom.pif.json" && sh "$migrate_script" -i "$json" >/dev/null
  [ -f "$custom" ] && mv "$custom" "$json.mig"
  
# Only for the new migrate.sh (upcoming Fork v9)
#  [ -f "$migrate_script" ] && sh "$migrate_script" "$json" "$json" >/dev/null

  (( tested++ ))
#  echo "tested=$tested" | tee -a "$results"
  echo "" | tee -a "$results"
}

function f_test_folder()
{
  local folder="$1"
  
  local list=$( ls "$folder"/*.json 2>/dev/null )
  [ -z "$list" ] && return

  (( folders++ ))
  for json in $list
  do
    [ -n "$json" ] && [ -f "$json" ] && [ -r "$json" ] && f_test_json "$json" "$folder"
  done
}

list=$( find "$test_path" -maxdepth $FOLDERS_DEPTH -type d 2>/dev/null )
for folder in $list
do
  [ -n "$folder" ] && [ -e "$folder" ] && f_test_folder "$folder"
done
  
echo "folders=$folders, tested=$tested" | tee -a "$results"
echo "" | tee -a "$results"

exec 2>&4 1>&3 4>&- 3>&-
