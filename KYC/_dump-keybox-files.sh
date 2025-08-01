#!/system/bin/bash

# Crawl recursively to dump keybox files for Tricky Store module
# zgfg @ xda © July 2025- All Rights Reserved

echo "Crawl recursively to dump keybox files for Tricky Store module\n";


FOLDERS_DEPTH="3";  # Increase for crawling deeper to subfolders 

script_path=${0%/*};
dump_path="$1"; [ -z "$dump_path" ] && dump_path="$script_path";
results="$dump_path/_keybox-files.txt"; rm -f "$results";

echo "results=$results";
exec 4>&2 3>&1 2>"$results" 1>&2 ;

dump_keybox_script="$script_path/_dump-keybox.sh";
[ ! -f "$dump_keybox_script" ] || [ ! -s "$dump_keybox_script" ] && dump_keybox_script="";

echo "PID=$$" | tee -a "$results";
echo "script_path=$script_path" | tee -a "$results";
echo "dump_path=$dump_path" | tee -a "$results";
echo "dump_keybox_script=$dump_keybox_script" | tee -a "$results";
echo "" | tee -a "$results";

(( folders = 0 )); (( dumped = 0 ));

function f_dump_keybox()
{
  local keybox="$1";
#  echo "Dumping keybox file: $keybox\n" | tee -a "$results";
  
  (( val = 2 ));
  [ -f "$dump_keybox_script" ] && bash "$dump_keybox_script" "$keybox" && (( val = $? ));

  (( val == 0 )) && (( dumped++ ));
#  echo "dumped=$dumped" | tee -a "$results";
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
#    echo "Processing keybox file: $keybox" | tee -a "$results";
    [ -n "$keybox" ] && [ -f "$keybox" ] && [ -r "$keybox" ] && [ -s "$keybox" ] && f_dump_keybox "$keybox";
  done;
}

list=$( find "$dump_path" -maxdepth $FOLDERS_DEPTH -type d 2>/dev/null );
for folder in $list;
do
#  echo "Processing folder: $folder\n" | tee -a "$results";
  [ -n "$folder" ] && [ -e "$folder" ] && f_process_folder "$folder";
done;
  
echo "Processed folders: $folders, dumped files: $dumped" | tee -a "$results";
echo "" | tee -a "$results";

exec 2>&4 1>&3 4>&- 3>&-;
