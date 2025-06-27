import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

/// See https://developer.android.com/studio/command-line/variables
Future<void> main(List<String> arguments) async {
  var parser = ArgParser()
    ..addFlag(
      'env',
      help:
          'Write env source file and output its name (Mac/Linux/Windows).\n'
          'Usage: . \$(android_build_environment --env)',
    )
    ..addFlag('help', abbr: 'h', help: 'Usage help', negatable: false);
  var result = parser.parse(arguments);

  var help = result['help'] as bool;

  void usage() {
    stdout.writeln('android_build_environment');
    stdout.writeln(parser.usage);
  }

  if (help) {
    usage();
    return;
  }

  var context = await getAndroidBuildContext();

  if (result['env'] as bool) {
    // Test locally on windows/mac/linux:
    // which java
    // . $(dart run bin/android_build_environment.dart --env)
    // which java
    var envRc = Platform.isWindows ? 'android_env.ps1' : 'android_env.rc';

    var env = await getAndroidBuildEnvironment(context: context);
    final dst = File(join(Directory.systemTemp.path, envRc));
    final content = Platform.isWindows
        ?
          // https://stackoverflow.com/questions/714877/setting-windows-powershell-environment-variables
          '''
# Add Android path
\$ENV:PATH="${env.paths.join(';')};\$ENV:PATH"
'''
        : '''
# Add Android path
export PATH="${env.paths.join(':')}:\$PATH"
''';
    try {
      await dst.writeAsString(content);
      stdout.write(dst.path);
    } catch (e) {
      stderr.writeln('Failed to write to $dst');
    }
  } else {
    stdout.writeln('                androidSdkPath: ${context.androidSdkPath}');
    stdout.writeln(
      '             androidStudioPath: ${context.androidStudioPath}',
    );
    stdout.writeln(
      '          androidStudioJdkPath: ${context.androidStudioJdkPath}',
    );
    stdout.writeln(
      '      androidSdkBuildToolsPath: ${context.androidSdkBuildToolsPath}',
    );
    stdout.writeln(
      '   androidSdkPlatformToolsPath: ${context.androidSdkPlatformToolsPath}',
    );
    stdout.writeln(
      '           androidSdkToolsPath: ${context.androidSdkToolsPath}',
    );
    stdout.writeln(
      'androidSdkCommandLineToolsPath: ${context.androidSdkCommandLineToolsPath}',
    );
    stdout.writeln(
      '            androidAvdHomePath: ${context.androidAvdHomePath}',
    );
    stdout.writeln('                    sdkVersion: ${context.sdkVersion}');

    await initAndroidBuildEnvironment();
    stdout.writeln('');
    stdout.writeln('sdkmanager: ${await which('sdkmanager')}');
    stdout.writeln('      java: ${await which('java')}');
  }
}
