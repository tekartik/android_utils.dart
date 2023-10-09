@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library apk_utils_test;

import 'dart:convert';

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/src/apk_get_sha1.dart';

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
      // ignore: unnecessary_statements
      getApkSha1;
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

  test('getApkSignInfo', () async {
    var output =
        'Signer #1 certificate SHA-1 digest: 40f1833d77c2f4e15566eaea1f87dc7a90246c48';
    expect(extractApkSignerSha1Digest(LineSplitter.split(output)),
        '40f1833d77c2f4e15566eaea1f87dc7a90246c48');
  });
}
