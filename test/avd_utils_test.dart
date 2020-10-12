@TestOn('vm')
library tekartik_android_util.test.avd_utils_test;

import 'dart:convert';

import 'package:dev_test/test.dart';
import 'package:tekartik_android_utils/avd_utils.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

void main() {
  group('build_utils', () {
    setUpAll(() async {
      await initAndroidBuildEnvironment();
    });
    test('avdmanager', () async {
      if (avdmanager != null) {
        var avdInfos = await getAvdInfos();
        expect(avdInfos, const TypeMatcher<List>());
      }
    }, skip: true);
    test('parse avdmanager output', () {
      var output = '''
    Name: Nexus_4_API_25
  Device: Nexus 4 (Google)
    Path: /home/alex/.android/avd/Nexus_4_API_25.avd
  Target: Google APIs (Google Inc.)
          Based on: Android 7.1.1 (Nougat) Tag/ABI: google_apis/x86
    Skin: nexus_4
  Sdcard: 512M
---------
    Name: Nexus_4_API_28
  Device: Nexus 4 (Google)
    Path: /home/alex/.android/avd/Nexus_4_API_28.avd
  Target: Default Android System Image
          Based on: Android API 28 Tag/ABI: default/x86
    Skin: nexus_4
  Sdcard: 512M
---------
''';
      var lines = LineSplitter.split(output).toList();
      var avdInfos = avdInfosParseLines(lines);
      expect(avdInfos.length, 2);
      var avdInfo = avdInfos.first;
      expect(avdInfo.name, 'Nexus_4_API_25');
      expect(avdInfo.skin, 'nexus_4');
    });
  });
}
