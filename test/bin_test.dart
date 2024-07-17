@TestOn('vm')
library;

import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:test/test.dart';

// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

void main() => defineTests();

String inFolder = join('test', 'data');
String outFolder = join(inFolder, 'tmp');

void defineTests() {
  group('bin', () {
    test('apk_info', () async {
      var result = await runCmd(
          DartCmd([
            join('bin', 'apk_info.dart'),
            join(inFolder, 'app-release.apk')
          ]),
          verbose: true);
      expect(result.stdout, contains('versionName'));
      expect(result.exitCode, 0);
    });

    test('nameIt', () async {
      var result = await runCmd(
          DartCmd([
            join('bin', 'apk_name_it.dart'),
            join(inFolder, 'app-release.apk'),
            join(outFolder, 'bin_name_it')
          ]),
          verbose: true);
      expect(result.exitCode, 0);
    });
  }, skip: !aaptSupported);
  group('bin_pub', () {
    test('apk_info', () async {
      var result = await runCmd(
          PubCmd(['run', 'apk_info.dart', join(inFolder, 'app-release.apk')]),
          commandVerbose: true);
      expect(result.stdout, contains('versionName'));
      expect(result.exitCode, 0);
    });

    test('apk_info no arg', () async {
      var result =
          await runCmd(PubCmd(['run', 'apk_info.dart']), commandVerbose: true);
      expect(result.stdout, contains('versionName'));
      expect(result.exitCode, 0);
    });

    test('nameIt', () async {
      var result = await runCmd(
          PubCmd([
            'run',
            'apk_name_it.dart',
            join(inFolder, 'app-release.apk'),
            join(outFolder, 'bin_pub_name_it')
          ]),
          verbose: true);
      expect(result.exitCode, 0);
    });

    test('nameIt no arg', () async {
      var result =
          await runCmd(PubCmd(['run', 'apk_name_it.dart']), verbose: true);
      expect(result.exitCode, 0);
    });
  }, skip: !aaptSupported);
}
