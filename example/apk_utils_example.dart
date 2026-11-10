import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future main() async {
  // aapt is in the SDK build-tools: put them on the PATH first.
  await initAndroidBuildEnvironment();
  var apkInfo = await getApkInfo(join('test', 'data', 'app-release.apk'));
  stdout.writeln(apkInfo);
}
