---
name: tekartik-android-utils-adb
description: >-
  Use when driving adb from Dart: listing and selecting connected devices, running
  adb shell commands, pushing/pulling directories, reading an installed
  package version with dumpsys, parsing adb shell ps output or streaming
  logcat, launching an emulator and running tests on it (android_emu_run).
  Covers listDevices, findDevice, findFirstDevice, findIpDevice,
  AdbDevice, DeviceAdb, AdbDeviceInfo, getAdbDeviceInfos, DumpsysPackageResult,
  adbLog, AdbLogOptions, ShellPsParser, adbCmd, adbKillEmulator,
  listAndroidEmulatorAvds, launchAndroidEmulator, killAndroidEmulator,
  waitForAdbDeviceBootCompleted from
  package:tekartik_android_utils/adb_device.dart, adb_utils.dart,
  adb_shell.dart, adb_log.dart, android_cmd.dart and emulator_utils.dart.
---

# adb devices, shell and logs (tekartik_android_utils)

`tekartik_android_utils` wraps the `adb` command line tool with `process_run`
shells: device discovery by serial or IP, `adb shell` helpers, `dumpsys`
parsing and a `logcat` streamer. It is `dart:io` only (Dart VM, no web).

## Guidelines

* The package is not on pub.dev, depend on it from git (single package at the
  repository root, so no `path:`):

  ```yaml
  dependencies:
    tekartik_android_utils:
      git:
        url: https://github.com/tekartik/android_utils.dart
  ```

* `adb` must be on the `PATH`. Call `initAndroidBuildEnvironment()` (from
  `package:tekartik_android_utils/build_utils.dart`) once at startup to add the
  Android SDK `platform-tools` to it, and test availability with
  `isAdbSupportedSync()` from `adb_utils.dart`.
* Device discovery (`adb_device.dart`) works with **serial strings**, not
  objects: `listDevices()` returns `Future<List<String>>`,
  `findFirstDevice()` and `findIpDevice({port = 5555})` return
  `Future<String?>`. `findDevice({serial})` resolves the usual CLI forms:
  `null` or `'any'` → first device, `'any:<port>'` → first TCP/IP device,
  anything else → that exact serial, but only if it is currently connected
  (otherwise `null`). `listDevices()` keeps `offline` and
  `unauthorized` devices too (use `getAdbDeviceInfos()` and its `type` to
  pick a usable one).
* Two different device wrappers exist, pick one:
  * `AdbDevice(serial)` (`adb_device.dart`) is the light one:
    `runShellCommand(command, {verbose})` returns the stdout of
    `adb -s <serial> shell <command>` as a `String` (throws on a non-zero exit)
    and `getIp({verbose})` returns the device's own IPv4 address or `null`.
  * `DeviceAdb(serial)` (`adb_utils.dart`) is the richer one:
    `runAdbCommand`/`runAdbCommandNoThrow` return a `ProcessResult`,
    `runAdbCommandOutLines(command)` returns `List<String>`, plus
    `fileExists(androidPath)`, `pullDirectory(androidFrom, localTo)`,
    `pushDirectory(localFrom, androidTo)` and
    `getDumpsysPackageInfo(packageName)`. Its `command` argument is everything
    after `adb -s <serial>`, e.g. `'shell ls /sdcard'`.
* `getDumpsysPackageInfo(packageName)` returns a `DumpsysPackageResult` whose
  `packageInfo` is `null` when the package is not installed. When set, the
  `DumpsysPackageInfo` exposes `packageName`, `versionName`, `versionCode`
  (`int`), `minSdkVersion` and `targetSdkVersion` — use it to decide whether an
  apk needs to be reinstalled.
* `getAdbDeviceInfos()` parses `adb devices -l` into `AdbDeviceInfo` objects
  (`serial`, `type`, `product`, `model`, `device`, all mutable `String?`). Keep
  only the ones with `type == 'device'`; `offline`/`unauthorized` entries are
  returned too. `adbDeviceInfosParseLines(lines)` and
  `adbDumpsysPackageParseLines(lines)` are the pure parsers, use them in unit
  tests against captured output instead of a real device.
* Logs: `adbLog(AdbLogOptions(package: ..., serial: ..., verbose: false))`
  streams `adb logcat` to stdout and **never returns** (it loops until the
  process is killed). With a `package` it polls `pidof` and restarts `logcat`
  filtered on the app pid whenever the app restarts. Both `package` and
  `serial` are required named parameters but nullable (`null` package = whole
  device log).
* `adb_shell.dart` parses `adb shell ps` output: `ShellPsParser(stdout)` builds
  `header` + `lines`, `findByName(name)` returns the `PsLine?` of a process,
  `PsLine.pid` is its pid. Kill it with the `shellKill(pid)` args from
  `android_cmd.dart`.
* `android_cmd.dart` only builds `ProcessCmd`/argument lists (run them with
  `runCmd` from `process_run`): `adbCmd(args)`, `adbMonkeyArgs({packageName,
  count, sysKeysPercent})`, `shellPsAdbArgs()`, `shellKill(pid)`,
  `adbKillEmulator({emulatorName})` and `defaultEmulatorSerialNumber`
  (`'emulator-5554'`). The `AdbTarget` class there is obsolete, use `DeviceAdb`.
* A dev-menu integration is available in
  `package:tekartik_android_utils/menu/device_id_vars_menu.dart`
  (`keyValueDeviceIdMenu(kv)`, `keyValuesDeviceIdMenu([kv])`) to let a
  developer pick the target serial interactively; it needs
  `tekartik_app_dev_menu` (`KeyValue`).
* Ready-made scripts (after `dart pub global activate -s git
  https://github.com/tekartik/android_utils.dart`, run as
  `dart pub global run tekartik_android_utils:<script>`: the pubspec
  declares no executables): `adb_log -p <package> [-s <serial>]`, `android_emu_run`,
  `adb_device_os_version`, `adb_tcpip`, `adb_kill_emu`, `adb_kill_monkey`.
* Emulators (`emulator_utils.dart`, after `initAndroidBuildEnvironment()`
  which puts the SDK `emulator` folder on the PATH):
  `listAndroidEmulatorAvds()` (`emulator -list-avds`),
  `launchAndroidEmulator(avd: ..., noWindow: ..., arguments: [...])` starts
  it **detached** (it lives on after the program) on the first free console
  port and returns once `sys.boot_completed` is `1` (an
  `AndroidEmulatorLaunch`, its `serial` is `emulator-<port>`, `kill()` stops
  it); `killAndroidEmulator(serial)` (`adb emu kill`, waits until adb drops
  it), `getAndroidEmulatorAvdName(serial)`, `waitForAdbDeviceBootCompleted`.
  The pure parts (`emulatorListAvdsParseLines`, `adbEmuAvdNameParseLines`,
  `androidEmulatorFreePort`, `androidCommandWithDevice`,
  `androidEmulatorRunChooseTarget`) are unit tested without an emulator.
* Run tests on an emulator from the command line: `android_emu_run [--avd
  <name>] [--serial <serial>] [--keep] [--no-window] -- flutter test
  integration_test`. It uses `--serial`, otherwise the running emulator of
  `--avd` or a new one, otherwise the first online emulator or device,
  otherwise the only AVD; the command gets `ANDROID_SERIAL` and, for a
  flutter command taking a device, `-d <serial>`. It stops the emulator it
  launched (not one already running) unless `--keep`; without a command it
  only boots it. `--list` shows the devices (with their AVD) and the AVDs.
* Anti-pattern: do not assume a device is connected in tests. Mark them
  `@TestOn('vm')` and guard with `isAdbSupportedSync()` plus an empty
  `listDevices()` check.

## Examples

List connected devices and print the Android release of the first one.

```dart
import 'dart:io';

import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_android_utils/adb_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main() async {
  await initAndroidBuildEnvironment();
  if (!isAdbSupportedSync()) {
    stderr.writeln('adb not found');
    exit(1);
  }
  for (var info in await getAdbDeviceInfos()) {
    stdout.writeln('${info.serial} ${info.type} ${info.model}');
  }

  // 'any' (or null) picks the first device, 'any:5555' the first ip device.
  var serial = await findDevice(serial: Platform.environment['ANDROID_SERIAL']);
  if (serial == null) {
    stderr.writeln('no device connected');
    exit(1);
  }
  var device = AdbDevice(serial);
  var release = await device.runShellCommand(
    'getprop ro.build.version.release',
  );
  stdout.writeln('$serial: Android ${release.trim()} ip ${await device.getIp()}');
}
```

Check the installed version of an app and pull its files.

```dart
import 'dart:io';

import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_android_utils/adb_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main() async {
  await initAndroidBuildEnvironment();
  var serial = await findFirstDevice();
  if (serial == null) {
    stderr.writeln('no device connected');
    return;
  }
  var device = DeviceAdb(serial);

  var packageName = 'com.example.app';
  var result = await device.getDumpsysPackageInfo(packageName);
  var info = result.packageInfo;
  if (info == null) {
    stdout.writeln('$packageName is not installed');
  } else {
    stdout.writeln('${info.packageName} ${info.versionName} (${info.versionCode})'
        ' minSdk ${info.minSdkVersion} targetSdk ${info.targetSdkVersion}');
  }

  var androidDir = '/sdcard/Android/data/$packageName/files';
  if (await device.fileExists(androidDir)) {
    await device.pullDirectory(androidDir, 'local_dump');
  }
  for (var line in await device.runAdbCommandOutLines('shell ls /sdcard')) {
    stdout.writeln(line);
  }
}
```

Find a running process with the `ps` parser and kill it.

```dart
import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/adb_shell.dart';
import 'package:tekartik_android_utils/android_cmd.dart';

Future<void> main() async {
  var psResult = await runCmd(adbCmd(shellPsAdbArgs()));
  var parser = ShellPsParser(psResult.stdout.toString());

  var line = parser.findByName('com.android.commands.monkey');
  if (line == null) {
    stdout.writeln('monkey not running');
    return;
  }
  stdout.writeln('killing pid ${line.pid}');
  await runCmd(adbCmd(shellKill(line.pid)));

  // Stop the default emulator (emulator-5554).
  await runCmd(adbKillEmulator());
}
```

Stream the logs of one app (this call runs until the process is killed).

```dart
import 'package:tekartik_android_utils/adb_log.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main(List<String> args) async {
  await initAndroidBuildEnvironment();
  await adbLog(
    AdbLogOptions(
      package: 'com.example.app',
      // null/'any': first device, 'any:5555': first ip device, or a serial.
      serial: args.isEmpty ? null : args.first,
      verbose: false,
    ),
  );
}
```
