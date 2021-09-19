import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';

const String envRc = 'android_env.rc';

Future<void> main(List<String> arguments) async {
  var parser = ArgParser()
    ..addFlag('env',
        help:
            'Write env source file and output its name (Mac/Linux). Usage: source \$(android_build_environment --env)');
  var result = parser.parse(arguments);
  var context = await getAndroidBuildContent();

  if (result['env'] as bool) {
    var env = await getAndroidBuildEnvironment(context: context);
    final dst = File(join(Directory.systemTemp.path, envRc));
    final content = '''
# Add path
export PATH=${env.paths.join(':')}:\$PATH
''';
    try {
      await dst.writeAsString(content);
      stdout.write(dst.path);
    } catch (e) {
      stderr.writeln('Failed to write to $dst');
    }
  } else {
    print('                androidSdkPath: ${context.androidSdkPath}');
    print('             androidStudioPath: ${context.androidStudioPath}');
    print('          androidStudioJdkPath: ${context.androidStudioJdkPath}');
    print(
        '      androidSdkBuildToolsPath: ${context.androidSdkBuildToolsPath}');
    print(
        '   androidSdkPlatformToolsPath: ${context.androidSdkPlatformToolsPath}');
    print('           androidSdkToolsPath: ${context.androidSdkToolsPath}');
    print(
        'androidSdkCommandLineToolsPath: ${context.androidSdkCommandLineToolsPath}');
    print('                    sdkVersion: ${context.sdkVersion}');

    await initAndroidBuildEnvironment();
    print('');
    print('sdkmanager: ${await which('sdkmanager')}');
    print('      java: ${await which('java')}');
  }
}
