# tekartik_android_utils

Dart (VM) helpers around the Android SDK tools: find the Android Studio / SDK
installation and put its tools on the `process_run` PATH, read apk and aab
info (`aapt`, `bundletool`, `apksigner`, `keytool`), drive devices with `adb`,
list and move AVDs, build and name release apks, generate a keystore.

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_android_utils:
    git:
      url: https://github.com/tekartik/android_utils.dart
```

[example/main.dart](example/main.dart) (`dart run example/main.dart`):

```dart
import 'dart:io';

import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main() async {
  var context = await getAndroidBuildContext();
  stdout.writeln('sdk          ${context.androidSdkPath}');
  stdout.writeln('build-tools  ${context.androidSdkBuildToolsPath}');
  stdout.writeln('studio jdk   ${context.androidStudioJdkPath}');

  // adb, aapt, apksigner, sdkmanager... on the PATH of the next commands.
  await initAndroidBuildEnvironment();
  try {
    stdout.writeln('devices      ${await listDevices()}');
  } catch (e) {
    stderr.writeln('adb not found: $e');
  }
}
```

## Libraries

| Import `package:tekartik_android_utils/...` | For |
|---|---|
| `build_utils.dart` | `getAndroidBuildContext`, `initAndroidBuildEnvironment` (call it first) |
| `apk_utils.dart`, `aab_utils.dart` | `getApkInfo` (aapt), `nameApk`, `getApkSha1` (apksigner), `getAabInfo` (bundletool) |
| `adb_device.dart`, `adb_utils.dart`, `adb_shell.dart`, `adb_log.dart` | `listDevices`, `findDevice`, `AdbDevice`, `DeviceAdb`, `getAdbDeviceInfos`, `ps` parsing, `adbLog` |
| `avd_utils.dart` | `getAvdInfos`, `moveAvdFolder` |
| `emulator_utils.dart` | `listAndroidEmulatorAvds`, `launchAndroidEmulator` (detached, waits for the boot), `killAndroidEmulator`, `waitForAdbDeviceBootCompleted` |
| `project.dart`, `signing.dart` | `AndroidProject` (gradle `assemble<Flavor>Release`, apk paths), keystore generation and Gradle signing config |

The package skills (`skills/`) give the details and examples.

## Run a command on an emulator

`android_emu_run` runs a command on an Android device, launching an emulator
when none is online, and stops the emulator it launched afterwards:

```bash
dart pub global activate -s git https://github.com/tekartik/android_utils.dart
# In a Flutter app: the running emulator, a phone, or the only AVD
dart pub global run tekartik_android_utils:android_emu_run -- flutter test integration_test
# That AVD (its running emulator, or a new one), kept running afterwards
dart pub global run tekartik_android_utils:android_emu_run --avd Pixel_9 --keep -- flutter test integration_test
# Boot it and leave it running (no command)
dart pub global run tekartik_android_utils:android_emu_run --avd Pixel_9 --no-window
```

The device is `--serial`, otherwise the running emulator of `--avd` or a new
one, otherwise the first online emulator or device, otherwise the only AVD
(`--list` shows them). The command gets `ANDROID_SERIAL` (adb, gradle
`connectedAndroidTest`) and, for `flutter run/test/drive/install/attach/logs/
screenshot`, `-d <serial>`; its exit code is the one of the tool.

## Platforms

Dart VM only (`dart:io`, it runs the SDK tools): Linux, macOS, Windows. The
tools must be installed (Android SDK, Android Studio for its JDK,
`bundletool` on the PATH for aab files).

## Common pitfalls

* Call `await initAndroidBuildEnvironment()` before running `aapt`,
  `apksigner`, `adb`, `avdmanager`... (only the first call does the work).
* The SDK is found from `ANDROID_SDK_ROOT`, the Windows registry and
  `%LOCALAPPDATA%\Android\Sdk`, `~/Library/Android/sdk` on macOS. On Linux
  set `ANDROID_SDK_ROOT` (`ANDROID_HOME` and `~/Android/Sdk` are not read).
  Android Studio (and its `jbr` JDK) is found from its desktop shortcut on
  Linux.
* Every path of the build context is null when not found (no build-tools
  yet, no Android Studio): null-check them.
* `listDevices()` also returns offline and unauthorized devices; use
  `getAdbDeviceInfos()` and keep `type == 'device'`.
* Keystore passwords: read them from the environment, never in a script;
  they are passed on the `keytool` command line.

## Scripts

The pubspec declares no executables. After
`dart pub global activate -s git https://github.com/tekartik/android_utils.dart`,
run `dart pub global run tekartik_android_utils:<script>`, or
`dart run bin/<script>.dart` in a checkout: `android_build_environment`,
`apk_info`, `apk_name_it`, `adb_log`, `adb_device_os_version`, `adb_tcpip`,
`adb_kill_emu`, `adb_kill_monkey`, `kill_emu`, `adb_menu`.

## Testing

```bash
dart test
```

Tests needing a tool (aapt, apksigner, bundletool, adb) are skipped when it
is missing.
