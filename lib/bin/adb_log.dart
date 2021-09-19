import 'package:args/args.dart';
import 'package:tekartik_android_utils/adb_log.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

Future<void> main(List<String> arguments) async {
  var parser = ArgParser()
    ..addOption('serial',
        abbr: 's',
        valueHelp:
            'use device with given serial (overrides \$ANDROID_SERIAL).\nany:<ip> can be used to find device by ip')
    ..addOption('package', abbr: 'p', valueHelp: 'Package name')
    ..addFlag('help', abbr: 'h', help: 'Usage help', negatable: false);
  var results = parser.parse(arguments);

  var help = results['help'] as bool;

  void _usage() {
    print('android_build_environment');
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }
  var serial = results['serial'] as String?;
  var package = results['package'] as String?;

  var options = AdbLogOptions(package: package, serial: serial);
  await adbLog(options);
}
