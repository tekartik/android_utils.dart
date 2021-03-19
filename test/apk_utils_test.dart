@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library apk_utils_test;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';

void main() => defineTests();

String inFolder = join('test', 'data');
String outFolder = join(inFolder, 'tmp');

/// Apk for testing
var testAppkFilePath = join(inFolder, 'app-release.apk');

void defineTests() {
  group('apk_utils', () {
    test('public', () {
      // ignore: unnecessary_statements
      ApkInfo;
    });
    group('aapt', () {
      test('getApkInfo', () async {
        var apkInfo = (await getApkInfo(join(inFolder, 'app-release.apk'),
            verbose: true))!;
        expect(apkInfo.name, 'com.tekartik.miniexp');
        expect(apkInfo.versionCode, '2');
        expect(apkInfo.versionName, '1.0.1');
      });

      test('nameIt', () async {
        var apkFilePath = join(inFolder, 'app-release.apk');
        await nameApk(apkFilePath,
            outFolderPath: join(outFolder, joinAll(testDescriptions)));
      });
    }, skip: !aaptSupported);
  });
}
