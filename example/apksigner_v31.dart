import 'dart:async';

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

Future main() async {
  var env = await getAndroidBuildEnvironment(sdkVersion: 31);
  print(await which('apksigner', environment: env));
}
