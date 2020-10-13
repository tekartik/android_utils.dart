@TestOn('vm')
library tekartik_android_util.test.adb_utils_test;

import 'dart:convert';

import 'package:dev_test/test.dart';
import 'package:process_run/which.dart';
import 'package:tekartik_android_utils/adb_utils.dart';
import 'package:tekartik_android_utils/src/adb_utils.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

void main() {
  group('adb_utils', () {
    setUpAll(() async {
      await initAndroidBuildEnvironment();
    });
    test('adb', () async {
      if (whichSync('adb') != null) {
        var infos = await getAdbDeviceInfos();
        expect(infos, const TypeMatcher<List>());
      }
    }, skip: false);
    test('parse adb devices -l output', () {
      var output = '''
List of
emulator-5554          device product:sdk_gphone_x86 model:Android_SDK_built_for_x86 device:generic_x86 transport_id:1
''';
      var lines = LineSplitter.split(output).toList();
      var infos = adbDeviceInfosParseLines(lines);
      expect(infos.length, 1);
      var info = infos.first;
      expect(info.serial, 'emulator-5554');
    });
  });
}
