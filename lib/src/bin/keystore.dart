import 'dart:io';

import 'package:dev_build/build_support.dart' show checkAndActivatePackage;
import 'package:path/path.dart';
import 'package:process_run/shell.dart';

/// Keystore credentials management.
class KeystoreCredentials {
  /// The password for the keystore.
  String? password;
}

/// Get the keystore credentials from the environment variable TEKARTIK_KEYSTORE_PASSWORD.
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

/// Prompt the user to enter a password and store it in the environment variable TEKARTIK_KEYSTORE_PASSWORD.
Future<void> enterCredentials() async {
  var credentials = credentialsFromEnv;
  var existing = credentials?.password;
  var password = await prompt(
    'Enter password${existing != null ? '[$existing]' : ''}',
  );
  if (password.length >= 8) {
    await checkAndActivatePackage('process_run');
    await Shell().run(
      'dart pub global run process_run:shell env var set TEKARTIK_KEYSTORE_PASSWORD $password',
    );
  } else {
    stderr.writeln('Password too short');
  }
  await promptTerminate();
}

/// Get the path to the keystore file.
String get keystorePath => join('.local', 'keystore.jks');
