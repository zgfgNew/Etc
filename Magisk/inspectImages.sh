#!/system/bin/sh

# Script path
#data/local/tmp/inspectImages.sh

---
# DAVINCI_V12.0.4.0_QFJEUXM

ls -l /sdcard/Download/*.img


# boot.img = QFJEUXM v12.0.4 boot.img
# Length:
# 134217728
# 0o1000000000

od -j 15724992 -N  118492736 -c /sdcard/Download/boot.img

:/ # od -j 15724992 -N  118492736 -c /sdcard/Download/boot.img
73770700 004 246 231   @ 301 207 273 216  \0  \0  \0  \0  \0  \0  \0  \0
73770720  \0  \0  \0  \0  \0  \0  \0   8  \0  \0  \0  \0  \0  \0  \0   !
73770740  \0  \0  \0  \0  \0  \0  \0 002   c   o   m   .   a   n   d   r
73770760   o   i   d   .   b   u   i   l   d   .   b   o   o   t   .   o
73771000   s   _   v   e   r   s   i   o   n  \0   1   0  \0  \0  \0  \0
73771020  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0   H
73771040  \0  \0  \0  \0  \0  \0  \0   %  \0  \0  \0  \0  \0  \0  \0  \n
73771060   c   o   m   .   a   n   d   r   o   i   d   .   b   u   i   l
73771100   d   .   b   o   o   t   .   s   e   c   u   r   i   t   y   _
73771120   p   a   t   c   h  \0   2   0   2   1   -   0   1   -   0   1
73771140  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
73771160  \0  \0  \0  \0  \0  \0  \0   H  \0  \0  \0  \0  \0  \0  \0   %
73771200  \0  \0  \0  \0  \0  \0  \0  \n   c   o   m   .   a   n   d   r
73771220   o   i   d   .   b   u   i   l   d   .   b   o   o   t   .   s
73771240   e   c   u   r   i   t   y   _   p   a   t   c   h  \0   2   0
73771260   2   1   -   0   1   -   0   1  \0  \0  \0  \0  \0  \0  \0  \0
73771300  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
*
777777700   A   V   B   f  \0  \0  \0 001  \0  \0  \0  \0  \0  \0  \0  \0
777777720  \0 357 360  \0  \0  \0  \0  \0  \0 357 360  \0  \0  \0  \0  \0
777777740  \0  \0 002 300  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
777777760  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
1000000000
:/ #

# 0o777777700
# 15725248


# long.img =QFJEUXM v12.0.4 boot.img patched by Magisk Camary v21401
# long.img patched by Magisk Camary v21401 = long.img
# Length:
# 134217728
# 0o1000000000

od -j 16123808 -N 118093920 -c /sdcard/Download/long.img

:/ # od -j 16123808 -N 118093920 -c /sdcard/Download/long.img
75403640   e   d   0   0   0   0   0   0   0   0   0   0   0   0   0   0
75403660   0   0   0   0   0   0   0   0   0   1   0   0   0   0   0   0
75403700   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
*
75403760   0   b   0   0   0   0   0   0   0   0   T   R   A   I   L   E
75404000   R   !   !   !  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
75404020  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
*
1000000000
:/ #

# Cut-off 118093808 trailing zeros
dd bs=1 count=16123920 if=/sdcard/Download/long.img of=/sdcard/Download/cut-long.img

od -j 16123808 -N 112 -c /sdcard/Download/cut-long.img


# short.img =QFJEUXM v12.0.4 boot.img patched by Magisk Camary v20422
# Length:
# 21417984
# 0o121550000

od -j 21415856 -N 2128 -c /sdcard/Download/short.img

# Cut-off 2032 trailing zeros
dd bs=1 count=21415952 if=/sdcard/Download/short.img of=/sdcard/Download/cut-short.img

od -j 21415856 -N 96 -c /sdcard/Download/cut-short.img

# cut-short.img patched by Magisk Camary v20422 = short.img patched by Magisk Camary v20422

# cut-short.img patched by Magisk Camary v21401 = short.img patched by Magisk Camary v21401


ls -l /sdcard/Download/cut*.img

md5sum /sdcard/Download/*.img

sha512sum /sdcard/Download/*.img

---
# Xiaomi.eu HMK20MI9T 21.2.3 v12-11

# long.img = 20,73 MB HMK20MI9T  21.2.3 boot.img from AndroidFileHost patched by Magisk 21408

# long.img = 128 MB HMK20MI9T  21.2.3 boot.img from XiaomiFirmwareUpdater patched by Magisk 21408

od -c /sdcard/Download/long.img

dd bs=1 count=21799392 if=/sdcard/Download/long.img of=/sdcard/Download/cut-long.img

od -j  21799360 -c /sdcard/Download/cut-long.img

# Tested with cut-long.img and everything works as with short.img (although, same size but different checksums)



od -j 21322272 -N 118093920 -c /sdcard/Download/long.img