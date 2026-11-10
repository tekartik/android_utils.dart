@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/avd_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:test/test.dart';

/// Build context and avd tests on fake trees in a temp folder, with the
/// environment (sdk, avd home, user home) set through process_run.
void main() {
  late Directory top;
  late Map<String, String> savedPlatformEnvironment;
  setUp(() async {
    top = await Directory.systemTemp.createTemp('android_utils_env');
    savedPlatformEnvironment = Map.of(platformEnvironment);
  });
  tearDown(() async {
    // Also resets shellEnvironment
    platformEnvironment = savedPlatformEnvironment;
    await top.delete(recursive: true);
  });

  void setEnvVars(Map<String, String> vars) {
    shellEnvironment = ShellEnvironment(
      environment: {...platformEnvironment, ...vars},
    );
  }

  group('build context', () {
    test('sdk without build-tools', () async {
      var sdk = join(top.path, 'sdk');
      await Directory(
        join(sdk, 'cmdline-tools', 'latest'),
      ).create(recursive: true);
      setEnvVars({'ANDROID_SDK_ROOT': sdk});
      var context = await getAndroidBuildContext();
      expect(context.androidSdkPath, sdk);
      expect(context.androidSdkBuildToolsPath, isNull);
      expect(context.sdkVersion, isNull);
      expect(
        context.androidSdkCommandLineToolsPath,
        join(sdk, 'cmdline-tools', 'latest'),
      );
    });

    test('android studio jdk in jbr', () async {
      var home = join(top.path, 'home');
      var studio = join(top.path, 'android-studio');
      await Directory(join(studio, 'bin')).create(recursive: true);
      await Directory(join(studio, 'jbr', 'bin')).create(recursive: true);
      var desktop = File(
        join(
          home,
          '.local',
          'share',
          'applications',
          'jetbrains-studio.desktop',
        ),
      );
      await desktop.parent.create(recursive: true);
      await desktop.writeAsString(
        '[Desktop Entry]\nExec="${join(studio, 'bin', 'studio.sh')}" %f\n',
      );
      platformEnvironment = {
        ...savedPlatformEnvironment,
        'TEKARTIK_PROCESS_RUN_USER_HOME_PATH': home,
      };
      var context = await getAndroidBuildContext();
      expect(context.androidStudioPath, studio);
      expect(context.androidStudioJdkPath, join(studio, 'jbr'));
    }, testOn: 'linux');
  });

  group('moveAvdFolder', () {
    late String avdHome;
    late String avdDir;
    setUp(() async {
      avdHome = join(top.path, 'avd');
      avdDir = join(avdHome, 'probe.avd');
      await Directory(avdDir).create(recursive: true);
      await File(join(avdDir, 'config.ini')).writeAsString('x');
      await File(
        join(avdHome, 'probe.ini'),
      ).writeAsString('avd.ini.encoding=UTF-8\npath=$avdDir\n');
      setEnvVars({'ANDROID_AVD_HOME': avdHome});
    });

    test('force onto its own folder (trailing slash)', () async {
      await moveAvdFolder(avd: 'probe', dst: '$avdHome/', force: true);
      expect(File(join(avdDir, 'config.ini')).existsSync(), isTrue);
    });

    test('force onto its own folder (relative)', () async {
      await moveAvdFolder(avd: 'probe', dst: relative(avdHome), force: true);
      expect(File(join(avdDir, 'config.ini')).existsSync(), isTrue);
    });

    test('relative dst, absolute path in the ini file', () async {
      var dst = join(top.path, 'other');
      await Directory(dst).create();
      await moveAvdFolder(avd: 'probe', dst: relative(dst));
      expect(File(join(dst, 'probe.avd', 'config.ini')).existsSync(), isTrue);
      expect(Directory(avdDir).existsSync(), isFalse);
      var ini = await File(join(avdHome, 'probe.ini')).readAsString();
      expect(ini, contains('path=${join(dst, 'probe.avd')}'));
    });
  });
}
