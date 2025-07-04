import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:tekartik_android_utils/build_utils.dart';

import 'build_utils.dart';

/// Check if adb is supported
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

/// Parses the output lines from `adb devices -l` command to extract device information.
List<AdbDeviceInfo> adbDeviceInfosParseLines(Iterable<String> lines) {
  var list = <AdbDeviceInfo>[];

  var listStarted = false;
  for (var line in lines) {
    if (line.startsWith('List of')) {
      listStarted = true;
      continue;
    } else if (listStarted) {
      var parts = line
          .split(' ')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.length > 4) {
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
                info.product = value;
                break;
              case 'device':
                info.product = value;
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

/// [initAndroidBuildEnvironment] must have been called first
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

  /// Creates an instance of [DeviceAdb] with the specified serial number.
  DeviceAdb(this.serial);

  /// Run an ADB command and return the output lines
  Future<List<String>> runAdbCommandOutLines(String command) async {
    return (await shell.run('adb -s $serial $command')).outLines.toList();
  }

  /// Run an ADB command and return the first [ProcessResult]
  Future<ProcessResult> runAdbCommand(String command) async {
    return (await shell.run('adb -s $serial $command')).first;
  }

  /// Run an ADB command without throwing on error and return the first [ProcessResult]
  Future<ProcessResult> runAdbCommandNoThrow(String command) async {
    return (await shellNoThrow.run('adb -s $serial $command')).first;
  }

  /// Check if a file exists on the device
  Future<bool> fileExists(String androidLocation) async {
    var result = await runAdbCommandNoThrow('shell ls $androidLocation');
    // ls: /storage/emulated/0/Android/data/com.hublot.loves.football.ucl2022.dev/files/Documents/fan_dnk_dummy: No such file or directory
    // exit code 1
    if (result.exitCode == 1) {
      return false;
    }
    return result.outLines.isNotEmpty;
  }

  /// Pull a directory from the device to the local machine
  Future<void> pullDirectory(String androidFrom, String localTo) async {
    await Directory(localTo).create(recursive: true);
    await runAdbCommandOutLines('pull $androidFrom $localTo');
  }

  /// Push a directory from the local machine to the device
  Future<void> pushDirectory(String localFrom, String androidTo) async {
    await runAdbCommandOutLines('push $localFrom $androidTo');
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
