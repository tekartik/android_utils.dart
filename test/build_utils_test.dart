@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:tekartik_android_utils/src/build_utils.dart'
    show readRegistryString;
import 'package:test/test.dart';

void main() {
  group('build_utils', () {
    setUpAll(() async {
      await initAndroidBuildEnvironment();
    });
    test('compat', () async {
      var context = await getAndroidBuildContent();
      stdout.writeln(context.androidStudioPath);
      stdout.writeln(context.androidSdkPath);
      stdout.writeln(context.androidStudioJdkPath);
    });
    test('context', () async {
      var context = await getAndroidBuildContext();
      stdout.writeln(context.androidStudioPath);
      stdout.writeln(context.androidSdkPath);
      stdout.writeln(context.androidStudioJdkPath);
    });
    test('cmdline-tools', () async {
      var context = await getAndroidBuildContext();
      if (context.androidSdkCommandLineToolsPath != null) {
        // sdkmanager should be found in cmdline tools instead of tools
        expect(
          dirname(dirname((await which('sdkmanager'))!)),
          context.androidSdkCommandLineToolsPath,
        );
      }
    });
    if (Platform.isWindows) {
      test('readRegistryString', () async {
        var displayVersion = await readRegistryString(
          'HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion',
          'DisplayVersion',
        );
        expect(displayVersion, isNotNull);
      });
    }
  });
}
