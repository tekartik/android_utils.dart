@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library;

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
    expect(await getApkSha1(testAppkFilePath),
        'ee5cbd7151d915de8b39530fe38eb1e714140b8f');
  }, skip: !apksignerSupported);
}
