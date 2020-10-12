import 'package:process_run/shell_run.dart';
import 'package:tekartik_android_utils/build_utils.dart';

import 'build_utils.dart';

class AdbDeviceInfo {
  String serial;
  String type;
  String product;
  String model;
  String device;
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
