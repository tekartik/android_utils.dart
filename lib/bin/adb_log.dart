import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/adb_log.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main(List<String> arguments) async {
  var parser =
      ArgParser()
        ..addOption(
          'serial',
          abbr: 's',
          valueHelp:
              'use device with given serial (overrides \$ANDROID_SERIAL).\nany:<ip> can be used to find device by ip',
        )
        ..addOption('package', abbr: 'p', valueHelp: 'Package name')
        ..addFlag('help', abbr: 'h', help: 'Usage help', negatable: false)
        ..addFlag('verbose', abbr: 'v', help: 'Verbose mode', negatable: false);
  var results = parser.parse(arguments);

  var help = results['help'] as bool;

  void usage() {
    stdout.writeln('android_build_environment');
    stdout.writeln(parser.usage);
  }

  if (help) {
    usage();
    return;
  }
  await initAndroidBuildEnvironment();
  var env = ShellEnvironment();

  var serial = results['serial'] as String? ?? env[globalSerialIdEnvKey];
  var package = results['package'] as String? ?? env[globalPackageNameEnvKey];
  var verbose = results['verbose'] as bool;

  if (serial != null) {
    stdout.writeln('serial: $serial');
  }
  if (package != null) {
    stdout.writeln('package: $package');
  }
  var options = AdbLogOptions(
    package: package,
    serial: serial,
    verbose: verbose,
  );

  await adbLog(options);
}

const globalSerialIdEnvKey = 'TK_ANDROID_UTILS_SERIAL_DEFAULT';
const globalPackageNameEnvKey = 'TK_ANDROID_UTILS_PACKAGE_NAME_DEFAULT';
// ds env vars set TK_ANDROID_UTILS_PACKAGE_NAME_DEFAULT xxx
