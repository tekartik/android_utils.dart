import 'dart:async';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

Future main() async {
  var env = await getAndroidBuildEnvironment();
  stdout.writeln(await which('emulator', environment: env));
  var shell = Shell(environment: env);

  await shell.run('emulator -version');
}
