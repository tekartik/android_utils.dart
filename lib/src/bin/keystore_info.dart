import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/bin/keystore.dart';

import 'keystore.dart' as ks;

Future<void> main() async {
  await dumpKeystoreInfo(keystorePath: ks.keystorePath);
}

Future<void> dumpKeystoreInfo({required String keystorePath}) async {
  var file = keystorePath;
  if (!File(file).existsSync()) {
    stderr.writeln('Missing keystore file $file');
    exit(1);
  }
  var credentials = credentialsFromEnv;
  if (credentials == null) {
    stderr.writeln('Missing credentials from env');
    exit(1);
  }
  var shell = Shell();
  var outLines = (await shell.run(
    'keytool -list -v -keystore $file -storepass ${credentials.password}',
  )).outLines;
  await File(
    join(dirname(file), 'keystore_info.txt'),
  ).writeAsString(outLines.join('\n'));
}
