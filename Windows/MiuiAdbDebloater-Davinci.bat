REM Lisa xiaomi.eu_multi_MI11LE_XM11Lite5GNE_V14.0.8.0.TKOCNXM_v14-13:

ECHO OFF
CLS

adb wait-for-device devices
PAUSE

ECHO List packages
adb shell pm list packages
PAUSE

ECHO List disabled packages
adb shell pm list packages -d
PAUSE

ECHO Disable XiaomiEUModule *
adb shell pm disable-user eu.xiaomi.module.inject
PAUSE

ECHO Disable Android Email *
adb shell pm disable-user com.android.email
PAUSE

ECHO Disable MIUI Analytics (Not present)
adb shell pm disable-user com.miui.analytics
PAUSE

ECHO Disable Miui Ads (Not present)
adb shell pm disable-user com.miui.msa.global
PAUSE

ECHO Disable Feedback *
adb shell pm disable-user com.miui.bugreport
PAUSE

ECHO Disable Miui Daemon (Keep ?!) 
REM adb shell pm disable-user com.miui.daemon
PAUSE

ECHO Disable Services and Feedback *
adb shell pm disable-user com.miui.miservice
PAUSE

ECHO Disable Yellow Page (Not present)
adb shell pm disable-user com.miui.yellowpage
PAUSE

ECHO Disable GetApps (Not present)
adb shell pm disable-user com.xiaomi.mipicks
PAUSE

ECHO Disable MiCredit (Not present)
adb shell pm disable-user com.micredit.in
PAUSE

ECHO Disable PaymentService *
adb shell pm disable-user com.xiaomi.payment
PAUSE

ECHO Disable Mi Pay (Not present)
adb shell pm disable-user com.mipay.wallet.in
PAUSE

ECHO Disable IMS
adb shell pm disable-user org.codeaurora.ims
PAUSE

ECHO Disable Mi Link
adb shell pm disable-user com.milink.service
PAUSE

ECHO Disable Xiaomi Sim Activate Service
adb shell pm disable-user com.xiaomi.simactivate.service
PAUSE

ECHO Disable Mi Mover
adb shell pm disable-user com.miui.huanji
PAUSE

ECHO Disable Mi Share
adb shell pm disable-user com.miui.mishare.connectivity
PAUSE

ECHO Disable Mi Game Service
adb shell pm disable-user com.xiaomi.migameservice
PAUSE

ECHO Disable Mi Play (Not present)
adb shell pm disable-user com.xiaomi.miplay_client
PAUSE

ECHO Disable Uce Shim (Keep?)
REM adb shell pm disable-user com.qualcomm.qti.uceShimService
PAUSE

ECHO Disable Quick Apps (Not present)
adb shell pm disable-user com.miui.hybrid
adb shell pm disable-user com.miui.hybrid.accessory
PAUSE

ECHO Disable Catch Log *
adb shell pm disable-user com.bsp.catchlog
PAUSE

ECHO Disable Joyose *
adb shell pm disable-user com.xiaomi.joyose
PAUSE

ECHO Disable Weather (Keep)
REM adb shell pm disable-user com.miui.weather
PAUSE

ECHO Disable Touch Assistant
adb shell pm disable-user com.miui.touchassistant
PAUSE

ECHO Disable Wallpaper (Not present)
REM adb shell pm disable-user com.miui.android.fashiongallery
PAUSE

ECHO Disable Miui Notes (Keep for now)
REM adb shell pm disable-user com.miui.notes
PAUSE

ECHO Disable File Manager (Keep)
REM adb shell pm disable-user com.mi.android.globalFileexplorer
PAUSE

ECHO Disable Calculator (Keep for now)
REM adb shell pm disable-user com.miui.calculator
PAUSE

ECHO Disable Easter Egg *
adb shell pm disable-user com.android.egg
PAUSE

ECHO Disable Market Feedback Agent *
adb shell pm disable-user com.google.android.feedback
PAUSE

ECHO Disable System Tracing *
adb shell pm disable-user com.android.traceur
PAUSE

ECHO Disable Device Health Services (Not present)
adb shell pm disable-user com.google.android.apps.turbo
PAUSE

ECHO Disable SIM Toolkit *
adb shell pm disable-user com.android.stk
PAUSE

ECHO Disable Browser (Not present) *
adb shell pm disable-user com.android.browser
PAUSE

ECHO Disable Partner Bookmarks (Not present)
adb shell pm disable-user com.android.bookmarkprovider
adb shell pm disable-user com.android.providers.partnerbookmarks
PAUSE

ECHO Disable Partner Bookmarks *
adb shell pm disable-user com.google.android.partnersetup
PAUSE

ECHO Disable DT TSC (Not present)
adb shell pm disable-user de.telekom.tsc
PAUSE

ECHO Disable DayDreams (Not present)
adb shell pm disable-user com.android.dreams.basic
adb shell pm disable-user com.android.dreams.phototable													   
PAUSE

ECHO Disable Android Auto (Keep) *
adb shell pm disable-user com.google.android.projection.gearhead
PAUSE

ECHO Disable Google (Keep) *
REM adb shell pm disable-user com.google.android.googlequicksearchbox
PAUSE

ECHO Disable Digital Wellbeing (Not present)
adb shell pm disable-user com.google.android.apps.wellbeing
PAUSE

ECHO Disable Facebook (Not present)
adb shell pm disable-user com.facebook.appmanager
adb shell pm disable-user com.facebook.system
adb shell pm disable-user com.facebook.services
PAUSE

ECHO Disable Google One (Keep)
adb shell pm disable-user com.google.android.apps.subscriptions.red
PAUSE

ECHO Disable Cne App *
adb shell pm disable-user com.qualcomm.qti.cne
PAUSE

ECHO Disable Google Duo (Not present)
adb shell pm disable-user com.google.android.apps.tachyon
PAUSE

ECHO Disable Google Play Music (Not present)
adb shell pm disable-user com.google.android.music
PAUSE

ECHO Disable Google Play Videos (Not present)
REM adb shell pm disable-user com.google.android.videos
PAUSE

ECHO Disable Google Photos (Keep?)
REM adb shell pm disable-user com.google.android.apps.photos
PAUSE

ECHO Disable GMail (Not present)
adb shell pm disable-user com.google.android.gm
PAUSE

ECHO Booking.com  (Not present)
REM adb shell pm disable-user com.booking
PAUSE

ECHO Disable YouTube (Keep)
REM adb shell pm disable-user com.google.android.youtube
PAUSE

ECHO List disabled packages
adb shell pm list packages -d
PAUSE

ECHO Optimize packages
adb shell cmd package bg-dexopt-job
PAUSE

EXIT


REM Semantics

ECHO Disable Google
REM adb shell pm disable-user com.google.android.googlequicksearchbox
PAUSE

ECHO Re-enable Google
REM adb shell pm enable com.google.android.googlequicksearchbox
PAUSE

ECHO Uninstall Google
REM adb shell pm uninstall -k --user 0 com.google.android.googlequicksearchbox
PAUSE

ECHO Re-install Google
REM adb shell cmd package install-existing com.google.android.googlequicksearchbox
PAUSE

EXIT
