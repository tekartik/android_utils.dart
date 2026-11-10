import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';

ProcessCmd _adbCmd(List<String> args) {
  return ProcessCmd('adb', args);
}

/// Creates an `adb [args]` command.
ProcessCmd adbCmd(List<String> args) => _adbCmd(args);

/// Builds the argument list for `adb shell monkey`, the stress-testing
/// event generator.
///
/// [packageName], if given, restricts events to that package (`-p`);
/// otherwise all packages are targeted. [count] is the number of events to
/// generate, defaulting to `50000`. [sysKeysPercent] sets the
/// `--pct-syskeys` percentage (defaults to `0`).
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

/// Builds the `adb -s [emulatorName] emu kill` command that stops a running
/// emulator. [emulatorName] defaults to [defaultEmulatorSerialNumber].
// http://stackoverflow.com/questions/20155376/android-stop-emulator-from-command-line
// adb -s emulator-5554 emu kill
ProcessCmd adbKillEmulator({String? emulatorName}) {
  emulatorName ??= defaultEmulatorSerialNumber;
  return ProcessCmd('adb', ['-s', emulatorName, 'emu', 'kill']);
}

/// Builds the argument list for `adb shell ps`, listing device processes.
List<String> shellPsAdbArgs() {
  return ['shell', 'ps'];
}

/// Builds the argument list for `adb shell kill [pid]`.
List<String> shellKill(int pid) {
  return ['shell', 'kill', '$pid'];
}

/// Obsolete: Use `DeviceAdb` instead.
///
/// Identifies a device/emulator to target with `adb` commands built via
/// [adbCmd].
class AdbTarget {
  /// Serial number of the device or emulator to target with `-s`, or
  /// `null` to target whichever single device is connected.
  final String? serial;

  /// Creates a target for the device/emulator with the given [serial]
  /// (`null` to target whichever single device is connected).
  AdbTarget({this.serial});

  /// Creates an `adb [args]` command, prefixed with `-s [serial]` if
  /// [serial] was set.
  ProcessCmd adbCmd(List<String> args) {
    return _adbCmd([
      if (serial != null) ...['-s', serial!],
      ...args,
    ]);
  }
}

/// Builds the command to run the `apk_name_it` script (see
/// `lib/bin/apk_name_it.dart`) against the standard release apk output
/// path for the given [flavor] (or the flavor-less path if omitted).
ProcessCmd nameApkCommand({String? flavor}) {
  String filename;
  if (flavor == null) {
    // Android Gradle plugin 3 and later: apk/release/app-release.apk
    filename = join('release', 'app-release');
  } else {
    filename = join(flavor, 'release', 'app-$flavor-release');
  }
  return ProcessCmd('apk_name_it', [
    join('app', 'build', 'outputs', 'apk', '$filename.apk'),
  ]);
}
