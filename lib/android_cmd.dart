import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';

ProcessCmd _adbCmd(List<String?> args) {
  return ProcessCmd('adb', args as List<String>);
}

/// Creates an adb command with the given arguments.
ProcessCmd adbCmd(List<String> args) => _adbCmd(args);

/// adb monkey command arguments.
List<String> adbMonkeyArgs({
  String? packageName,
  int? count,
  int sysKeysPercent = 0,
}) {
  count ??= 50000;
  var args = <String>[
    'shell',
    'monkey',
    if (packageName != null) ...['-p', packageName],
    ...['--pct-syskeys', '$sysKeysPercent'],
    '$count',
  ];

  return args;
}

/// Default emulator serial number.
const String defaultEmulatorSerialNumber = 'emulator-5554';

/// Kills the emulator with the given name.
// http://stackoverflow.com/questions/20155376/android-stop-emulator-from-command-line
// adb -s emulator-5554 emu kill
ProcessCmd adbKillEmulator({String? emulatorName}) {
  emulatorName ??= defaultEmulatorSerialNumber;
  return ProcessCmd('adb', ['-s', emulatorName, 'emu', 'kill']);
}

/// View processes on the device.
List<String> shellPsAdbArgs() {
  return ['shell', 'ps'];
}

/// Kills the process with the given PID on the device.
List<String> shellKill(int pid) {
  return ['shell', 'kill', '$pid'];
}

/// Obsolete: Use [DeviceAdb] instead.
/// Adb target
class AdbTarget {
  /// Serial number of the device or emulator.
  final String? serial;

  /// Adb
  AdbTarget({this.serial});

  /// Creates an adb command with the given arguments.
  ProcessCmd adbCmd(List<String> args) {
    if (serial != null) {
      args.insertAll(0, ['-s', serial!]);
    }
    return _adbCmd(args);
  }
}

/// Name the apk command
ProcessCmd nameApkCommand({String? flavor}) {
  String filename;
  if (flavor == null) {
    filename = 'app-release';
  } else {
    filename = join(flavor, 'release', 'app-$flavor-release');
  }
  return ProcessCmd('apk_name_it', [
    join('app', 'build', 'outputs', 'apk', '$filename.apk'),
  ]);
}
