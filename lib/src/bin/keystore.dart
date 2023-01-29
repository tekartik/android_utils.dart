import 'dart:io';

import 'package:dev_test/build_support.dart' show checkAndActivatePackage;
import 'package:path/path.dart';
import 'package:process_run/shell.dart';

class KeystoreCredentials {
  String? password;
}

KeystoreCredentials? get credentialsFromEnv {
  var password = shellEnvironment['TEKARTIK_KEYSTORE_PASSWORD'];
  if (password != null) {
    return KeystoreCredentials()..password = password;
  }
  return null;
}

// Allow direct test.
Future<void> main() async {
  await enterCredentials();
}

Future<void> enterCredentials() async {
  var credentials = credentialsFromEnv;
  var existing = credentials?.password;
  var password =
      await prompt('Enter password${existing != null ? '[$existing]' : ''}');
  if (password.length >= 8) {
    await checkAndActivatePackage('process_run');
    await Shell().run(
        'pub global run process_run:shell env var set TEKARTIK_KEYSTORE_PASSWORD $password');
  } else {
    stderr.writeln('Password too short');
  }
  await promptTerminate();
}

String get keystorePath => join('.local', 'keystore.jks');
