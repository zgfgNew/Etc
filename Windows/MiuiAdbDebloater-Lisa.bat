REM ## Lisa Xiaomi.eu HyperOS_2.0.6.0 A14:

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

ECHO Disable Android Updater
adb shell pm uninstall -k --user 0 com.android.updater
PAUSE

ECHO Disable Android Email
adb shell pm uninstall -k --user 0 com.android.email
PAUSE

ECHO Disable MIUI Analytics (Not present)
REM adb shell pm uninstall -k --user 0 com.miui.analytics
PAUSE

ECHO Disable Miui Ads (Not present)
REM adb shell pm uninstall -k --user 0 com.miui.msa.global
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

ECHO Disable Yellow Page (Not present)
REM adb shell pm uninstall -k --user 0 com.miui.yellowpage
PAUSE

ECHO Disable GetApps (Not present)
REM adb shell pm uninstall -k --user 0 com.xiaomi.mipicks
PAUSE

ECHO Disable App Vault (Not present)
REM adb shell pm uninstall -k --user 0 com.mi.globalminusscreen
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

ECHO Disable IMS
adb shell pm uninstall -k --user 0 org.codeaurora.ims
PAUSE

ECHO Disable Mi Link
adb shell pm uninstall -k --user 0 com.milink.service
PAUSE

ECHO Disable Xiaomi Sim Activate Service
adb shell pm uninstall -k --user 0 com.xiaomi.simactivate.service
PAUSE

ECHO Disable Mi Mover
adb shell pm uninstall -k --user 0 com.miui.huanji
PAUSE

ECHO Disable Mi Share
adb shell pm uninstall -k --user 0 com.miui.mishare.connectivity
PAUSE

ECHO Disable Mi Game Center (Not present)
adb shell pm uninstall -k --user 0 com.xiaomi.glgm
PAUSE

ECHO Disable Mi Game Service (Not present)
REM adb shell pm uninstall -k --user 0 com.xiaomi.migameservice
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

ECHO Disable Weather (Keep for now)
adb shell pm uninstall -k --user 0 com.miui.weather2
PAUSE

ECHO Personal Safety (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.apps.safetyhub
PAUSE

ECHO Disable Touch Assistant (Quick ball)
adb shell pm uninstall -k --user 0 com.miui.touchassistant
PAUSE

ECHO Disable Wallpaper Carousel
REM adb shell pm uninstall -k --user 0 com.miui.android.fashiongallery
adb shell pm uninstall -k --user 0 com.mfashiongallery.emag
PAUSE

ECHO Disable Miui Notes (Keep for now)
REM adb shell pm uninstall -k --user 0 com.miui.notes
PAUSE

ECHO Disable Files (Keep)
REM adb shell pm uninstall -k --user 0 com.mi.android.globalFileexplorer
REM adb shell pm uninstall -k --user 0 com.android.fileexplorer
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

ECHO Disable Mi Health
adb shell pm uninstall -k --user 0 package:com.mi.health
PAUSE

ECHO Disable Device Health Services (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.apps.turbo
PAUSE

ECHO Disable SIM Toolkit
adb shell pm uninstall -k --user 0 com.android.stk
PAUSE

ECHO Disable Browser
adb shell pm uninstall -k --user 0 com.android.browser
PAUSE

ECHO Disable Partner Bookmarks (Not present)
REM adb shell pm uninstall -k --user 0 com.android.bookmarkprovider
REM adb shell pm uninstall -k --user 0 com.android.providers.partnerbookmarks
PAUSE

ECHO Disable Android Package Installer (Mi Package Installer present)
adb shell pm uninstall -k --user 0 com.android.packageinstaller
PAUSE

ECHO Disable Partner Bookmarks
adb shell pm uninstall -k --user 0 com.google.android.partnersetup
PAUSE

ECHO Disable DT TSC (Not present)
REM adb shell pm uninstall -k --user 0 de.telekom.tsc
PAUSE

ECHO Disable DayDreams (Not present)
REM adb shell pm uninstall -k --user 0 com.android.dreams.basic
REM adb shell pm uninstall -k --user 0 com.android.dreams.phototable													   
PAUSE

ECHO Disable Android Auto
adb shell pm uninstall -k --user 0 com.google.android.projection.gearhead
PAUSE

ECHO Disable Accessability Suite
adb shell pm uninstall -k --user 0 com.google.android.marvin.talkback
PAUSE

ECHO Disable Google (Keep)
REM adb shell pm uninstall -k --user 0 com.google.android.googlequicksearchbox
PAUSE

ECHO Disable Digital Wellbeing (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.apps.wellbeing
PAUSE

ECHO Disable Facebook (Not present)
REM adb shell pm uninstall -k --user 0 com.facebook.appmanager
REM adb shell pm uninstall -k --user 0 com.facebook.system
REM adb shell pm uninstall -k --user 0 com.facebook.services
PAUSE

ECHO Disable Google One (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.apps.subscriptions.red
PAUSE

ECHO Disable Cne App
adb shell pm uninstall -k --user 0 com.qualcomm.qti.cne
PAUSE

ECHO Disable Google Meet (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.apps.tachyon
PAUSE

ECHO Disable Google Play Music (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.music
PAUSE

ECHO Disable Google TV (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.videos
PAUSE

ECHO Disable Google Photos (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.apps.photos
PAUSE

ECHO Disable GMail
adb shell pm uninstall -k --user 0 com.google.android.gm
PAUSE

ECHO Booking.com (Keep)
REM adb shell pm uninstall -k --user 0 com.booking
PAUSE

ECHO Disable Google Calendar
REM adb shell pm uninstall -k --user 0 com.google.android.calendar
adb shell pm uninstall -k --user 0 com.android.calendar
PAUSE

ECHO Disable YouTube (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.youtube
PAUSE

ECHO Disable YouTube Music (Not present)
REM adb shell pm uninstall -k --user 0 com.google.android.youtube.music
PAUSE

ECHO Disable Android System SafetyCore
adb shell pm uninstall -k --user 0 com.google.android.safetycore
PAUSE

ECHO List disabled packages
adb shell pm list packages -d
REM package: com.mi.global.shop
REM package: com.google.android.contacts
PAUSE

ECHO List uninstalled packages
adb shell pm list packages -u
REM diff only vs adb shell pm list packages
package:com.android.egg
package:com.android.email
package:com.android.stk
package:com.google.android.partnersetup
package:com.google.android.projection.gearhead
package:com.google.android.feedback
package:org.codeaurora.ims
package:com.miui.bugreport
package:com.google.android.marvin.talkback
package:com.android.traceur
package:com.mi.health
package:com.android.packageinstaller
package:com.milink.service
package:com.miui.huanji
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
