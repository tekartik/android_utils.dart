import 'dart:async';
import 'dart:io' show stdout;

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

Future main() async {
  var env = await getAndroidBuildEnvironment();
  stdout.writeln(await which('aapt', environment: env));
}
