import 'dart:io';

import 'package:tekartik_android_utils/src/gradle/gradle.dart';
import 'package:test/test.dart';

void main() {
  group('gradle', () {
    test('executable', () {
      if (Platform.isWindows) {
        expect(gradleShellExecutableFilename, 'gradlew.bat');
      } else {
        expect(gradleShellExecutableFilename, 'gradlew');
      }
    });
  });
}
