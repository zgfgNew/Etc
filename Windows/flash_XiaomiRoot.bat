REM cmd
echo on
PAUSE
REM cd \adb
PAUSE

REM adb sideload xiaomi.eu_multi_HMK20MI9T_V12.5.2.0.RFJCNXM_v12-11.zip
PAUSE

adb wait-for-device devices
PAUSE
REM adb wait-for-device shell magisk --remove-modules
PAUSE

adb reboot-bootloader
PAUSE

fastboot devices
PAUSE

REM fastboot continue
REM PAUSE

fastboot getvar product
PAUSE

fastboot getvar anti
PAUSE

fastboot oem device-info
PAUSE

REM fastboot boot boot-Xiaomi.eu_HyperOS_2.0.6.0_A14.img
REM fastboot boot boot-APatch_11039-Xiaomi.eu_HyperOS_2.0.6.0_A14.img
REM fastboot boot boot-stock-davinci_EEA_V12.1.1.0.RFJEUXM_3c22137238_11.0.img
PAUSE

REM fastboot flash boot boot-Xiaomi.eu_HyperOS_2.0.6.0_A14.img
REM fastboot flash boot boot-APatch_11039-Xiaomi.eu_HyperOS_2.0.6.0_A14.img
REM fastboot flash boot boot-stock-davinci_EEA_V12.1.1.0.RFJEUXM_3c22137238_11.0.img
PAUSE

fastboot reboot
EXIT
