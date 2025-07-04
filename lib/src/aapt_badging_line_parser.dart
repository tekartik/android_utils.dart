import 'apk_info.dart';

String? _get(String line, String key) {
  var prefix = " $key='";
  var index = line.indexOf(prefix);
  if (index != -1) {
    var value = line.substring(index + prefix.length);
    var endIndex = value.indexOf("'");
    if (endIndex != -1) {
      return value.substring(0, endIndex);
    }
  }
  return null;
}

/// Parses a line from the output of the `aapt` command to extract APK information.
ApkInfo? parseBadgingLine(String line) {
  if (line.startsWith('package:')) {
    var name = _get(line, 'name');
    var versionName = _get(line, 'versionName');
    var versionCode = _get(line, 'versionCode');

    if (name != null && versionName != null && versionCode != null) {
      return ApkInfo(
        name: name,
        versionName: versionName,
        versionCode: versionCode,
      );
    }
  }
  return null;
}
