/// Apk information.
class ApkInfo {
  /// Package name.
  String? name;

  /// Version name (1.0.0)
  String? versionName;

  /// Integer
  String? versionCode;

  /// Creates an instance of [ApkInfo].
  ApkInfo({this.name, this.versionName, this.versionCode});

  /// Debug to map
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
