

// package: name='com.inventhys.elfinfo.app' versionCode='2' versionName='0.1' platformBuildVersionName=''

import 'apk_info.dart';

String _get(String line, String key) {
  String prefix = " ${key}='";
  int index = line.indexOf(prefix);
  if (index != -1) {
    String value = line.substring(index + prefix.length);
    int endIndex = value.indexOf("'");
    if (endIndex != -1) {
      return value.substring(0, endIndex);
    }
  }
  return null;

}
ApkInfo parseBadgingLine(String line) {
  if (line.startsWith('package:')) {
    String name = _get(line, "name");
    String versionName = _get(line, "versionName");
    String versionCode = _get(line, "versionCode");

    if (name != null && versionName != null && versionCode != null) {
      return new ApkInfo(name, versionName, versionCode);
    }
  }
  return null;
}