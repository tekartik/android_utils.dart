@TestOn('vm')
import 'package:dev_test/test.dart';
import 'package:tekartik_android_utils/android_cmd.dart';

main() {
  group('android_cmd', () {
    test('firebaseArgs', () async {
      expect(nameApkCommand(flavor: "staging").arguments,
          ['app/build/outputs/apk/app-staging-release.apk']);
    });
  });
}
