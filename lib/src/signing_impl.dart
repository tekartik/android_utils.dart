import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';

import 'project_impl.dart';

class SigningOptions {
  /// File name in Android module
  final String keystore;
  final String password;

  SigningOptions({required this.keystore, required this.password});
}

const keystoreAliasDefault = 'app';

class KeytoolGenKeyOptions {
  final String alias;
  final String? firstAndLastName;
  final String? organizationUnit;
  final String? organization;
  final String? cityOrLocality;
  final String? stateOrProvince;
  final String? countryCode;

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

extension AndroidModuleSigningExt on AndroidModule {
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

    var dnames =
        [
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

  Future<void> printKeyInfo({required SigningOptions signinOptions}) async {
    var keystore = signinOptions.keystore;
    var password = signinOptions.password;
    var shell = Shell().cd(join(project.path, module));
    await shell.run(
      'keytool -list -v -keystore $keystore -storepass $password',
    );
  }

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
}
