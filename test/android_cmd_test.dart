@TestOn('vm')
library;

import 'dart:io';

import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:test/test.dart';

void main() {
  group('android_cmd', () {
    test('firebaseArgs', () async {
      expect(nameApkCommand(flavor: 'staging').arguments, [
        Platform.isWindows
            ? 'app\\build\\outputs\\apk\\staging\\release\\app-staging-release.apk'
            : 'app/build/outputs/apk/staging/release/app-staging-release.apk'
      ]);
    });
  });
}
