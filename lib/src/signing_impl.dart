import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';

import 'project_impl.dart';

/// Signing options for Android module
class SigningOptions {
  /// File name in Android module
  final String keystore;

  /// Password for the keystore
  final String password;

  /// Creates an instance of [SigningOptions]
  SigningOptions({required this.keystore, required this.password});
}

/// Default alias for the keystore
const keystoreAliasDefault = 'app';

/// Options for generating a key using keytool
class KeytoolGenKeyOptions {
  /// Default alias for the keystore
  final String alias;

  /// Full name of the user
  final String? firstAndLastName;

  /// Organization unit of the user
  final String? organizationUnit;

  /// Organization of the user
  final String? organization;

  /// City or locality of the user
  final String? cityOrLocality;

  /// State or province of the user
  final String? stateOrProvince;

  /// Country code of the user (2 letters)
  final String? countryCode;

  /// Creates an instance of [KeytoolGenKeyOptions]
  KeytoolGenKeyOptions({
    this.alias = keystoreAliasDefault,
    this.firstAndLastName,
    this.organizationUnit,
    this.organization,
    this.cityOrLocality,
    this.stateOrProvince,
    this.countryCode,
  }); // 2 letters
}

/// Extension on [AndroidModule] to handle signing operations
extension AndroidModuleSigningExt on AndroidModule {
  /// Generates a key in the Android module using keytool
  Future<void> generateKey({
    required SigningOptions signinOptions,
    required KeytoolGenKeyOptions keytoolGenOptions,
  }) async {
    var keystore = signinOptions.keystore;
    var password = signinOptions.password;
    var shell = Shell().cd(join(project.path, module));
    String? dname(String key, String? value) {
      if (value != null) {
        return '$key=${shellArgument(value)}';
      }
      return null;
    }

    var dnames = [
      dname('CN', keytoolGenOptions.firstAndLastName),
      dname('OU', keytoolGenOptions.organizationUnit),
      dname('O', keytoolGenOptions.organization),
      dname('L', keytoolGenOptions.cityOrLocality),
      dname('ST', keytoolGenOptions.stateOrProvince),
      dname('C', keytoolGenOptions.countryCode),
    ].nonNulls;
    await shell.run(
      'keytool -genkey -v -keystore $keystore -storepass $password'
      ' -alias ${keytoolGenOptions.alias} -keypass $password -keyalg RSA -keysize 2048'
      '${dnames.isNotEmpty ? ' -dname ${dnames.join(',')}' : ''}'
      ' -validity 100000',
    );
  }

  /// Prints the key information from the keystore
  Future<void> printKeyInfo({required SigningOptions signinOptions}) async {
    var keystore = signinOptions.keystore;
    var password = signinOptions.password;
    var shell = Shell().cd(join(project.path, module));
    await shell.run(
      'keytool -list -v -keystore $keystore -storepass $password',
    );
  }

  /// Prints the Gradle configuration for signing the Android module
  Future<void> printGradleConfig({
    required SigningOptions signinOptions,
    String alias = keystoreAliasDefault,
  }) async {
    stdout.writeln('''
    signingConfigs {
        release {
            keyAlias $alias
            keyPassword '${signinOptions.password}'
            storeFile file(${signinOptions.keystore}')
            storePassword '${signinOptions.password}'
        }
    }
    buildTypes {
        debug {
            signingConfig signingConfigs.release
        }
        release {
            signingConfig signingConfigs.release
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
    ''');
  }

  /// Prints the Gradle Kotlin DSL configuration for signing the Android module
  Future<void> printGradleConfigKts({
    required SigningOptions signinOptions,
    String alias = keystoreAliasDefault,
  }) async {
    stdout.writeln('''
    signingConfigs {
        create("release") {
            keyAlias = "$alias"
            keyPassword = "${signinOptions.password}"
            storeFile = file("${signinOptions.keystore}")
            storePassword = "${signinOptions.password}"
        }
    }
    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
    ''');
  }
}
