@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:tekartik_android_utils/src/apk_get_sha1.dart';
import 'package:test/test.dart';

Future<void> main() async {
  await initAndroidBuildEnvironment();
  defineTests();
}

String inFolder = join('test', 'data');

/// Apk for testing
var testAppkFilePath = join(inFolder, 'app-release.apk');

void defineTests() {
  test('apk_get_sha1', () async {
    expect(
      await getApkSha1(testAppkFilePath),
      'ee5cbd7151d915de8b39530fe38eb1e714140b8f',
    );
  }, skip: !apksignerSupported);
  test('apk_get_sha1 path with a space', () async {
    var dir = await Directory.systemTemp.createTemp('android_utils_sha1');
    try {
      var apk = join(dir.path, 'my apps', 'app-release.apk');
      await Directory(dirname(apk)).create();
      await File(testAppkFilePath).copy(apk);
      expect(await getApkSha1(apk), 'ee5cbd7151d915de8b39530fe38eb1e714140b8f');
    } finally {
      await dir.delete(recursive: true);
    }
  }, skip: !apksignerSupported);
}
