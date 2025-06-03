import 'dart:async';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

Future main() async {
  await initAndroidBuildEnvironment();
  stdout.writeln(await which('apksigner'));
}
