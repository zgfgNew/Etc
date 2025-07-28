REM For TWRP
REM Dumping to Internal memory
REM Type commands one by one
dd if=/dev/block/bootdevice/by-name/boot_a of=/sdcard/boot_a.img
dd if=/dev/block/bootdevice/by-name/boot_b of=/sdcard/boot_b.img
dd if=/dev/block/bootdevice/by-name/persist of=/sdcard/persist.img
dd if=/dev/block/bootdevice/by-name/persistbak of=/sdcard/persistbak.img
dd if=/dev/block/sdf of=/sdcard/sdf.bin

REM For Terminal Emulator
REM Type commands one by one
su
REM Grant root for TE
REM Same dd commands as for TWRP, dumping to Internal memory

REM For ADB
REM Type commands one by one
ECHO on
adb wait-for-device devices
adb shell
su
REM Grant root for ADB
REM Same dd commands as for TWRP, dumping to Internal memory
