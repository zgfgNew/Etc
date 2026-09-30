#!/system/bin/bash

# Android shell script to forcefully convert old format ./*custom.pif.json to the new format ./*custom.pif.prop print files (by keeping also the original json prints)
# zgfg @ xda © Apr 2026

DIR="$0";
DIR=$( dirname "$(readlink -f "$DIR")" );

cd "$DIR";
pwd;


migrate="$DIR/new_migrate.sh";
[ ! -f "$migrate" ] || [ ! -s "$migrate" ] && migrate="/data/adb/modules/playintegrityfix/migrate.sh"
echo "migrate=$migrate";


list=$( ls *custom.pif.json 2>/dev/null );
#echo "list=$list";

for json in $list;
do
  prop=$( echo "$json" | sed 's!.json$!.prop!' );
  echo "\nConverting $json to $prop\n";
  [ -n "$json" -a -f "$json" -a -r "$json" -a -s "$json" ] && "$SHELL" "$migrate" -f -p "$json" "$prop";
done;
