import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';

import 'project_impl.dart';

/// Keystore location and password shared by the signing operations in
/// [AndroidModuleSigningExt].
class SigningOptions {
  /// Keystore file name/path, relative to the module directory.
  final String keystore;

  /// Password protecting both the keystore and the signing key.
  final String password;

  /// Creates signing options pointing at [keystore], protected by
  /// [password].
  SigningOptions({required this.keystore, required this.password});
}

/// Default keystore alias (`'app'`), used when none is given explicitly.
const keystoreAliasDefault = 'app';

/// Options passed to `keytool -genkey` by
/// [AndroidModuleSigningExt.generateKey], to fill in the certificate's
/// distinguished name.
class KeytoolGenKeyOptions {
  /// Alias to store the generated key under, defaults to
  /// [keystoreAliasDefault].
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

  /// Creates key-generation options. [alias] defaults to
  /// [keystoreAliasDefault]; the distinguished-name fields
  /// ([firstAndLastName], [organizationUnit], [organization],
  /// [cityOrLocality], [stateOrProvince], [countryCode]) default to `null`
  /// and are omitted from the generated certificate's `-dname` when unset.
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

/// Signing-related operations available on an [AndroidModule], all of which
/// run `keytool` (or print Gradle config) from the module's directory.
extension AndroidModuleSigningExt on AndroidModule {
  /// Generates a new signing key/keystore via `keytool -genkey`, using
  /// [signinOptions] for the keystore location/password and
  /// [keytoolGenOptions] for the key alias and certificate identity
  /// fields.
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

  /// Prints the certificate details of the keystore described by
  /// [signinOptions], via `keytool -list -v`.
  Future<void> printKeyInfo({required SigningOptions signinOptions}) async {
    var keystore = signinOptions.keystore;
    var password = signinOptions.password;
    var shell = Shell().cd(join(project.path, module));
    await shell.run(
      'keytool -list -v -keystore $keystore -storepass $password',
    );
  }

  /// Prints a Groovy Gradle (`build.gradle`) `signingConfigs`/`buildTypes`
  /// snippet wiring [signinOptions]' keystore/password and [alias]
  /// (defaults to [keystoreAliasDefault]) into the `release` signing
  /// config, reused by the `debug` build type.
  Future<void> printGradleConfig({
    required SigningOptions signinOptions,
    String alias = keystoreAliasDefault,
  }) async {
    stdout.writeln('''
    signingConfigs {
        release {
            keyAlias $alias
            keyPassword '${signinOptions.password}'
            storeFile file('${signinOptions.keystore}')
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

  /// Prints the Gradle Kotlin DSL (`build.gradle.kts`) equivalent of
  /// [printGradleConfig], wiring [signinOptions]' keystore/password and
  /// [alias] (defaults to [keystoreAliasDefault]) into the `release`
  /// signing config, reused by the `debug` build type.
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
