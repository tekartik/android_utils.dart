import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/bin/keystore.dart';

Future main() async {
  var file = keystorePath;
  await Directory(dirname(file)).create(recursive: true);

  var shell = Shell(stdin: sharedStdIn);
  // TODO password!
  await shell.run(
      'keytool -genkey -v -keystore $file -alias app -keyalg RSA -keysize 2048 -validity 30000');
  await sharedStdIn.terminate();
}
