# To force Core Only mode  (no modules), access to /data/cache needed
adb shell su -c touch /cache/.disable_magisk

# To disable or remove Magisk morule, access to /data needed
adb shell su -c touch /data/adb/modules/<module folder>/disable
adb shell su -c touch /data/adb/modules/<module folder>/remove

# To remove all Magisk modules (not working on Xiaomi Mi 9T)
adb wait-for-device shell magisk --remove-modules

---

Enter to Android Safe mode (press and keep pressing Vol- once the phone started to boot), then reboot to (standard) Android mode
- did not trigger Magisk to boot to the Core only mode (Xiaomi Mi 9T)
- Android Safe mode screws up Home screen icons, LSPosed and so
