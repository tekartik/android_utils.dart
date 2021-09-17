import 'package:args/args.dart';
import 'package:tekartik_android_utils/adb_log.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

Future<void> main(List<String> arguments) async {
  var argParser = ArgParser()
    ..addOption('serial',
        abbr: 's',
        valueHelp:
            'use device with given serial (overrides \$ANDROID_SERIAL). any:<ip> can be used to find device by ip')
    ..addOption('package', abbr: 'p', valueHelp: 'Package name');
  var argResult = argParser.parse(arguments);
  var serial = argResult['serial'] as String?;
  var package = argResult['package'] as String?;

  serial = devWarning('any:5555');
  package = devWarning('com.hublot.produscan');
  var options = AdbLogOptions(package: package, serial: serial);
  await adbLog(options);
}
