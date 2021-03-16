import 'dart:convert';

import 'package:dev_test/test.dart';
import 'package:tekartik_android_utils/src/bin/keytool.dart';

void main() {
  group('keytool', () {
    test('extractSha1', () {
      var lines = LineSplitter.split('''
Certificate fingerprints:
  MD5:  69:3D:D9:FE:2B:39:4A:68:59:A8:DD:78:6C:E8:9A:3B
  SHA1: 40:F1:83:3D:77:C2:F4:E1:55:66:EA:EA:1F:87:DC:7A:90:24:6C:48
      ''');
      expect(keytoolOutLinesExtractSha1Digest(lines),
          '40:F1:83:3D:77:C2:F4:E1:55:66:EA:EA:1F:87:DC:7A:90:24:6C:48');
    });
  });
}
