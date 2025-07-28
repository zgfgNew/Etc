#!/bin/sh

# Crawl recursively and generate custom JSON files for PI Fork module from stock build.prop files,
# provided by zgfg @ xda

echo "Crawl recursively and generate custom.pif.json files for PI Fork module from stock build.prop files\
     \n - provided by zgfg @ xda\n"


FOLDERS_DEPTH="4"  # Increase for crawling deeper than to sub-sub-sub-sub-folders 

script_path=${0%/*}
test_path="$1"; [ -z "$test_path" ] && test_path="$script_path"
results="$test_path/pif-gen-custom-results.txt"; rm -f "$results"

echo "results=$results"
exec 4>&2 3>&1 2>"$results" 1>&2 

module_path="/data/adb/modules/playintegrityfix"
gen_script="$script_path/my_gen_pif_custom.sh"
[ ! -f "$gen_script" ] || [ ! -s "$gen_script" ] && gen_script="$module_path/my_gen_pif_custom.sh"
[ ! -f "$gen_script" ] || [ ! -s "$gen_script" ] && gen_script=""

echo "PID=$$" | tee -a "$results"
echo "script_path=$script_path" | tee -a "$results"
echo "test_path=$test_path" | tee -a "$results"
echo "gen_script=$gen_script" | tee -a "$results"
echo "" | tee -a "$results"

(( folders = 0 )); (( created = 0 ))

function f_gen_json()
{
  local folder="$1"; local build="$2"
  echo "$build" | tee -a "$results"
  
  (( val = 2 ))
  [ -f "$gen_script" ] && sh "$gen_script" "$folder" && (( val = $? ))

  (( val == 0 )) && (( created++ ))
#  echo "created=$created" | tee -a "$results"
  echo "" | tee -a "$results"
}

function f_process_folder()
{
  local folder="$1"
  
  local list=$( ls "$folder"/*build.prop 2>/dev/null )
  [ -z "$list" ] && return

  (( folders++ ))
  for build in $list
  do
    [ -n "$build" ] && [ -f "$build" ] && [ -r "$build" ] && [ -s "$build" ] && f_gen_json "$folder" "$build"
  done
}

list=$( find "$test_path" -maxdepth $FOLDERS_DEPTH -type d 2>/dev/null )
for folder in $list
do
  [ -n "$folder" ] && [ -e "$folder" ] && f_process_folder "$folder"
done
  
echo "folders=$folders, created=$created" | tee -a "$results"
echo "" | tee -a "$results"

exec 2>&4 1>&3 4>&- 3>&-
