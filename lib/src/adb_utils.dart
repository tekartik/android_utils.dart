import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:tekartik_android_utils/build_utils.dart';

import 'build_utils.dart';

class AdbDeviceInfo {
  String? serial;
  String? type;
  String? product;
  String? model;
  String? device;
}

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

class DeviceAdb {
  final String serial;
  var shell = Shell();
  var shellNoThrow = Shell(throwOnError: false);
  DeviceAdb(this.serial);

  Future<List<String>> runAdbCommandOutLines(String command) async {
    return (await shell.run('adb -s $serial $command')).outLines.toList();
  }

  Future<ProcessResult> runAdbCommand(String command) async {
    return (await shell.run('adb -s $serial $command')).first;
  }

  Future<ProcessResult> runAdbCommandNoThrow(String command) async {
    return (await shellNoThrow.run('adb -s $serial $command')).first;
  }

  Future<bool> fileExists(String androidLocation) async {
    var result = await runAdbCommandNoThrow('shell ls $androidLocation');
    // ls: /storage/emulated/0/Android/data/com.hublot.loves.football.ucl2022.dev/files/Documents/fan_dnk_dummy: No such file or directory
    // exit code 1
    if (result.exitCode == 1) {
      return false;
    }
    return result.outLines.isNotEmpty;
  }

  Future<void> pullDirectory(String androidFrom, String localTo) async {
    await Directory(localTo).create(recursive: true);
    await runAdbCommandOutLines('pull $androidFrom $localTo');
  }

  Future<void> pushDirectory(String localFrom, String androidTo) async {
    await runAdbCommandOutLines('push $localFrom $androidTo');
  }
}
