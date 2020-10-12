import 'package:process_run/shell_run.dart';
import 'package:tekartik_android_utils/build_utils.dart';

class AvdInfo {
  String name;
  String device;
  String path;
  String target;
  String skin;
  String sdCard;
}

List<AvdInfo> avdInfosParseLines(Iterable<String> lines) {
  var list = <AvdInfo>[];
  AvdInfo avdInfo;
  String key;
  String value;

  void validatePreviousValue() {
    if (avdInfo != null && key != null && value != null) {
      switch (key) {
        case 'name':
          avdInfo.name = value;
          break;
        case 'device':
          avdInfo.device = value;
          break;
        case 'path':
          avdInfo.path = value;
          break;
        case 'target':
          avdInfo.target = value;
          break;
        case 'skin':
          avdInfo.skin = value;
          break;
        case 'sdcard':
          avdInfo.sdCard = value;
          break;
      }
      key = null;
      value = null;
    }
  }

  void validatePreviousAvd() {
    if (avdInfo != null && avdInfo.name != null) {
      list.add(avdInfo);
      avdInfo = null;
    }
  }

  for (var line in lines) {
    if (line.startsWith('----')) {
      validatePreviousValue();
      validatePreviousAvd();
    }
    avdInfo ??= AvdInfo();
    var parts = line.split(':');

    if (parts[0].length < 10) {
      validatePreviousValue();
      key = parts[0].toLowerCase().trim();
    }
    if (parts.length > 1) {
      var partValue = parts.sublist(1).join(':').trim();
      if (value != null) {
        value += '\n$partValue';
      } else {
        value = partValue;
      }
    }
  }
  validatePreviousValue();
  validatePreviousAvd();
  return list;
}

/// [initAndroidBuildEnvironment] must have been called first
Future<List<AvdInfo>> getAvdInfos() async {
  var lines = (await run('avdmanager list avd')).outLines;
  return avdInfosParseLines(lines);
}
