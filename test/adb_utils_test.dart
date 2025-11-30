@TestOn('vm')
library;

import 'dart:convert';

import 'package:process_run/which.dart';
import 'package:tekartik_android_utils/adb_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:test/test.dart';

void main() {
  group('adb_utils', () {
    setUpAll(() async {
      await initAndroidBuildEnvironment();
    });
    test('adb', () async {
      if (whichSync('adb') != null) {
        var infos = await getAdbDeviceInfos();
        // ignore: avoid_print
        print('devices: $infos');
      }
    }, skip: false);
    test('parse adb devices -l output', () {
      var output = '''
List of
emulator-5554          device product:sdk_gphone_x86 model:Android_SDK_built_for_x86 device:generic_x86 transport_id:1
''';
      var lines = LineSplitter.split(output).toList();
      var infos = adbDeviceInfosParseLines(lines);
      expect(infos.length, 1);
      var info = infos.first;
      expect(info.serial, 'emulator-5554');
    });
    //  adb -d shell dumpsys package com.tekartik.package1
    test('dumpsys parsing', () {
      var output = LineSplitter.split(adbDumpSysExample1).toList();
      var result = adbDumpsysPackageParseLines(output);
      var packageInfo = result.packageInfo!;
      expect(packageInfo.packageName, 'com.tekartik.package1');
      expect(packageInfo.versionName, '1.0.16');
      expect(packageInfo.versionCode, 20);
      expect(packageInfo.minSdkVersion, 27);
      expect(packageInfo.targetSdkVersion, 36);

      var output2 = LineSplitter.split(adbDumpSysExample2).toList();
      result = adbDumpsysPackageParseLines(output2);
      packageInfo = result.packageInfo!;
      expect(packageInfo.packageName, 'com.tekartik.package2');
      expect(packageInfo.versionName, '1.4.73');
      expect(packageInfo.versionCode, 248);
      expect(packageInfo.minSdkVersion, 26);
    });
  });
}

var adbDumpSysExample1 = r'''
Receiver Resolver Table:
  Non-Data Actions:
      androidx.profileinstaller.action.SAVE_PROFILE:
        2f30bd4 com.tekartik.package1/androidx.profileinstaller.ProfileInstallReceiver filter f34c3
          Action: "androidx.profileinstaller.action.SAVE_PROFILE"
      androidx.profileinstaller.action.INSTALL_PROFILE:
        2f30bd4 com.tekartik.package1/androidx.profileinstaller.ProfileInstallReceiver filter 90ed17d
          Action: "androidx.profileinstaller.action.INSTALL_PROFILE"
      androidx.profileinstaller.action.SKIP_FILE:
        2f30bd4 com.tekartik.package1/androidx.profileinstaller.ProfileInstallReceiver filter 2d17872
          Action: "androidx.profileinstaller.action.SKIP_FILE"
      androidx.profileinstaller.action.BENCHMARK_OPERATION:
        2f30bd4 com.tekartik.package1/androidx.profileinstaller.ProfileInstallReceiver filter a5f1140
          Action: "androidx.profileinstaller.action.BENCHMARK_OPERATION"

Service Resolver Table:
  Non-Data Actions:
      com.google.android.wearable.action.WATCH_FACE_CONTROL:
        5de272b com.tekartik.package1/androidx.wear.watchface.control.WatchFaceControlService filter 5c7f788 permission com.google.android.wearable.permission.BIND_WATCH_FACE_CONTROL
          Action: "com.google.android.wearable.action.WATCH_FACE_CONTROL"
      android.service.wallpaper.WallpaperService:
        93c0879 com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceDefault filter fbaa9be permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        9265a1f com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceBeige filter 7c4016c permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        c6bb335 com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceBlue filter a73a3ca permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        760793b com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceDarkGreen filter 7a5c858 permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        b14db1 com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceGreen filter 9103296 permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        1536e17 com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceLightBlue filter 8db1204 permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        7dc13ed com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceOrange filter d14e222 permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        716d4b3 com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServicePink filter ef94a70 permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        77301e9 com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceRed filter 9c2fe6e permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        8a0090f com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceYellow filter f809d9c permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"
        c70d3a5 com.tekartik.package1/com.tekartik.timegaugepower.faces.PowerGaugeServiceDarkBlue filter 324937a permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"

Permissions:
  Permission [com.tekartik.package1.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION] (3f66163):
    sourcePackage=com.tekartik.package1
    uid=10057 gids=null type=0 prot=signature
    perm=Permission{847ac21 com.tekartik.package1.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION}

Registered ContentProviders:
  com.tekartik.package1/androidx.startup.InitializationProvider:
    Provider{f7c8846 com.tekartik.package1/androidx.startup.InitializationProvider}

ContentProvider Authorities:
  [com.tekartik.package1.androidx-startup]:
    Provider{f7c8846 com.tekartik.package1/androidx.startup.InitializationProvider}
      applicationInfo=ApplicationInfo{1dd5194 com.tekartik.package1}

Key Set Manager:
  [com.tekartik.package1]
      Signing KeySets: 32

Packages:
  Package [com.tekartik.package1] (da25746):
    userId=10057
    pkg=Package{361734 com.tekartik.package1}
    codePath=/data/app/~~GSfSdCYUCkDXHTY6qu0DAw==/com.tekartik.package1-fNrHlgqJDWTgDoY2Akzmgw==
    resourcePath=/data/app/~~GSfSdCYUCkDXHTY6qu0DAw==/com.tekartik.package1-fNrHlgqJDWTgDoY2Akzmgw==
    legacyNativeLibraryDir=/data/app/~~GSfSdCYUCkDXHTY6qu0DAw==/com.tekartik.package1-fNrHlgqJDWTgDoY2Akzmgw==/lib
    primaryCpuAbi=null
    secondaryCpuAbi=null
    versionCode=20 minSdk=27 targetSdk=36
    versionName=1.0.16
    splits=[base, config.fr, config.xhdpi]
    apkSigningVersion=3
    applicationInfo=ApplicationInfo{361734 com.tekartik.package1}
    flags=[ SYSTEM HAS_CODE ALLOW_CLEAR_USER_DATA UPDATED_SYSTEM_APP ALLOW_BACKUP ]
    privateFlags=[ PRIVATE_FLAG_ACTIVITIES_RESIZE_MODE_RESIZEABLE_VIA_SDK_VERSION ALLOW_AUDIO_PLAYBACK_CAPTURE PARTIALLY_DIRECT_BOOT_AWARE VENDOR PRIVATE_FLAG_ALLOW_NATIVE_HEAP_POINTER_TAGGING ]
    forceQueryable=false
    queriesPackages=[]
    queriesIntents=[Intent { act=android.support.wearable.complications.ACTION_COMPLICATION_UPDATE_REQUEST }, Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] }]
    dataDir=/data/user/0/com.tekartik.package1
    supportsScreens=[small, medium, large, xlarge, resizeable, anyDensity]
    usesOptionalLibraries:
      com.google.android.wearable
    usesLibraryFiles:
      /system/framework/com.google.android.wearable.jar
    timeStamp=2025-07-04 01:16:33
    firstInstallTime=2009-01-01 01:00:00
    lastUpdateTime=2025-07-04 01:16:34
    installerPackageName=com.android.vending
    signatures=PackageSignatures{a9ad6d1 version:3, signatures:[b76298ca], past signatures:[]}
    installPermissionsFixed=true
    pkgFlags=[ SYSTEM HAS_CODE ALLOW_CLEAR_USER_DATA UPDATED_SYSTEM_APP ALLOW_BACKUP ]
    declared permissions:
      com.tekartik.package1.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: prot=signature, INSTALLED
    requested permissions:
      android.permission.WAKE_LOCK
      com.google.android.wearable.permission.RECEIVE_COMPLICATION_DATA
      android.permission.ACCESS_NETWORK_STATE
      com.tekartik.package1.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
    install permissions:
      android.permission.ACCESS_NETWORK_STATE: granted=true
      com.tekartik.package1.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: granted=true
      android.permission.WAKE_LOCK: granted=true
    User 0: ceDataInode=2135 installed=true hidden=false suspended=false distractionFlags=0 stopped=false notLaunched=false enabled=0 instant=false virtual=false
      lastDisabledCaller: com.android.vending
      runtime permissions:
        com.google.android.wearable.permission.RECEIVE_COMPLICATION_DATA: granted=true, flags=[ GRANTED_BY_DEFAULT]

Hidden system packages:
  Package [com.tekartik.package1] (65903ba):
    userId=10057
    pkg=Package{9c941f8 com.tekartik.package1}
    codePath=/vendor/app/com.tekartik.package1
    resourcePath=/vendor/app/com.tekartik.package1
    legacyNativeLibraryDir=/vendor/app/com.tekartik.package1/lib
    primaryCpuAbi=null
    secondaryCpuAbi=null
    versionCode=15 minSdk=27 targetSdk=33
    versionName=1.0.11
    splits=[base]
    apkSigningVersion=2
    applicationInfo=ApplicationInfo{9c941f8 com.tekartik.package1}
    flags=[ SYSTEM HAS_CODE ALLOW_CLEAR_USER_DATA TEST_ONLY ALLOW_BACKUP ]
    privateFlags=[ PRIVATE_FLAG_ACTIVITIES_RESIZE_MODE_RESIZEABLE_VIA_SDK_VERSION ALLOW_AUDIO_PLAYBACK_CAPTURE PARTIALLY_DIRECT_BOOT_AWARE VENDOR PRIVATE_FLAG_ALLOW_NATIVE_HEAP_POINTER_TAGGING ]
    forceQueryable=false
    queriesPackages=[]
    queriesIntents=[Intent { act=android.support.wearable.complications.ACTION_COMPLICATION_UPDATE_REQUEST }, Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] }, Intent { act=androidx.wear.tiles.action.BIND_UPDATE_REQUESTER }]
    dataDir=/data/user/0/com.tekartik.package1
    supportsScreens=[small, medium, large, xlarge, resizeable, anyDensity]
    usesOptionalLibraries:
      com.google.android.wearable
    timeStamp=2009-01-01 01:00:00
    firstInstallTime=2009-01-01 01:00:00
    lastUpdateTime=2009-01-01 01:00:00
    signatures=PackageSignatures{a9ad6d1 version:3, signatures:[b76298ca], past signatures:[]}
    installPermissionsFixed=true
    pkgFlags=[ SYSTEM HAS_CODE ALLOW_CLEAR_USER_DATA TEST_ONLY ALLOW_BACKUP ]
    declared permissions:
      com.tekartik.package1.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: prot=signature, INSTALLED
    requested permissions:
      android.permission.WAKE_LOCK
      com.google.android.wearable.permission.RECEIVE_COMPLICATION_DATA
      com.google.android.wearable.permission.BIND_WATCH_FACE_CONTROL
      com.tekartik.package1.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
    install permissions:
      com.tekartik.package1.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: granted=true
      android.permission.WAKE_LOCK: granted=true
    User 0: ceDataInode=2135 installed=true hidden=false suspended=false distractionFlags=0 stopped=false notLaunched=false enabled=0 instant=false virtual=false
      lastDisabledCaller: com.android.vending
      runtime permissions:
        com.google.android.wearable.permission.RECEIVE_COMPLICATION_DATA: granted=true, flags=[ GRANTED_BY_DEFAULT]

Queries:
  system apps queryable: false
  queries via package name:
  queries via intent:
    com.tekartik.sysui:
      com.tekartik.package1
    com.tekartik.package1:
      com.tekartik.store.gen3
      com.google.android.apps.walletnfcrel
      com.google.android.dialer
      com.google.android.clockwork.flashlight
      com.google.android.wearable.weather
      com.google.android.contacts
      com.google.android.deskclock
      com.google.android.apps.maps
      com.google.android.apps.messaging
      com.google.android.apps.youtube.music
      com.tekartik.howto2022
      com.tekartik.bbe2022
      com.strava
      com.whatsapp
      deezer.android.app
      de.komoot.android
      com.spotify.music
      com.tekartik.chronometer2022.debug
      com.tekartik.loves.football.ucl2022.dev
      com.rayadams.wearsysinfo
  queryable via interaction:
    User 0:
      [com.android.inputdevices,com.google.android.wearable.ambient,com.android.keychain,com.android.server.telecom,com.google.clockwork.wearqxdm,com.android.wallpaperbackup,com.google.android.apps.wearable.settings,com.android.dynsystem,com.android.location.fused,com.google.android.apps.wearable.bluetooth,com.android.networkstack.inprocess,com.android.localtransport,android,com.qualcomm.qti.services.secureui,com.android.providers.settings,com.qti.diagservices,com.android.networkstack.tethering.inprocess]:
        com.tekartik.package1
      com.tekartik.package1:
        [com.android.inputdevices,com.google.android.wearable.ambient,com.android.keychain,com.android.server.telecom,com.google.clockwork.wearqxdm,com.android.wallpaperbackup,com.google.android.apps.wearable.settings,com.android.dynsystem,com.android.location.fused,com.google.android.apps.wearable.bluetooth,com.android.networkstack.inprocess,com.android.localtransport,android,com.qualcomm.qti.services.secureui,com.android.providers.settings,com.qti.diagservices,com.android.networkstack.tethering.inprocess]
        com.tekartik.sysui
        com.google.android.wearable.app

Package Changes:
  Sequence number=31
  User 0:
    seq=1, package=com.strava
    seq=3, package=com.google.android.gms
    seq=4, package=com.google.android.contacts
    seq=5, package=com.google.android.apps.youtube.music
    seq=6, package=com.whatsapp
    seq=7, package=com.google.android.apps.messaging
    seq=8, package=com.google.android.apps.maps
    seq=9, package=com.google.android.wearable.healthservices
    seq=10, package=com.spotify.music
    seq=14, package=com.google.android.apps.walletnfcrel
    seq=19, package=com.android.vending
    seq=24, package=com.tekartik.impossiblemove
    seq=25, package=com.tekartik.package2
    seq=26, package=com.tekartik.time.soccerboard
    seq=29, package=com.tekartik.package1
    seq=30, package=com.google.android.wearable.weather


Dexopt state:
  [com.tekartik.package1]
    path: /data/app/~~GSfSdCYUCkDXHTY6qu0DAw==/com.tekartik.package1-fNrHlgqJDWTgDoY2Akzmgw==/base.apk
      arm: [status=speed-profile] [reason=install-dm]


Compiler stats:
  [com.tekartik.package1]
     base.apk - 5431
''';

var adbDumpSysExample2 = r'''
Activity Resolver Table:
  Non-Data Actions:
      com.bi.tekartikdigitalwatch.CONFIG_MAIN:
        c510ca3 com.tekartik.package2/com.bi.tekartikdigitalwatch.settings.SettingsMainActivity filter 7da5359
          Action: "com.bi.tekartikdigitalwatch.CONFIG_MAIN"
          Category: "com.google.android.wearable.watchface.category.WEARABLE_CONFIGURATION"
          Category: "android.intent.category.DEFAULT"
      androidx.wear.watchface.editor.action.WATCH_FACE_EDITOR:
        c510ca3 com.tekartik.package2/com.bi.tekartikdigitalwatch.settings.SettingsMainActivity filter 96e3ba0
          Action: "androidx.wear.watchface.editor.action.WATCH_FACE_EDITOR"
          Category: "com.google.android.wearable.watchface.category.WEARABLE_CONFIGURATION"
          Category: "android.intent.category.DEFAULT"
      com.bi.tekartikdigitalwatch.CONFIG_MAIN_WITH_WIDGET_RIGHT:
        d30cb1e com.tekartik.package2/com.bi.tekartikdigitalwatch.settings.SettingsMainActivityWithWidgets$SettingsRightWidget filter 2ddcfff
          Action: "com.bi.tekartikdigitalwatch.CONFIG_MAIN_WITH_WIDGET_RIGHT"
          Category: "com.google.android.wearable.watchface.category.WEARABLE_CONFIGURATION"
          Category: "android.intent.category.DEFAULT"
      com.bi.tekartikdigitalwatch.CONFIG_MAIN_WITH_WIDGET_LEFT:
        c0b71cc com.tekartik.package2/com.bi.tekartikdigitalwatch.settings.SettingsMainActivityWithWidgets$SettingsLeftWidget filter d53cc15
          Action: "com.bi.tekartikdigitalwatch.CONFIG_MAIN_WITH_WIDGET_LEFT"
          Category: "com.google.android.wearable.watchface.category.WEARABLE_CONFIGURATION"
          Category: "android.intent.category.DEFAULT"

Receiver Resolver Table:
  Non-Data Actions:
      androidx.profileinstaller.action.SAVE_PROFILE:
        363deb8 com.tekartik.package2/androidx.profileinstaller.ProfileInstallReceiver filter 407bff7
          Action: "androidx.profileinstaller.action.SAVE_PROFILE"
      androidx.profileinstaller.action.INSTALL_PROFILE:
        363deb8 com.tekartik.package2/androidx.profileinstaller.ProfileInstallReceiver filter 9b21491
          Action: "androidx.profileinstaller.action.INSTALL_PROFILE"
      com.google.android.c2dm.intent.RECEIVE:
        21a7b2a com.tekartik.package2/com.google.firebase.iid.FirebaseInstanceIdReceiver filter 3496d1b
          Action: "com.google.android.c2dm.intent.RECEIVE"
      androidx.profileinstaller.action.SKIP_FILE:
        363deb8 com.tekartik.package2/androidx.profileinstaller.ProfileInstallReceiver filter c3d1ff6
          Action: "androidx.profileinstaller.action.SKIP_FILE"
      androidx.profileinstaller.action.BENCHMARK_OPERATION:
        363deb8 com.tekartik.package2/androidx.profileinstaller.ProfileInstallReceiver filter 3d42e64
          Action: "androidx.profileinstaller.action.BENCHMARK_OPERATION"

Service Resolver Table:
  Non-Data Actions:
      com.google.android.wearable.action.WATCH_FACE_CONTROL:
        390b6ef com.tekartik.package2/androidx.wear.watchface.control.WatchFaceControlService filter 834e5fc permission com.google.android.wearable.permission.BIND_WATCH_FACE_CONTROL
          Action: "com.google.android.wearable.action.WATCH_FACE_CONTROL"
      com.google.firebase.MESSAGING_EVENT:
        4ee6493 com.tekartik.package2/com.bi.tekartikdigitalwatch.firebase.WearFirebaseMessagingService filter 8d7ccd0
          Action: "com.google.firebase.MESSAGING_EVENT"
        d29c4c9 com.tekartik.package2/com.google.firebase.messaging.FirebaseMessagingService filter 13437ce
          Action: "com.google.firebase.MESSAGING_EVENT"
          mPriority=-500, mOrder=0, mHasStaticPartialTypes=false, mHasDynamicPartialTypes=false
      android.service.wallpaper.WallpaperService:
        cd268cd com.tekartik.package2/com.bi.tekartikdigitalwatch.faces.Weuro2025WatchFaceService filter d134582 permission android.permission.BIND_WALLPAPER
          Action: "android.service.wallpaper.WallpaperService"
          Category: "com.google.android.wearable.watchface.category.WATCH_FACE"

Permissions:
  Permission [com.tekartik.package2.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION] (56002da):
    sourcePackage=com.tekartik.package2
    uid=10090 gids=null type=0 prot=signature
    perm=Permission{c569857 com.tekartik.package2.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION}

Registered ContentProviders:
  com.tekartik.package2/androidx.startup.InitializationProvider:
    Provider{c9eee3 com.tekartik.package2/androidx.startup.InitializationProvider}
  com.tekartik.package2/com.google.firebase.provider.FirebaseInitProvider:
    Provider{b1e52f5 com.tekartik.package2/com.google.firebase.provider.FirebaseInitProvider}

ContentProvider Authorities:
  [com.tekartik.package2.firebaseinitprovider]:
    Provider{b1e52f5 com.tekartik.package2/com.google.firebase.provider.FirebaseInitProvider}
      applicationInfo=ApplicationInfo{854afd7 com.tekartik.package2}
  [com.tekartik.package2.androidx-startup]:
    Provider{c9eee3 com.tekartik.package2/androidx.startup.InitializationProvider}
      applicationInfo=ApplicationInfo{ec90c4 com.tekartik.package2}

Key Set Manager:
  [com.tekartik.package2]
      Signing KeySets: 59

Packages:
  Package [com.tekartik.package2] (833404f):
    userId=10090
    pkg=Package{307e11d com.tekartik.package2}
    codePath=/data/app/~~xqbiWjKB6B-7o9e2pctQzw==/com.tekartik.package2-st3BfMMlLpFakWOwfpm2CA==
    resourcePath=/data/app/~~xqbiWjKB6B-7o9e2pctQzw==/com.tekartik.package2-st3BfMMlLpFakWOwfpm2CA==
    legacyNativeLibraryDir=/data/app/~~xqbiWjKB6B-7o9e2pctQzw==/com.tekartik.package2-st3BfMMlLpFakWOwfpm2CA==/lib
    primaryCpuAbi=armeabi-v7a
    secondaryCpuAbi=null
    versionCode=248 minSdk=26 targetSdk=36
    versionName=1.4.73
    splits=[base, config.armeabi_v7a, config.fr, config.xhdpi]
    apkSigningVersion=3
    applicationInfo=ApplicationInfo{307e11d com.tekartik.package2}
    flags=[ HAS_CODE ALLOW_CLEAR_USER_DATA ALLOW_BACKUP ]
    privateFlags=[ PRIVATE_FLAG_ACTIVITIES_RESIZE_MODE_RESIZEABLE_VIA_SDK_VERSION ALLOW_AUDIO_PLAYBACK_CAPTURE PARTIALLY_DIRECT_BOOT_AWARE PRIVATE_FLAG_ALLOW_NATIVE_HEAP_POINTER_TAGGING ]
    forceQueryable=false
    queriesPackages=[]
    queriesIntents=[Intent { act=android.support.wearable.complications.ACTION_COMPLICATION_UPDATE_REQUEST }, Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] }]
    dataDir=/data/user/0/com.tekartik.package2
    supportsScreens=[small, medium, large, xlarge, resizeable, anyDensity]
    usesLibraries:
      com.google.android.wearable
    usesOptionalLibraries:
      wear-sdk
    usesLibraryFiles:
      /system/framework/com.google.android.wearable.jar
    timeStamp=2025-07-03 23:31:21
    firstInstallTime=2025-06-18 08:27:04
    lastUpdateTime=2025-07-03 23:31:21
    installerPackageName=com.android.vending
    signatures=PackageSignatures{a5fdf92 version:3, signatures:[2cac3db6], past signatures:[]}
    installPermissionsFixed=true
    pkgFlags=[ HAS_CODE ALLOW_CLEAR_USER_DATA ALLOW_BACKUP ]
    declared permissions:
      com.tekartik.package2.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: prot=signature, INSTALLED
    requested permissions:
      android.permission.WAKE_LOCK
      android.permission.INTERNET
      android.permission.ACCESS_NETWORK_STATE
      android.permission.VIBRATE
      com.google.android.wearable.permission.RECEIVE_COMPLICATION_DATA
      android.permission.POST_NOTIFICATIONS
      com.google.android.c2dm.permission.RECEIVE
      com.google.android.gms.permission.AD_ID
      com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE
      com.tekartik.package2.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
    install permissions:
      com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE: granted=true
      com.google.android.c2dm.permission.RECEIVE: granted=true
      android.permission.INTERNET: granted=true
      android.permission.ACCESS_NETWORK_STATE: granted=true
      android.permission.VIBRATE: granted=true
      com.google.android.gms.permission.AD_ID: granted=true
      android.permission.WAKE_LOCK: granted=true
      com.tekartik.package2.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION: granted=true
    User 0: ceDataInode=39050 installed=true hidden=false suspended=false distractionFlags=0 stopped=false notLaunched=false enabled=0 instant=false virtual=false
      lastDisabledCaller: com.android.vending
      gids=[3003]
      runtime permissions:

Queries:
  system apps queryable: false
  queries via package name:
  queries via intent:
    com.tekartik.sysui:
      com.tekartik.package2
    com.tekartik.package2:
      com.tekartik.store.gen3
      com.google.android.apps.walletnfcrel
      com.google.android.dialer
      com.google.android.clockwork.flashlight
      com.google.android.wearable.weather
      com.google.android.contacts
      com.google.android.deskclock
      com.google.android.apps.maps
      com.google.android.apps.messaging
      com.google.android.apps.youtube.music
      com.tekartik.howto2022
      com.tekartik.bbe2022
      com.strava
      com.whatsapp
      deezer.android.app
      de.komoot.android
      com.spotify.music
      com.tekartik.chronometer2022.debug
      com.tekartik.loves.football.ucl2022.dev
      com.rayadams.wearsysinfo
  queryable via interaction:
    User 0:
      [com.android.inputdevices,com.google.android.wearable.ambient,com.android.keychain,com.android.server.telecom,com.google.clockwork.wearqxdm,com.android.wallpaperbackup,com.google.android.apps.wearable.settings,com.android.dynsystem,com.android.location.fused,com.google.android.apps.wearable.bluetooth,com.android.networkstack.inprocess,com.android.localtransport,android,com.qualcomm.qti.services.secureui,com.android.providers.settings,com.qti.diagservices,com.android.networkstack.tethering.inprocess]:
        com.tekartik.package2
      [com.google.android.gsf,com.google.android.gms]:
        com.tekartik.package2
      com.tekartik.package2:
        [com.android.inputdevices,com.google.android.wearable.ambient,com.android.keychain,com.android.server.telecom,com.google.clockwork.wearqxdm,com.android.wallpaperbackup,com.google.android.apps.wearable.settings,com.android.dynsystem,com.android.location.fused,com.google.android.apps.wearable.bluetooth,com.android.networkstack.inprocess,com.android.localtransport,android,com.qualcomm.qti.services.secureui,com.android.providers.settings,com.qti.diagservices,com.android.networkstack.tethering.inprocess]
        com.tekartik.sysui
        com.google.android.wearable.app

Package Changes:
  Sequence number=32
  User 0:
    seq=1, package=com.strava
    seq=3, package=com.google.android.gms
    seq=4, package=com.google.android.contacts
    seq=5, package=com.google.android.apps.youtube.music
    seq=6, package=com.whatsapp
    seq=7, package=com.google.android.apps.messaging
    seq=8, package=com.google.android.apps.maps
    seq=9, package=com.google.android.wearable.healthservices
    seq=10, package=com.spotify.music
    seq=14, package=com.google.android.apps.walletnfcrel
    seq=19, package=com.android.vending
    seq=24, package=com.tekartik.impossiblemove
    seq=25, package=com.tekartik.package2
    seq=26, package=com.tekartik.time.soccerboard
    seq=29, package=com.tekartik.package1
    seq=31, package=com.google.android.wearable.weather


Dexopt state:
  [com.tekartik.package2]
    path: /data/app/~~xqbiWjKB6B-7o9e2pctQzw==/com.tekartik.package2-st3BfMMlLpFakWOwfpm2CA==/base.apk
      arm: [status=speed-profile] [reason=install-dm]


Compiler stats:
  [com.tekartik.package2]
     base.apk - 10624
''';
