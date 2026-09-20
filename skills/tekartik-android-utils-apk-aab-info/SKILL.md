---
name: tekartik-android-utils-apk-aab-info
description: >-
  Use when reading or renaming Android build artifacts from Dart: package name,
  versionName and versionCode of an .apk (aapt dump badging) or .aab
  (bundletool dump manifest), and the signing certificate SHA-1 of an apk.
  Covers getApkInfo, ApkInfo, aaptSupported, getAabInfo, AabInfo,
  bundleToolSupported, getApkSha1, apkExtractSha1Digest, nameApk, copyApk,
  nameIt from package:tekartik_android_utils/apk_utils.dart and aab_utils.dart.
---

# Apk and aab metadata (tekartik_android_utils)

`tekartik_android_utils` wraps the Android command line tools (`aapt`,
`bundletool`, `apksigner`, `keytool`) so a Dart build script can read the
metadata of an apk/aab and rename release artifacts. Everything here is
`dart:io` based: it only runs on the Dart VM, never on the web.

## Guidelines

* The package is not on pub.dev, depend on it from git (single package at the
  repository root, so no `path:`):

  ```yaml
  dependencies:
    tekartik_android_utils:
      git:
        url: https://github.com/tekartik/android_utils.dart
  ```

* Import `package:tekartik_android_utils/apk_utils.dart` for apk work and
  `package:tekartik_android_utils/aab_utils.dart` for app bundles. `apk_utils`
  re-exports `ApkInfo`, `getApkSha1` and `apkExtractSha1Digest`, so one import
  is usually enough.
* Every function shells out; the tool must be on the `PATH`. Call
  `initAndroidBuildEnvironment()` (from
  `package:tekartik_android_utils/build_utils.dart`) first to prepend the
  Android SDK build-tools/platform-tools to the `PATH` of the current process,
  then guard on `aaptSupported` / `bundleToolSupported` (cached `whichSync`
  checks) before calling. See the `tekartik-android-utils-build-signing`
  sibling skill for the build environment itself.
* `getApkInfo(apkFilePath, {verbose})` returns `Future<ApkInfo?>`: it is
  **nullable**, `null` means no badging line could be parsed (bad path, apk not
  readable by `aapt`). Always null-check, do not blindly `!`.
* `getAabInfo(aabFilePath, {verbose})` returns a non-nullable
  `Future<AabInfo>`; it throws if `bundletool` fails.
* `ApkInfo` has three mutable `String?` fields: `name` (the package name, e.g.
  `com.example.app`), `versionName` and `versionCode` — `versionCode` is a
  **String**, parse it with `int.tryParse` if you need a number. `toMap()` and
  `toString()` are handy for logs. `AabInfo` extends `ApkInfo` and adds
  `fromXml(String xmlText)` to fill those fields from an `AndroidManifest.xml`
  document (`package`, `android:versionName`, `android:versionCode`).
* Signature hash: `getApkSha1(apkPath, {verbose})` runs
  `apksigner verify --print-certs`; `apkExtractSha1Digest(apkPath)` runs
  `keytool -printcert -jarfile` instead. Both return `Future<String?>` (`null`
  when the digest line is missing) and both throw if the tool is absent, so
  wrap them in a `try`/`catch` like the `apk_info` CLI does.
* Renaming release artifacts: `nameApk(apkFilePath, {outFolderPath})` reads the
  info and copies the apk to `<name>-<versionName>-<versionCode>.apk`
  (`outFolderPath` defaults to the apk's own directory); it throws a
  `StateError` when the file is missing or unreadable. `copyApk(apkFilePath,
  apkInfo, {outFolderPath})` does the copy when you already hold an `ApkInfo`.
  `nameIt(apkFilePath, manifestFilePath, {versionName})` derives the name from
  a manifest xml instead of from `aapt` (both extensions are checked: `.apk`
  and `.xml`, `StateError` otherwise).
* These helpers write progress to stdout/stderr, they are meant for build
  scripts, not for a library API. They never delete the source apk.
* Ready-made CLI: `dart pub global activate -s git https://github.com/tekartik/android_utils.dart`
  then `apk_info <file.apk>` (name, versionCode, versionName, SHA1),
  `apk_info <file.apk> <manifest.xml>` and `apk_name_it <file.apk> [dstFolder]`.
* Testing: mark the test `@TestOn('vm')` and skip when the tool is missing
  (`whichSync('aapt') != null`), like the package's own `apk_utils_test.dart`;
  CI machines rarely have the Android SDK.

## Examples

Read the metadata and the certificate digest of a release apk.

```dart
import 'dart:io';

import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main(List<String> args) async {
  var apkFilePath = args.first;
  // Make aapt/apksigner/keytool visible in the PATH.
  await initAndroidBuildEnvironment();

  if (!aaptSupported) {
    stderr.writeln('aapt not found, check your Android SDK build-tools');
    exit(1);
  }
  var apkInfo = await getApkInfo(apkFilePath);
  if (apkInfo == null) {
    stderr.writeln('cannot read $apkFilePath');
    exit(1);
  }
  stdout.writeln('name        : ${apkInfo.name}');
  stdout.writeln('versionName : ${apkInfo.versionName}');
  stdout.writeln('versionCode : ${apkInfo.versionCode}');

  try {
    stdout.writeln('SHA1 (apksigner): ${await getApkSha1(apkFilePath)}');
    stdout.writeln('SHA1 (keytool)  : ${await apkExtractSha1Digest(apkFilePath)}');
  } catch (e) {
    stderr.writeln('Fail to extract sha1: $e');
  }
}
```

Read an app bundle manifest through `bundletool`.

```dart
import 'dart:io';

import 'package:tekartik_android_utils/aab_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main(List<String> args) async {
  await initAndroidBuildEnvironment();
  if (!bundleToolSupported) {
    stderr.writeln('bundletool not found in the PATH');
    exit(1);
  }
  var aabInfo = await getAabInfo(args.first, verbose: true);
  stdout.writeln('${aabInfo.name} ${aabInfo.versionName} (${aabInfo.versionCode})');
  var versionCode = int.tryParse(aabInfo.versionCode ?? '');
  stdout.writeln('next version code: ${(versionCode ?? 0) + 1}');
}
```

Rename the apk produced by a release build into a versioned file name.

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main() async {
  await initAndroidBuildEnvironment();
  var apkFilePath = join(
    'build',
    'app',
    'outputs',
    'flutter-apk',
    'app-release.apk',
  );
  var outFolderPath = join('build', 'publish');
  await Directory(outFolderPath).create(recursive: true);

  // Copies to build/publish/com.example.app-1.0.1-2.apk
  await nameApk(apkFilePath, outFolderPath: outFolderPath);

  // Same, when the info is already known (no aapt call).
  var apkInfo = await getApkInfo(apkFilePath);
  if (apkInfo != null) {
    await copyApk(apkFilePath, apkInfo, outFolderPath: outFolderPath);
  }
}
```

Parse an `AndroidManifest.xml` without any external tool.

```dart
import 'dart:io';

import 'package:tekartik_android_utils/aab_utils.dart';

Future<void> main(List<String> args) async {
  var manifestPath = args.first;
  var info = AabInfo()..fromXml(await File(manifestPath).readAsString());
  stdout.writeln('${info.name} ${info.versionName} (${info.versionCode})');
  stdout.writeln(info.toMap());
}
```
