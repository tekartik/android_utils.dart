@TestOn('vm')
library;

import 'dart:io';

import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:test/test.dart';

void main() {
  group('android_cmd', () {
    test('firebaseArgs', () async {
      expect(nameApkCommand(flavor: 'staging').arguments, [
        if (Platform.isWindows)
          'app\\build\\outputs\\apk\\staging\\release\\app-staging-release.apk'
        else
          'app/build/outputs/apk/staging/release/app-staging-release.apk',
      ]);
      // Android Gradle plugin 3+ output, as with a flavor
      expect(nameApkCommand().arguments, [
        if (Platform.isWindows)
          'app\\build\\outputs\\apk\\release\\app-release.apk'
        else
          'app/build/outputs/apk/release/app-release.apk',
      ]);
    });
    test('AdbTarget.adbCmd', () {
      var args = ['shell', 'ps'];
      expect(AdbTarget(serial: 'emulator-5554').adbCmd(args).arguments, [
        '-s',
        'emulator-5554',
        'shell',
        'ps',
      ]);
      // The caller's list is not modified
      expect(args, ['shell', 'ps']);
      expect(AdbTarget().adbCmd(args).arguments, ['shell', 'ps']);
    });
  });
}
