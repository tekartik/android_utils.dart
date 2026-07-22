/// Information about an Android apk, as read from `aapt dump badging` (see
/// `getApkInfo`) or an app manifest.
class ApkInfo {
  /// Package name (e.g. `com.example.app`).
  String? name;

  /// Human-readable version name (e.g. `'1.0.0'`).
  String? versionName;

  /// Version code, as a numeric string (e.g. `'42'`).
  String? versionCode;

  /// Creates apk info from the given [name], [versionName] and
  /// [versionCode], each defaulting to `null` when not known.
  ApkInfo({this.name, this.versionName, this.versionCode});

  /// Converts this info to a `{name, versionName, versionCode}` map, mainly
  /// for debugging/logging via [toString].
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'versionName': versionName,
      'versionCode': versionCode,
    };
    return map;
  }

  @override
  String toString() => toMap().toString();
}
