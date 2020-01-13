class ApkInfo {
  String name;
  String versionName;
  String versionCode;

  ApkInfo({this.name, this.versionName, this.versionCode});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'versionName': versionName,
      'versionCode': versionCode
    };
    return map;
  }

  @override
  String toString() => toMap().toString();
}
