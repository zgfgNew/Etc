adb wait-for-device devices
adb shell
su
input text 6610
input keyevent 66
input text 6610
input keyevent 66
input touchscreen swipe 930 880 930 380
input text 6610
exit
exit

adb wait-for-device devices
adb shell
su
input touchscreen swipe 930 880 930 380
input text 6610
exit
exit



