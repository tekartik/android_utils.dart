---
name: tekartik-android-utils-build-signing
description: >-
  Use when a Dart build script must locate the local Android Studio/SDK, put
  aapt/adb/apksigner/keytool/emulator on the PATH, list or move AVDs, build an
  apk with gradlew or create and inspect a signing keystore. Covers
  getAndroidBuildContext, initAndroidBuildEnvironment, AvdInfo, getAvdInfos,
  getAvdIniFileNames, moveAvdFolder, AndroidProject, AndroidModule,
  SigningOptions, KeytoolGenKeyOptions, AndroidModuleSigningExt (generateKey,
  printKeyInfo, printGradleConfig, printGradleConfigKts) from
  package:tekartik_android_utils/build_utils.dart, avd_utils.dart, project.dart
  and signing.dart.
---

# Android build environment, AVDs and signing (tekartik_android_utils)

`tekartik_android_utils` finds the Android Studio / SDK installation of the
current machine (Windows registry, well-known macOS/Linux paths,
`ANDROID_SDK_ROOT`), exposes it as a build context and a `process_run`
`ShellEnvironment`, and adds helpers around AVDs, Gradle builds and keystores.
All of it is `dart:io` only (Dart VM, no web).

## Guidelines

* The package is not on pub.dev, depend on it from git (single package at the
  repository root, so no `path:`):

  ```yaml
  dependencies:
    tekartik_android_utils:
      git:
        url: https://github.com/tekartik/android_utils.dart
  ```

* Start every script with `await initAndroidBuildEnvironment()` from
  `package:tekartik_android_utils/build_utils.dart`. It merges the Android tool
  directories into the global `shellEnvironment` of `process_run`, so any later
  `Shell().run(...)`, `which(...)`, `aapt`, `adb`, `apksigner`, `keytool`,
  `emulator`, `sdkmanager`, `avdmanager` call resolves. It is idempotent: only
  the first call does the work, later calls await the same future and ignore
  their arguments.
* `getAndroidBuildContext({sdkVersion})` returns the located paths:
  `androidStudioPath`, `androidStudioJdkPath`, `androidSdkPath`,
  `androidSdkBuildToolsPath`, `androidSdkPlatformToolsPath`,
  `androidSdkToolsPath`, `androidSdkCommandLineToolsPath`,
  `androidAvdHomePath`. Every getter is `String?` and is `null` when that
  directory was not found, so null-check before joining paths. `sdkVersion`
  (e.g. `31`) restricts build-tools/command-line-tools to that major version,
  otherwise the latest one is used.
* Keep the returned context in a `var`: the `AndroidBuildContext` type itself is
  not exported by `build_utils.dart` (only `getAndroidBuildContext`,
  `initAndroidBuildEnvironment` and the deprecated typo alias
  `getAndroidBuildContent` are). Same for `getAndroidBuildEnvironment()`, which
  returns a standalone `ShellEnvironment` instead of mutating the global one:
  the package's own `example/aapt.dart` imports
  `package:tekartik_android_utils/src/build_utils.dart` for it — do that only
  in scripts, never in published library code.
* AVDs (`avd_utils.dart`): `getAvdInfos()` runs `avdmanager list avd` and
  returns `Future<List<AvdInfo?>>` (**entries can be null**, filter with
  `.nonNulls`); `AvdInfo` carries `name`, `device`, `path`, `target`, `skin`,
  `sdCard`. `getAvdIniFileNames()` lists the `.ini` files of the AVD home
  without any tool call, and `moveAvdFolder(avd: ..., dst: ..., force: false)`
  moves one AVD folder to another disk and rewrites its `.ini`; it logs and
  skips when the destination already exists unless `force` is true.
  `avdInfosParseLines(lines)` is the pure parser, use it in tests.
* Gradle build (`project.dart`): `AndroidProject(path)` is just a path wrapper.
  `buildApkCmd(target, {flavor})` returns the `ProcessCmd` for
  `./gradlew <target>:assemble<Flavor>Release` — run it yourself with `runCmd`
  from `process_run` — and `getApkPath({flavor, module, mode})` computes the
  expected output path (`module` defaults to `AndroidProject.moduleApp`, `mode`
  to `AndroidProject.modeRelease`, the other constant is
  `AndroidProject.modeDebug`). `nameApk(target)` renames the built release apk
  after its version (see the `tekartik-android-utils-apk-aab-info` sibling
  skill). Targets are normalized with `AndroidProject.targetToGradleTarget`
  (`'app'` → `':app'`) and `targetToPath` (`':app:sub'` → `app/sub`).
* Signing (`signing.dart`, which also re-exports `project.dart`): build an
  `AndroidModule(project: androidProject, module: 'app')`, then use the
  `AndroidModuleSigningExt` extension methods, all running in the module
  directory:
  * `generateKey(signinOptions: SigningOptions(keystore: ..., password: ...),
    keytoolGenOptions: KeytoolGenKeyOptions(alias: ..., firstAndLastName: ...,
    organizationUnit: ..., organization: ..., cityOrLocality: ...,
    stateOrProvince: ..., countryCode: ...))` runs `keytool -genkey` (RSA 2048,
    validity 100000); every distinguished-name field is optional and omitted
    from `-dname` when null, `alias` defaults to `app`.
  * `printKeyInfo(signinOptions: ...)` runs `keytool -list -v`.
  * `printGradleConfig(signinOptions: ..., alias: ...)` prints the Groovy
    `signingConfigs`/`buildTypes` block, `printGradleConfigKts(...)` the Kotlin
    DSL one, to paste into `build.gradle`/`build.gradle.kts`.
  * Note the parameter is spelled `signinOptions` (no `g`), and `SigningOptions`
    uses the **same** password for the store and the key.
* Never hardcode a real keystore password in a script or a test: read it from
  the environment (`Platform.environment`) or a git-ignored local file, and keep
  the generated `.jks` out of the repository.
* Ready-made CLI (after `dart pub global activate -s git
  https://github.com/tekartik/android_utils.dart`):
  `android_build_environment` prints the detected paths.
* Testing: mark tests `@TestOn('vm')`, call `initAndroidBuildEnvironment()` in
  `setUpAll`, and tolerate `null` paths — machines without Android Studio must
  not fail the suite (that is what the package's own `build_utils_test.dart`
  does).

## Examples

Print the detected Android installation.

```dart
import 'dart:io';

import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main() async {
  await initAndroidBuildEnvironment();
  // The AndroidBuildContext type is not exported, keep it in a var.
  var context = await getAndroidBuildContext();
  stdout.writeln('studio      : ${context.androidStudioPath}');
  stdout.writeln('studio jdk  : ${context.androidStudioJdkPath}');
  stdout.writeln('sdk         : ${context.androidSdkPath}');
  stdout.writeln('build-tools : ${context.androidSdkBuildToolsPath}');
  stdout.writeln('cmdline     : ${context.androidSdkCommandLineToolsPath}');
  stdout.writeln('avd home    : ${context.androidAvdHomePath}');

  var buildTools = context.androidSdkBuildToolsPath;
  if (buildTools == null) {
    stderr.writeln('no build tools, install them from Android Studio');
    exit(1);
  }
}
```

List the AVDs and move a big one to another disk.

```dart
import 'dart:io';

import 'package:tekartik_android_utils/avd_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main() async {
  await initAndroidBuildEnvironment();

  // getAvdInfos() can contain null entries.
  for (var avd in (await getAvdInfos()).nonNulls) {
    stdout.writeln('${avd.name} ${avd.device} ${avd.target} ${avd.path}');
  }
  for (var iniFile in await getAvdIniFileNames()) {
    stdout.writeln(iniFile);
  }

  await moveAvdFolder(avd: 'Pixel_7_API_34', dst: '/data/avd', force: false);
}
```

Build a release apk with the project's Gradle wrapper.

```dart
import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:tekartik_android_utils/project.dart';

Future<void> main() async {
  await initAndroidBuildEnvironment();
  var project = AndroidProject('android');

  // ./gradlew :app:assembleRelease in the android directory.
  await runCmd(project.buildApkCmd('app'), verbose: true);

  var apkPath = project.getApkPath(
    module: AndroidProject.moduleApp,
    mode: AndroidProject.modeRelease,
  );
  stdout.writeln('apk: $apkPath ${File(apkPath).statSync().size} bytes');

  // Rename it to <package>-<versionName>-<versionCode>.apk
  await project.nameApk('app');
}
```

Create a keystore and print the matching Gradle configuration.

```dart
import 'dart:io';

import 'package:tekartik_android_utils/signing.dart';

Future<void> main() async {
  var module = AndroidModule(project: AndroidProject('android'), module: 'app');
  // Never hardcode the password, read it from the environment.
  var password = Platform.environment['ANDROID_KEYSTORE_PASSWORD']!;
  var signingOptions = SigningOptions(
    keystore: 'keystore.jks',
    password: password,
  );

  await module.generateKey(
    signinOptions: signingOptions,
    keytoolGenOptions: KeytoolGenKeyOptions(
      alias: 'app',
      firstAndLastName: 'John Doe',
      organization: 'Example Inc',
      cityOrLocality: 'Paris',
      countryCode: 'FR',
    ),
  );
  await module.printKeyInfo(signinOptions: signingOptions);
  await module.printGradleConfigKts(signinOptions: signingOptions);
}
```
