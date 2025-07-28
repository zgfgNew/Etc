ECHO OFF
CLS

adb wait-for-device devices
PAUSE

ECHO Install YouTube
adb install-multiple yt\base.apk yt\split_config.arm64_v8a.apk yt\split_config.en.apk yt\split_config.xxhdpi.apk
PAUSE

ECHO Check that YouTube is installed
adb shell pm list packages | adb shell grep youtube
PAUSE
