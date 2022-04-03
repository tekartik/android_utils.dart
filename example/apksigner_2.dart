import 'dart:async';

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

Future main() async {
  await initAndroidBuildEnvironment();
  print(await which('apksigner'));
}
