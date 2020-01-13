@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library aab_utils_test;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:tekartik_android_utils/aab_utils.dart';

void main() => defineTests();

String inFolder = join('test', 'data');
String outFolder = join(inFolder, 'tmp');

void defineTests() {
  group('aab_utils', () {
    test('version', () async {
      // print(Platform.environment);
      await run('bundletool version');
    });
    test('public', () {
      // ignore: unnecessary_statements
      AabInfo;
      // ignore: unnecessary_statements
      getAabInfo;
    });
    group('aapt', () {
      test('getAabInfo', () async {
        var manifestInfo =
            await getAabInfo(join(inFolder, 'app-release.aab'), verbose: true);
        expect(manifestInfo.name, 'com.tekartik.miniexp');
        expect(manifestInfo.versionCode, '2');
        expect(manifestInfo.versionName, '1.0.1');
      });
    }, skip: !bundleToolSupported);
  });
}
