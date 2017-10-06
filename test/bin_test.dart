@TestOn("vm")

import 'package:dev_test/test.dart';
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

void main() => defineTests();

String inFolder = join("test", "data");
String outFolder = join(inFolder, "tmp");

void defineTests() {
  group('bin', () {
    test('apk_info', () async {
      ProcessResult result = await runCmd(
          dartCmd([
            join("bin", "apk_info.dart"),
            join(inFolder, "app-release.apk")
          ]),
          verbose: true);
      expect(result.stdout, contains("versionName"));
      expect(result.exitCode, 0);
    });

    test('nameIt', () async {
      ProcessResult result = await runCmd(
          dartCmd([
            join("bin", "apk_name_it.dart"),
            join(inFolder, "app-release.apk"),
            join(outFolder, joinAll(testDescriptions))
          ]),
          verbose: true);
      expect(result.exitCode, 0);
    });
  });
  group('bin_pub', () {
    test('apk_info', () async {
      ProcessResult result = await devRunCmd(
          pubCmd(["run", "apk_info.dart", join(inFolder, "app-release.apk")]),
          commandVerbose: true);
      expect(result.stdout, contains("versionName"));
      expect(result.exitCode, 0);
    });

    test('apk_info no arg', () async {
      ProcessResult result =
          await runCmd(pubCmd(["run", "apk_info.dart"]), commandVerbose: true);
      expect(result.stdout, contains("versionName"));
      expect(result.exitCode, 0);
    });

    test('nameIt', () async {
      ProcessResult result = await runCmd(
          pubCmd([
            "run",
            "apk_name_it.dart",
            join(inFolder, "app-release.apk"),
            join(outFolder, joinAll(testDescriptions))
          ]),
          verbose: true);
      expect(result.exitCode, 0);
    });

    test('nameIt no arg', () async {
      ProcessResult result =
          await runCmd(pubCmd(["run", "apk_name_it.dart"]), verbose: true);
      expect(result.exitCode, 0);
    });
  });
}
