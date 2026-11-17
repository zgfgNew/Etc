#!/system/bin/bash

# zgfg @ xda © Jan 2026- All Rights Reserved

# Helper functions
myPrint() { echo "-- $@"; }
myWarn() { echo "!!! $@"; }
myError() { myWarn "ERROR: $@, cannot proceed"; exit -1; }

# Check for working directory
PWD=$(pwd);
myPrint "SHELL=$SHELL, pwd=$PWD";
myPrint "PATH=$PATH";
myPrint "Arguments 0=$0, 1=$1, 2=$2, @=$@";
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
#LogFile="$DIR/_compare-keyboxes.log";
if [ -n "$LogFile" ]; then
  exec 3>&1 4>&2 2>$LogFile 1>&2;
  set -x;
fi;

# Check for root permissions
WHOAMI="$(whoami 2>/dev/null)";
myPrint "USER=$USER, whoami=$WHOAMI";
if [ "$USER" != "root" -a "$WHOAMI" != "root" ]; then
  myPrint "Root permissons not provided";
fi;

# Check for KB1 file to compare
LOCALKB="$DIR/keybox.xml";
if [ -n "$1" -a -f "$1" ]; then
  KB1="$1";
elif [ -f "$LOCALKB" ]; then
  KB1="$LOCALKB";
else
  KB1="/data/adb/tricky_store/keybox.xml";
fi;
if [ ! -f "$KB1" ]; then
  myError "$KB1 file not found";
fi;
myPrint "KB1=$KB1";

# Check for KB2 file to compare
LOCALKB="$DIR/keybox1.xml";
if [ -n "$2" -a -f "$2" ]; then
  KB2="$2";
elif [ -f "$LOCALKB" ]; then
  KB2="$LOCALKB";
else
  KB2="/data/adb/tricky_store/keybox.xml";
fi;
if [ ! -f "$KB2" ]; then
  myError "$KB2 file not found";
fi;
myPrint "KB2=$KB2";

# Check if KB1 and KB2 are same files
if [[ "$KB1" == "$KB2" ]]; then
  myError "Same files $KB1 and $KB2";
fi

# Check for diff
DIFF=$(which diff);

# Check for ToyBox
TOYBOX=$(which toybox);
TOYBOXEXT=$(which toybox-ext);
if [ -n "$TOYBOXEXT" -a -x "$TOYBOXEXT" ]; then
  TOYBOX="$TOYBOXEXT";
fi;
myPrint "toybox=$TOYBOX";
if [ -n "$TOYBOX" -a -x "$TOYBOX" ]; then
  DIFF="$TOYBOX diff";
fi;

# Check for BusyBox
BUSYBOX=$(which busybox);
myPrint "busybox=$BUSYBOX";
if [ -n "$BUSYBOX" ]; then
  DIFF="$BUSYBOX diff";
fi;

if [ -n "$DIFF" ]; then
  myDiff() { $DIFF $@; }
else
  myError "diff utility not found";
fi;
myPrint "diff=$DIFF";

# Diff KB1 and KB2
myPrint diff "$KB1" "$KB2"
myDiff "$KB1" "$KB2"

# Finish debug logging
if [ -n "$LogFile" ]; then
  set +x;
  exec 1>&3 2>&4 3>&- 4>&-;
fi;

exit 0;
