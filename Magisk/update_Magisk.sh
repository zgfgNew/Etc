#!/system/bin/sh

# Script for updating Magisk:
# (Previous) Magisk must be already installed
# Magisk app must be updated
#
# Script will disk-dump boot image, patch and flash it back
# A/B devices are supported, script will disk-dump, patch and flash the active slot

# Boot partition
AB=$(getprop ro.boot.slot_suffix)
BOOT_PART=/dev/block/bootdevice/by-name/boot"$AB"

# Boot and patched boot images
DOWNLOAD=/sdcard/Download/
BOOT_IMG="$DOWNLOAD"boot.img
PATCHED_BOOT_IMG="$DOWNLOAD"patched-boot.img

# Magisk path
MAGISK_PATH=/data/adb/magisk/

# Disk-dump boot image to Download folder
dd if="$BOOT_PART" of="$BOOT_IMG"

# Patch the boot image and move to Download folder
"$MAGISK_PATH"boot_patch.sh "$BOOT_IMG"
mv "$MAGISK_PATH"new-boot.img "$PATCHED_BOOT_IMG"

# Flash the patched boot image
dd if="$PATCHED_BOOT_IMG" of="$BOOT_PART"

# Reboot
reboot
