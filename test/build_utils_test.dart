@TestOn('vm')
library tekartik_android_util.test.build_utils_test;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/build_utils.dart';

void main() {
  group('build_utils', () {
    setUpAll(() async {
      await initAndroidBuildEnvironment();
    });
    test('compat', () async {
      var context = await getAndroidBuildContent();
      print(context.androidStudioPath);
      print(context.androidSdkPath);
      print(context.androidStudioJdkPath);
    });
    test('context', () async {
      var context = await getAndroidBuildContext();
      print(context.androidStudioPath);
      print(context.androidSdkPath);
      print(context.androidStudioJdkPath);
    });
    test('cmdline-tools', () async {
      var context = await getAndroidBuildContext();
      if (context.androidSdkCommandLineToolsPath != null) {
        // sdkmanager should be found in cmdline tools instead of tools
        expect(dirname(dirname((await which('sdkmanager'))!)),
            context.androidSdkCommandLineToolsPath);
      }
    });
  });
}
