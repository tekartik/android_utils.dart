import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:tekartik_android_utils/build_utils.dart';

import 'build_utils.dart';

/// Checks whether the `adb` executable is available on the current `PATH`.
///
/// Returns `true` if `adb` was found, `false` otherwise.
bool isAdbSupportedSync() {
  return whichSync('adb') != null;
}

/// Adb device information
class AdbDeviceInfo {
  /// Serial number of the device
  String? serial;

  /// Type of the device (e.g., "device", "offline", "unauthorized")
  String? type;

  /// Product name of the device
  String? product;

  /// Model name of the device
  String? model;

  /// Device name of the device
  String? device;
}

final _whitespaceRegExp = RegExp(r'\s+');

/// Parses [lines] — the stdout of `adb devices -l` — into a list of
/// [AdbDeviceInfo], one per connected device. Lines before the `List of`
/// header, and any that don't carry at least a serial and a type, are
/// ignored.
///
/// Returns an empty list if no device lines are found.
List<AdbDeviceInfo> adbDeviceInfosParseLines(Iterable<String> lines) {
  var list = <AdbDeviceInfo>[];

  var listStarted = false;
  for (var line in lines) {
    if (line.startsWith('List of')) {
      listStarted = true;
      continue;
    } else if (listStarted) {
      var parts = line
          .split(_whitespaceRegExp)
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.length >= 2) {
        var info = AdbDeviceInfo()
          ..serial = parts[0]
          ..type = parts[1];
        for (var i = 2; i < parts.length; i++) {
          var part = parts[i];
          var defParts = part.split(':');
          if (defParts.length > 1) {
            var key = defParts[0].toLowerCase();
            var value = defParts.sublist(1).join(':');
            switch (key) {
              case 'product':
                info.product = value;
                break;
              case 'model':
                info.model = value;
                break;
              case 'device':
                info.device = value;
                break;
            }
          }
        }
        list.add(info);
      }
    }
  }

  return list;
}

/// Runs `adb devices -l` and parses its output into [AdbDeviceInfo]s, one
/// per connected device (possibly empty).
///
/// [initAndroidBuildEnvironment] must have been called first.
Future<List<AdbDeviceInfo>> getAdbDeviceInfos() async {
  var lines = (await run('adb devices -l')).outLines;
  return adbDeviceInfosParseLines(lines);
}

/// Device ADB utility class
class DeviceAdb {
  /// Serial number of the device
  final String serial;

  /// Shell instance for running adb commands
  var shell = Shell();

  /// Shell instance for running adb commands without throwing on error
  var shellNoThrow = Shell(throwOnError: false);

  /// Creates a [DeviceAdb] that runs all commands against the device with
  /// the given [serial] (as reported by `adb devices`).
  DeviceAdb(this.serial);

  /// Runs `adb -s [serial] [command]` and returns its stdout as a list of
  /// lines. Throws if the command exits with a non-zero code.
  Future<List<String>> runAdbCommandOutLines(String command) async {
    return (await shell.run('adb -s $serial $command')).outLines.toList();
  }

  /// Runs `adb -s [serial] [command]` and returns the first
  /// [ProcessResult]. Throws if the command exits with a non-zero code.
  Future<ProcessResult> runAdbCommand(String command) async {
    return (await shell.run('adb -s $serial $command')).first;
  }

  /// Runs `adb -s [serial] [command]` and returns the first
  /// [ProcessResult], without throwing if the command exits with a
  /// non-zero code.
  Future<ProcessResult> runAdbCommandNoThrow(String command) async {
    return (await shellNoThrow.run('adb -s $serial $command')).first;
  }

  /// Checks whether [androidLocation] exists on the device, via
  /// `adb shell ls`.
  ///
  /// Returns `true` if the path exists, `false` otherwise.
  Future<bool> fileExists(String androidLocation) async {
    var result = await runAdbCommandNoThrow('shell ls $androidLocation');
    // ls: /storage/emulated/0/Android/data/com.hublot.loves.football.ucl2022.dev/files/Documents/fan_dnk_dummy: No such file or directory
    // exit code 1
    if (result.exitCode == 1) {
      return false;
    }
    return result.outLines.isNotEmpty;
  }

  /// Pulls the directory at [androidFrom] on the device into [localTo] on
  /// the local machine, creating [localTo] (and any missing parents) first.
  Future<void> pullDirectory(String androidFrom, String localTo) async {
    await Directory(localTo).create(recursive: true);
    await runAdbCommandOutLines('pull $androidFrom $localTo');
  }

  /// Pushes the local directory at [localFrom] to [androidTo] on the
  /// device.
  Future<void> pushDirectory(String localFrom, String androidTo) async {
    await runAdbCommandOutLines('push $localFrom $androidTo');
  }

  /// Runs `adb shell dumpsys package [packageName]` on the device and
  /// parses its output.
  ///
  /// Returns a [DumpsysPackageResult] whose [DumpsysPackageResult.packageInfo]
  /// is `null` if [packageName] isn't installed or the output couldn't be
  /// parsed.
  Future<DumpsysPackageResult> getDumpsysPackageInfo(String packageName) async {
    var lines = await runAdbCommandOutLines(
      'shell dumpsys package $packageName',
    );
    return adbDumpsysPackageParseLines(lines);
  }
}

/// Package information from `adb shell dumpsys package`
class AdbPackageInfo {
  /// package name
  final String packageName;

  /// version name
  final String versionName;

  /// version code
  final int versionCode;

  /// Creates an instance of [AdbPackageInfo].
  AdbPackageInfo(this.packageName, this.versionName, this.versionCode);

  @override
  String toString() {
    return 'AdbPackageInfo{packageName: $packageName, versionName: $versionName, versionCode: $versionCode}';
  }
}

/// Package information from `adb shell dumpsys package` command
class DumpsysPackageInfo {
  /// Package name
  final String packageName;

  /// Version name
  final String versionName;

  /// Version code
  final int versionCode;

  /// Minimum SDK version
  final int minSdkVersion;

  /// Target SDK version
  final int targetSdkVersion;

  /// Creates an instance of [DumpsysPackageInfo].
  DumpsysPackageInfo({
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.minSdkVersion,
    required this.targetSdkVersion,
  });
}

/// Result of `adb shell dumpsys package` command
class DumpsysPackageResult {
  /// Package information if available
  final DumpsysPackageInfo? packageInfo;

  /// Creates an instance of [DumpsysPackageResult].
  DumpsysPackageResult({this.packageInfo});
}

/// Parses [lines] — the stdout of `adb shell dumpsys package <name>` — to
/// extract the package's version and SDK information.
///
/// Returns a [DumpsysPackageResult] whose [DumpsysPackageResult.packageInfo]
/// is `null` if the expected `Packages:` / `Package [...]` sections aren't
/// found in [lines].
DumpsysPackageResult adbDumpsysPackageParseLines(List<String> lines) {
  String levelPrefix(int level) {
    return '  ' * level;
  }

  int findLevelSection(int level, List<String> lines, String section) {
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('${levelPrefix(level)}$section')) {
        return i;
      }
    }
    return -1;
  }

  var packagesIndex = findLevelSection(0, lines, 'Packages:');
  DumpsysPackageInfo? packageInfo;
  if (packagesIndex > -1) {
    var subLines = lines.sublist(packagesIndex + 1);
    // Package [com.tekartik.package1] (da25746):
    var pkgLineIndex = findLevelSection(1, subLines, 'Package [');

    if (pkgLineIndex > -1) {
      var line = subLines[pkgLineIndex];
      var start = line.indexOf('[');
      if (start > 1) {
        var packageName = line.substring(start + 1, line.indexOf(']')).trim();
        // versionCode=20 minSdk=27 targetSdk=36
        var versionCodeIndex = findLevelSection(2, subLines, 'versionCode=');
        if (versionCodeIndex > -1) {
          var map = <String, String>{};
          void feedMap(String line) {
            var parts = line.trim().split(' ');
            for (var part in parts) {
              var keyValue = part.split('=');
              if (keyValue.length == 2) {
                var key = keyValue[0].trim();
                var value = keyValue[1].trim();
                map[key] = value;
              }
            }
          }

          feedMap(subLines[versionCodeIndex]);
          var versionNameIndex = findLevelSection(2, subLines, 'versionName=');
          if (versionNameIndex > -1) {
            feedMap(subLines[versionNameIndex]);
          }
          packageInfo = DumpsysPackageInfo(
            packageName: packageName,
            versionName: map['versionName'] ?? '',
            versionCode: int.tryParse(map['versionCode'] ?? '') ?? 0,
            minSdkVersion: int.tryParse(map['minSdk'] ?? '') ?? 0,
            targetSdkVersion: int.tryParse(map['targetSdk'] ?? '') ?? 0,
          );
        }
      }
    }
  }
  var result = DumpsysPackageResult(packageInfo: packageInfo);
  return result;
}
