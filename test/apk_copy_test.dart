@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:test/test.dart';

void main() {
  group('copyApk', () {
    late Directory tempDir;
    final apkInfo = ApkInfo(
      name: 'com.example.app',
      versionName: '1.0.1',
      versionCode: '2',
    );
    const content = [1, 2, 3, 4, 5, 6, 7, 8];
    const wellNamed = 'com.example.app-1.0.1-2.apk';

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('android_utils_copy_apk');
    });
    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('already well named, never copied onto itself', () async {
      var apk = File(join(tempDir.path, wellNamed))..writeAsBytesSync(content);
      await copyApk(apk.path, apkInfo);
      expect(apk.readAsBytesSync(), content);
    });

    test('already well named in an explicit out folder', () async {
      var apk = File(join(tempDir.path, wellNamed))..writeAsBytesSync(content);
      await copyApk(
        apk.path,
        apkInfo,
        outFolderPath: join(tempDir.path, '.', 'sub', '..'),
      );
      expect(apk.readAsBytesSync(), content);
    });

    test('copied next to the source', () async {
      var apk = File(join(tempDir.path, 'app-release.apk'))
        ..writeAsBytesSync(content);
      await copyApk(apk.path, apkInfo);
      expect(File(join(tempDir.path, wellNamed)).readAsBytesSync(), content);
      expect(apk.readAsBytesSync(), content);
    });

    test('copied in the out folder', () async {
      var apk = File(join(tempDir.path, 'app-release.apk'))
        ..writeAsBytesSync(content);
      var outFolder = join(tempDir.path, 'out');
      await copyApk(apk.path, apkInfo, outFolderPath: outFolder);
      expect(File(join(outFolder, wellNamed)).readAsBytesSync(), content);
    });
  });
}
