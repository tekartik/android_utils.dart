@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library apk_utils_test;

import 'package:dev_test/test.dart';
import 'package:tekartik_android_utils/src/aapt_badging_line_parser.dart';
import 'package:tekartik_android_utils/src/manifest_info.dart';

void main() => defineTests();

void defineTests() {
  group('main tests', () {
    test('aapt', () {
      var xmlText = '''
<?xml version='1.0' encoding='utf-8'?>
<manifest android:hardwareAccelerated="true" android:versionCode="1" android:versionName="0.1.0" package="io.bitswift.app" xmlns:android="http://schemas.android.com/apk/res/android">
    <supports-screens android:anyDensity="true" android:largeScreens="true" android:normalScreens="true" android:resizeable="true" android:smallScreens="true" android:xlargeScreens="true" />
    <uses-permission android:name="android.permission.INTERNET" />
    <application android:hardwareAccelerated="true" android:icon="@drawable/icon" android:label="@string/app_name">
        <activity android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale" android:label="@string/activity_name" android:launchMode="singleTop" android:name="CordovaApp" android:screenOrientation="portrait" android:theme="@android:style/Theme.Black.NoTitleBar" android:windowSoftInputMode="adjustResize">
            <intent-filter android:label="@string/launcher_name">
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
    <uses-sdk android:minSdkVersion="14" android:targetSdkVersion="19" />
</manifest>
''';
      var info = ManifestInfo()..fromXml(xmlText);
      expect(info.name, 'io.bitswift.app');
      expect(info.versionName, '0.1.0');
      expect(info.versionCode, '1');
    });
    test('aab', () {
      var xmlText = '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android" android:compileSdkVersion="29" android:compileSdkVersionCodename="10" android:versionCode="2" android:versionName="1.0.1" package="com.tekartik.miniexp" platformBuildVersionCode="29" platformBuildVersionName="10">
  <uses-sdk android:minSdkVersion="25" android:targetSdkVersion="29"/>
  <application android:allowBackup="true" android:icon="@mipmap/ic_launcher" android:label="@string/app_name" android:name="com.tekartik.miniexp.App" android:supportsRtl="true">
    <activity android:name="com.tekartik.miniexp.MainActivity">
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>
  </application>
</manifest>
''';
      var info = ManifestInfo()..fromXml(xmlText);
      expect(info.name, 'com.tekartik.miniexp');
      expect(info.versionName, '1.0.1');
      expect(info.versionCode, '2');
    });
  });

  group('badging_parser', () {
    test('parse', () {
      var apkInfo = parseBadgingLine(
          "package: name='com.test.app' versionCode='2' versionName='0.1' platformBuildVersionName=''");
      expect(apkInfo.name, 'com.test.app');
      expect(apkInfo.versionCode, '2');
      expect(apkInfo.versionName, '0.1');
    });
  });
}
