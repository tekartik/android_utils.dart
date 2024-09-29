@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library;

import 'package:path/path.dart';
import 'package:tekartik_android_utils/project.dart';
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  group('project', () {
    test('target', () {
      expect(AndroidProject.targetToGradleTarget('app'), ':app');
      expect(AndroidProject.targetToGradleTarget('app/sub'), ':app:sub');
    });

    test('getApkPath', () {
      var androidTopPath = '.';
      var project = AndroidProject(androidTopPath);

      var flavor = 'prod';
      var sourceApk = join(androidTopPath, 'app', 'build', 'outputs', 'apk',
          flavor, 'release', 'app-$flavor-release.apk');
      expect(project.getApkPath(flavor: flavor), sourceApk);

      expect(
          project.getApkPath(),
          join(androidTopPath, 'app', 'build', 'outputs', 'apk', 'release',
              'app-release.apk'));
    });
  });
}
