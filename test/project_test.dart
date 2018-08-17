@TestOn("vm")
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library apk_utils_test;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/project.dart';

void main() => defineTests();

void defineTests() {
  group('project', () {
    test('target', () {
      expect(AndroidProject.targetToGradleTarget('app'), ':app');
      expect(AndroidProject.targetToGradleTarget('app/sub'), ':app:sub');
    });

    test('getApkPath', () {
      String androidTopPath = '.';
      AndroidProject project = new AndroidProject(androidTopPath);

      String flavor = "prod";
      String sourceApk = join(androidTopPath, 'app', 'build', 'outputs', 'apk',
          flavor, 'release', 'app-${flavor}-release.apk');
      expect(project.getApkPath(flavor: flavor), sourceApk);

      expect(
          project.getApkPath(),
          join(androidTopPath, 'app', 'build', 'outputs', 'apk', 'release',
              'app-release.apk'));
    });
  });
}
