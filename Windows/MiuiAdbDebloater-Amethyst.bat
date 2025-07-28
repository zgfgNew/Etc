REM Lisa xiaomi.eu_multi_MI11LE_XM11Lite5GNE_V14.0.8.0.TKOCNXM_v14-13:

ECHO OFF
CLS

adb wait-for-device devices
REM ee7e9a0f device
PAUSE
ECHO List installed packages
adb shell pm list packages
PAUSE

ECHO List disabled packages
adb shell pm list packages -d
PAUSE

ECHO Disable XiaomiEUModule (Not present)
REM adb shell pm uninstall -k --user 0 eu.xiaomi.module.inject
PAUSE

ECHO Disable Android Email (Not present)
REM adb shell pm uninstall -k --user 0 com.android.email
PAUSE

ECHO Disable MIUI Analytics
adb shell pm uninstall -k --user 0 com.miui.analytics
PAUSE

ECHO Disable Miui Ads
adb shell pm uninstall -k --user 0 com.miui.msa.global
PAUSE

ECHO Disable Feedback
adb shell pm uninstall -k --user 0 com.miui.bugreport
PAUSE

ECHO Disable Miui Daemon (Keep) 
REM adb shell pm uninstall -k --user 0 com.miui.daemon
PAUSE

ECHO Disable Services and Feedback
adb shell pm uninstall -k --user 0 com.miui.miservice
PAUSE

ECHO Disable Yellow Page
adb shell pm uninstall -k --user 0 com.miui.yellowpage
PAUSE

ECHO Disable GetApps
adb shell pm uninstall -k --user 0 com.xiaomi.mipicks
PAUSE

ECHO Disable App Vault
adb shell pm uninstall -k --user 0 com.mi.globalminusscreen
PAUSE

ECHO Disable MiCredit (Not present)
REM adb shell pm uninstall -k --user 0 com.micredit.in
PAUSE

ECHO Disable PaymentService
adb shell pm uninstall -k --user 0 com.xiaomi.payment
PAUSE

ECHO Disable Mi Pay (Not present)
REM adb shell pm uninstall -k --user 0 com.mipay.wallet.in
PAUSE

ECHO Disable IMS (Keep !)
REM adb shell pm uninstall -k --user 0 org.codeaurora.ims
PAUSE

ECHO Disable Mi Link
adb shell pm uninstall -k --user 0 com.milink.service
PAUSE

ECHO Disable Xiaomi Sim Activate Service
adb shell pm uninstall -k --user 0 com.xiaomi.simactivate.service
PAUSE

ECHO Disable Mi Mover (Not present)
REM adb shell pm uninstall -k --user 0 com.miui.huanji
PAUSE

ECHO Disable Mi Share
adb shell pm uninstall -k --user 0 com.miui.mishare.connectivity
PAUSE

ECHO Disable Mi Game Center
adb shell pm uninstall -k --user 0 com.xiaomi.glgm
PAUSE

ECHO Disable Mi Game Service
adb shell pm uninstall -k --user 0 com.xiaomi.migameservice
PAUSE

ECHO Disable Mi Play (Not present)
REM adb shell pm uninstall -k --user 0 com.xiaomi.miplay_client
PAUSE

ECHO Disable Uce Shim (Not present)
REM adb shell pm uninstall -k --user 0 com.qualcomm.qti.uceShimService
PAUSE

ECHO Disable Quick Apps (Not present)
REM adb shell pm uninstall -k --user 0 com.miui.hybrid
REM adb shell pm uninstall -k --user 0 com.miui.hybrid.accessory
PAUSE

ECHO Disable Catch Log
adb shell pm uninstall -k --user 0 com.bsp.catchlog
PAUSE

ECHO Disable Joyose
adb shell pm uninstall -k --user 0 com.xiaomi.joyose
PAUSE

ECHO Disable Weather
adb shell pm uninstall -k --user 0 com.miui.weather2
PAUSE

ECHO Personal Safety
adb shell pm uninstall -k --user 0 com.google.android.apps.safetyhub
PAUSE

ECHO Disable Touch Assistant (Quick ball)
adb shell pm uninstall -k --user 0 com.miui.touchassistant
PAUSE

ECHO Disable Wallpaper Carousel
adb shell pm uninstall -k --user 0 com.miui.android.fashiongallery
PAUSE

ECHO Disable Miui Notes (Keep for now)
REM adb shell pm uninstall -k --user 0 com.miui.notes
PAUSE

ECHO Disable File Manager (Keep)
REM adb shell pm uninstall -k --user 0 com.mi.android.globalFileexplorer
PAUSE

ECHO Disable Calculator (Keep for now)
REM adb shell pm uninstall -k --user 0 com.miui.calculator
PAUSE

ECHO Disable Easter Egg
adb shell pm uninstall -k --user 0 com.android.egg
PAUSE

ECHO Disable Market Feedback Agent
adb shell pm uninstall -k --user 0 com.google.android.feedback
PAUSE

ECHO Disable System Tracing
adb shell pm uninstall -k --user 0 com.android.traceur
PAUSE

ECHO Disable Device Health Services
adb shell pm uninstall -k --user 0 com.google.android.apps.turbo
PAUSE

ECHO Disable SIM Toolkit
adb shell pm uninstall -k --user 0 com.android.stk
PAUSE

ECHO Disable Browser
adb shell pm uninstall -k --user 0 com.android.browser
PAUSE

ECHO Disable Partner Bookmarks
adb shell pm uninstall -k --user 0 com.android.bookmarkprovider
adb shell pm uninstall -k --user 0 com.android.providers.partnerbookmarks
PAUSE

ECHO Disable Partner Bookmarks
adb shell pm uninstall -k --user 0 com.google.android.partnersetup
PAUSE

ECHO Disable DT TSC (Not present)
REM adb shell pm uninstall -k --user 0 de.telekom.tsc
PAUSE

ECHO Disable DayDreams
adb shell pm uninstall -k --user 0 com.android.dreams.basic
adb shell pm uninstall -k --user 0 com.android.dreams.phototable													   
PAUSE

ECHO Disable Android Auto (Keep)
REM adb shell pm uninstall -k --user 0 com.google.android.projection.gearhead
PAUSE

ECHO Disable Accessability Suite (Keep?)
REM adb shell pm uninstall -k --user 0 com.google.android.marvin.talkback
PAUSE

ECHO Disable Google (Keep)
REM adb shell pm uninstall -k --user 0 com.google.android.googlequicksearchbox
PAUSE

ECHO Disable Digital Wellbeing
adb shell pm uninstall -k --user 0 com.google.android.apps.wellbeing
PAUSE

ECHO Disable Facebook
adb shell pm uninstall -k --user 0 com.facebook.appmanager
adb shell pm uninstall -k --user 0 com.facebook.system
adb shell pm uninstall -k --user 0 com.facebook.services
PAUSE
ECHO Disable Google One
adb shell pm uninstall -k --user 0 com.google.android.apps.subscriptions.red
PAUSE

ECHO Disable Cne App
adb shell pm uninstall -k --user 0 com.qualcomm.qti.cne
PAUSE

ECHO Disable Google Meet (Keep)
REM adb shell pm uninstall -k --user 0 com.google.android.apps.tachyon
PAUSE

ECHO Disable Google Play Music (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.music
PAUSE

ECHO Disable Google TV
adb shell pm uninstall -k --user 0 com.google.android.videos
PAUSE

ECHO Disable Google Photos
adb shell pm uninstall -k --user 0 com.google.android.apps.photos
PAUSE

ECHO Disable GMail
adb shell pm uninstall -k --user 0 com.google.android.gm
PAUSE

ECHO Booking.com (Keep)
REM adb shell pm uninstall -k --user 0 com.booking
PAUSE

ECHO Disable Google Calendar
adb shell pm uninstall -k --user 0 com.google.android.calendar
PAUSE

ECHO Disable YouTube
adb shell pm uninstall -k --user 0 com.google.android.youtube
PAUSE

ECHO Disable YouTube Music
adb shell pm uninstall -k --user 0 com.google.android.youtube.music
PAUSE

ECHO Disable Android System SafetyCore
adb shell pm uninstall -k --user 0 com.google.android.safetycore
PAUSE

ECHO List disabled packages
adb shell pm list packages -d
REM package:com.mi.global.shop
REM package:com.google.android.contacts
PAUSE

ECHO List uninstalled packages
adb shell pm list packages -u
REM diff only vs adb shell pm list packages
package:com.miui.miservice
package:com.miui.msa.global
package:com.qualcomm.qti.cne
package:com.android.dreams.phototable
package:com.facebook.appmanager
package:com.android.bookmarkprovider
package:com.miui.touchassistant
package:com.xiaomi.joyose
package:com.google.android.gm
package:com.dti.telefonica
package:com.xiaomi.glgm
package:com.android.egg
package:com.google.android.apps.youtube.music
package:com.android.stk
package:com.google.android.partnersetup
package:com.google.android.feedback
package:com.miui.bugreport
package:com.miui.yellowpage
package:com.android.traceur
package:com.google.android.gms.supervision
package:de.telekom.tsc
package:com.milink.service
package:com.facebook.system
package:com.sfr.android.sfrjeux
package:com.android.dreams.basic
package:com.google.android.calendar
package:com.ironsource.appcloud.oobe.hutchison
package:com.altice.android.myapps
package:com.google.android.apps.wellbeing
package:com.xiaomi.mipicks
package:com.miui.analytics
package:com.miui.mishare.connectivity
package:com.xiaomi.payment
package:com.aura.oobe.vodafone
package:com.mi.globalbrowser
package:com.xiaomi.simactivate.service
package:com.mi.globalminusscreen
package:com.orange.aura.oobe
package:com.bsp.catchlog
package:com.google.android.videos
package:com.google.android.apps.bard
package:com.facebook.services
package:com.google.android.apps.safetyhub
package:com.google.android.apps.subscriptions.red
package:com.orange.update
package:com.google.android.apps.turbo
package:com.aura.oobe.deutsche
package:com.android.providers.partnerbookmarks
package:com.google.android.youtube
package:com.dti.bouyguestelecom
package:com.miui.weather2
package:com.google.android.apps.photos
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
