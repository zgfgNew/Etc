#!/system/bin/bash

# Crawl recursively to dump keybox files for Tricky Store module
# zgfg @ xda © July 2025- All Rights Reserved

echo "Crawl recursively to dump keybox files for Tricky Store module\n";


FOLDERS_DEPTH="3";  # Increase for crawling deeper to subfolders 

script_path="$0";
script_path=$(dirname "$(readlink -f "$script_path")");
[ -z "$script_path" -o "$script_path" == "/" -o "$script_path" == "/data/data/com.mixplorer/cache" ] && script_path="$PWD";

kb_path="$1";
[ -z "$kb_path" -o ! -e "$kb_path" ] && kb_path="$script_path";
[ -z "$kb_path" -o ! -w "$kb_path" ] && kb_path="/sdcard/Download";

results="$kb_path/_dump-results.txt"; rm -f "$results";
echo "results=$results";
exec 4>&2 2>"$results" 3>&1 1>&2 ;

dump_kb_script="$script_path/_dump-keybox.sh";
[ ! -f "$dump_kb_script" -o ! -s "$dump_kb_script" ] && dump_kb_script="";

echo "PID=$$" | tee -a "$results";
echo "SHELL=$SHELL" | tee -a "$results";
echo "Arguments 0=$0, @=$@" | tee -a "$results";
echo "script_path=$script_path" | tee -a "$results";
echo "dump_kb_script=$dump_kb_script" | tee -a "$results";
echo "kb_path=$kb_path" | tee -a "$results";
echo "FOLDERS_DEPTH=$FOLDERS_DEPTH" | tee -a "$results";
echo "" | tee -a "$results";

(( folders = 0 )); (( dumped = 0 ));

function f_dump_kb()
{
  local keybox="$1";
#  echo "Dumping keybox: $keybox\n" | tee -a "$results";
  
  (( val = 2 ));
  [ -f "$dump_kb_script" ] && "$SHELL" "$dump_kb_script" "$keybox" && (( val = $? ));

  (( val == 0 )) && (( dumped++ ));
#  echo "Dumped keyboxes: $dumped" | tee -a "$results";
  echo "" | tee -a "$results";
}

function f_process_folder()
{
  local folder="$1";
  local list=$( ls "$folder"/*.xml 2>/dev/null );
  [ -z "$list" ] && return;

  (( folders++ ));
  for keybox in $list;
  do
#    echo "Processing keybox: $keybox" | tee -a "$results";
    [ -n "$keybox" -a -f "$keybox" -a -r "$keybox" -a -s "$keybox" ] && f_dump_kb "$keybox";
  done;
}

list=$( find "$kb_path" -maxdepth $FOLDERS_DEPTH -type d 2>/dev/null );
for folder in $list;
do
#  echo "Processing folder: $folder\n" | tee -a "$results";
  [ -n "$folder" -a -e "$folder" ] && f_process_folder "$folder";
done;

exec 1>&3 3>&- 2>&4 4>&-;
echo "Processed folders: $folders, dumped keyboxes: $dumped" | tee -a "$results";
echo "" | tee -a "$results";
exit 0;
