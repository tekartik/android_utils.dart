import 'dart:async';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

Future main() async {
  var env = await getAndroidBuildEnvironment(sdkVersion: 31);
  stdout.writeln(await which('apksigner', environment: env));
}
