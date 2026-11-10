@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_android_utils/project.dart';
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  group('project', () {
    test('target', () {
      expect(AndroidProject.targetToGradleTarget('app'), ':app');
      expect(AndroidProject.targetToGradleTarget('app/sub'), ':app:sub');
      // Gradle syntax as input
      expect(AndroidProject.targetToGradleTarget(':app'), ':app');
      expect(AndroidProject.targetToGradleTarget(':app:sub'), ':app:sub');
    });

    test('getApkPath', () {
      var androidTopPath = '.';
      var project = AndroidProject(androidTopPath);

      var flavor = 'prod';
      var sourceApk = join(
        androidTopPath,
        'app',
        'build',
        'outputs',
        'apk',
        flavor,
        'release',
        'app-$flavor-release.apk',
      );
      expect(project.getApkPath(flavor: flavor), sourceApk);

      expect(
        project.getApkPath(),
        join(
          androidTopPath,
          'app',
          'build',
          'outputs',
          'apk',
          'release',
          'app-release.apk',
        ),
      );
      // The module folder, with or without flavor
      expect(
        project.getApkPath(flavor: flavor, module: 'mod'),
        join(
          androidTopPath,
          'mod',
          'build',
          'outputs',
          'apk',
          flavor,
          'release',
          'mod-$flavor-release.apk',
        ),
      );
    });

    test('buildApkCmd', () {
      var project = AndroidProject('.');
      expect(project.buildApkCmd('app').arguments, [':app:assembleRelease']);
      expect(project.buildApkCmd(':app', flavor: 'prod').arguments, [
        ':app:assembleProdRelease',
      ]);
      expect(project.buildApkCmd('app/sub').arguments, [
        ':app:sub:assembleRelease',
      ]);
    });

    test('nameApk reads the release output of the target', () async {
      var top = await Directory.systemTemp.createTemp('android_utils_name');
      try {
        // Not built: the error names the apk path of Android Gradle plugin 3+
        await expectLater(
          AndroidProject(top.path).nameApk('app'),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains(
                join(
                  'app',
                  'build',
                  'outputs',
                  'apk',
                  'release',
                  'app-release.apk',
                ),
              ),
            ),
          ),
        );
      } finally {
        await top.delete(recursive: true);
      }
    });
  });
}
