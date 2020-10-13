@TestOn('vm')
library tekartik_android_util.test.build_utils_test;

import 'package:dev_test/test.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

void main() {
  group('build_utils', () {
    setUpAll(() async {
      await initAndroidBuildEnvironment();
    });
    test('context', () async {
      var context = await getAndroidBuildContent();
      print(context.androidStudioPath);
      print(context.androidSdkPath);
      print(context.androidStudioJdkPath);
    });
  });
}
