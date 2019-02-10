import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';

Future main() async {
  var apkInfo = await getApkInfo(join('test', 'data', 'app-release.apk'));
  print(apkInfo);
}
