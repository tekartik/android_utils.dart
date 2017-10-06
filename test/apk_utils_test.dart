@TestOn("vm")
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library apk_utils_test;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/src/apk_info.dart';

void main() => defineTests();

String inFolder = join("test", "data");
String outFolder = join(inFolder, "tmp");

void defineTests() {
  group('apk_utils', () {
    test('getApkInfo', () async {
      ApkInfo apkInfo =
          await getApkInfo(join(inFolder, "app-release.apk"), verbose: true);
      expect(apkInfo.name, 'com.tekartik.miniexp');
      expect(apkInfo.versionCode, '2');
      expect(apkInfo.versionName, '1.0.1');
    });

    test('nameIt', () async {
      String apkFilePath = join(inFolder, "app-release.apk");
      await nameApk(apkFilePath,
          outFolderPath: join(outFolder, joinAll(testDescriptions)));
    });
  });
}
