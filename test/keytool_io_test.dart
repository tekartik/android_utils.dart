import 'package:tekartik_android_utils/src/bin/keytool_io.dart';
import 'package:test/test.dart';

import 'apk_utils_test.dart';

void main() {
  group('keytool_io', () {
    test('extractSha1', () async {
      expect(await apkExtractSha1Digest(testAppkFilePath),
          'EE:5C:BD:71:51:D9:15:DE:8B:39:53:0F:E3:8E:B1:E7:14:14:0B:8F');
    });
  });
}
