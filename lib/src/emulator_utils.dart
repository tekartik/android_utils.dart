import 'dart:async';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/adb_utils.dart';

/// Lowest console port of an Android emulator (serial `emulator-5554`).
const androidEmulatorFirstPort = 5554;

/// Highest console port of an Android emulator (serial `emulator-5682`).
const androidEmulatorLastPort = 5682;

/// Prefix of the adb serial of a local emulator (`emulator-<port>`).
const androidEmulatorSerialPrefix = 'emulator-';

/// The adb state of a device ready for commands (`adb devices` second column).
const adbDeviceStateOnline = 'device';

final _avdNameRegExp = RegExp(r'^[A-Za-z0-9._-]+$');

/// Parses [lines], the stdout of `emulator -list-avds`, into AVD names.
///
/// Lines that cannot be an AVD name (empty, `INFO    | ...` logs printed by
/// some emulator versions) are ignored. Returns the names in the emulator
/// order, possibly empty.
List<String> emulatorListAvdsParseLines(Iterable<String> lines) {
  return lines
      .map((line) => line.trim())
      .where((line) => _avdNameRegExp.hasMatch(line))
      .toList();
}

/// Parses [lines], the stdout of `adb -s <serial> emu avd name`, into the
/// AVD name of a running emulator.
///
/// Returns `null` when the output holds no name (only `OK` or an error).
String? adbEmuAvdNameParseLines(Iterable<String> lines) {
  for (var line in lines) {
    var name = line.trim();
    if (name.isEmpty || name == 'OK') {
      continue;
    }
    if (_avdNameRegExp.hasMatch(name)) {
      return name;
    }
    return null;
  }
  return null;
}

/// Returns the console port of the local emulator with the adb [serial]
/// (`emulator-5556` gives `5556`), or `null` when [serial] is not one
/// (a usb device, an ip device).
int? androidEmulatorSerialPort(String serial) {
  if (!serial.startsWith(androidEmulatorSerialPrefix)) {
    return null;
  }
  return int.tryParse(serial.substring(androidEmulatorSerialPrefix.length));
}

/// Returns the adb serial of the local emulator on the console [port]
/// (`emulator-<port>`).
String androidEmulatorSerial(int port) => '$androidEmulatorSerialPrefix$port';

/// Returns the first even console port, from [androidEmulatorFirstPort] to
/// [androidEmulatorLastPort], used by none of the adb [serials].
///
/// Throws a [StateError] when every port is taken.
int androidEmulatorFreePort(Iterable<String> serials) {
  var usedPorts = serials.map(androidEmulatorSerialPort).nonNulls.toSet();
  for (
    var port = androidEmulatorFirstPort;
    port <= androidEmulatorLastPort;
    port += 2
  ) {
    if (!usedPorts.contains(port)) {
      return port;
    }
  }
  throw StateError('No free emulator port in $usedPorts');
}

/// Flutter commands taking a device (`-d <serial>`).
const _flutterDeviceCommands = {
  'attach',
  'drive',
  'install',
  'logs',
  'run',
  'screenshot',
  'test',
};

/// Returns [command] (an executable and its arguments) targeting the device
/// [serial]: for a `flutter` command taking a device (`run`, `test`,
/// `drive`, `install`, `attach`, `logs`, `screenshot`) without `-d` nor
/// `--device-id`, `-d <serial>` is inserted after the sub command; any other
/// command is returned unchanged (it reads `ANDROID_SERIAL`, as adb and
/// gradle do).
List<String> androidCommandWithDevice(List<String> command, String serial) {
  if (command.length < 2) {
    return command;
  }
  var executable = command.first.split(RegExp(r'[/\\]')).last.toLowerCase();
  var isFlutter = executable == 'flutter' || executable == 'flutter.bat';
  if (!isFlutter || !_flutterDeviceCommands.contains(command[1])) {
    return command;
  }
  var hasDevice = command.any(
    (arg) =>
        arg == '-d' || arg == '--device-id' || arg.startsWith('--device-id='),
  );
  if (hasDevice) {
    return command;
  }
  return [command[0], command[1], '-d', serial, ...command.sublist(2)];
}

/// What to do to get a device for a run, see [androidEmulatorRunChooseTarget].
class AndroidEmulatorRunTarget {
  /// The adb serial of the online device to use, `null` when [avdToLaunch]
  /// must be launched.
  final String? serial;

  /// The AVD to launch, `null` when the online device [serial] is used.
  final String? avdToLaunch;

  /// A device to use: the online device [serial] or the AVD [avdToLaunch]
  /// to launch (exactly one of them).
  const AndroidEmulatorRunTarget({this.serial, this.avdToLaunch})
    : assert((serial == null) != (avdToLaunch == null));

  @override
  String toString() => serial != null ? 'use $serial' : 'launch $avdToLaunch';
}

/// Chooses the device of a run.
///
/// [devices] are the parsed `adb devices -l` ([getAdbDeviceInfos]), only the
/// online ones ([adbDeviceStateOnline]) count. [runningAvdNames] maps the
/// serial of each running emulator to its AVD name. [avds] are the AVDs of
/// the machine ([listAndroidEmulatorAvds]).
///
/// - [serial] given: that device when online.
/// - [avd] given: the running emulator of that AVD, otherwise a launch of it.
/// - neither: the first online emulator, otherwise the first online device,
///   otherwise a launch of the only AVD of the machine.
///
/// Throws a [StateError] (its message for the user) when there is no
/// answer: [serial] offline, unknown [avd], several AVDs and nothing online.
AndroidEmulatorRunTarget androidEmulatorRunChooseTarget({
  required List<AdbDeviceInfo> devices,
  required Map<String, String?> runningAvdNames,
  required List<String> avds,
  String? serial,
  String? avd,
}) {
  var online = devices
      .where((device) => device.type == adbDeviceStateOnline)
      .map((device) => device.serial)
      .nonNulls
      .toList();
  if (serial != null) {
    if (online.contains(serial)) {
      return AndroidEmulatorRunTarget(serial: serial);
    }
    throw StateError('Device $serial is not online (online: $online)');
  }
  if (avd != null) {
    for (var onlineSerial in online) {
      if (runningAvdNames[onlineSerial] == avd) {
        return AndroidEmulatorRunTarget(serial: onlineSerial);
      }
    }
    if (!avds.contains(avd)) {
      throw StateError('Unknown AVD $avd (AVDs: ${avds.join(', ')})');
    }
    return AndroidEmulatorRunTarget(avdToLaunch: avd);
  }
  var emulator = online
      .where((serial) => androidEmulatorSerialPort(serial) != null)
      .firstOrNull;
  if (emulator != null) {
    return AndroidEmulatorRunTarget(serial: emulator);
  }
  if (online.isNotEmpty) {
    return AndroidEmulatorRunTarget(serial: online.first);
  }
  if (avds.length == 1) {
    return AndroidEmulatorRunTarget(avdToLaunch: avds.first);
  }
  if (avds.isEmpty) {
    throw StateError('No device online and no AVD to launch');
  }
  throw StateError(
    'No device online, choose the AVD to launch with --avd: ${avds.join(', ')}',
  );
}

Shell _quietShell() => Shell(verbose: false, throwOnError: false);

/// Lists the AVD names of the machine with `emulator -list-avds`.
///
/// The `emulator` of the Android SDK must be on the PATH: call
/// `initAndroidBuildEnvironment()` (`build_utils.dart`) first, it adds the
/// SDK `emulator` folder. Throws a [ShellException] when the emulator cannot
/// run.
Future<List<String>> listAndroidEmulatorAvds() async {
  var result = await Shell(
    verbose: false,
  ).runExecutableArguments('emulator', ['-list-avds']);
  return emulatorListAvdsParseLines(result.outLines);
}

/// Returns the AVD name of the running emulator [serial]
/// (`adb -s <serial> emu avd name`), `null` when it is not an emulator or
/// does not answer.
Future<String?> getAndroidEmulatorAvdName(String serial) async {
  if (androidEmulatorSerialPort(serial) == null) {
    return null;
  }
  var result = await _quietShell().runExecutableArguments('adb', [
    '-s',
    serial,
    'emu',
    'avd',
    'name',
  ]);
  if (result.exitCode != 0) {
    return null;
  }
  return adbEmuAvdNameParseLines(result.outLines);
}

/// Returns `true` when the device [serial] is online and booted
/// (`sys.boot_completed` is `1`).
Future<bool> isAdbDeviceBootCompleted(String serial) async {
  var result = await _quietShell().runExecutableArguments('adb', [
    '-s',
    serial,
    'shell',
    'getprop',
    'sys.boot_completed',
  ]);
  return result.exitCode == 0 && result.outText.trim() == '1';
}

/// Waits until the device [serial] is online and booted, checking every
/// [interval] (2 s by default).
///
/// Throws a [TimeoutException] after [timeout] (5 minutes by default).
Future<void> waitForAdbDeviceBootCompleted(
  String serial, {
  Duration timeout = const Duration(minutes: 5),
  Duration interval = const Duration(seconds: 2),
}) async {
  var stopwatch = Stopwatch()..start();
  while (!await isAdbDeviceBootCompleted(serial)) {
    if (stopwatch.elapsed > timeout) {
      throw TimeoutException('$serial not booted', timeout);
    }
    await Future<void>.delayed(interval);
  }
}

/// Returns the serials of the devices known by adb (`adb devices`), any
/// state.
Future<List<String>> _adbSerials() async {
  var result = await _quietShell().runExecutableArguments('adb', ['devices']);
  return adbDeviceInfosParseLines(
    result.outLines,
  ).map((info) => info.serial).nonNulls.toList();
}

/// Stops the emulator [serial] (`adb -s <serial> emu kill`) and waits until
/// adb no longer lists it.
///
/// Throws a [TimeoutException] when it is still listed after [timeout]
/// (1 minute by default).
Future<void> killAndroidEmulator(
  String serial, {
  Duration timeout = const Duration(minutes: 1),
}) async {
  await _quietShell().runExecutableArguments('adb', [
    '-s',
    serial,
    'emu',
    'kill',
  ]);
  var stopwatch = Stopwatch()..start();
  while ((await _adbSerials()).contains(serial)) {
    if (stopwatch.elapsed > timeout) {
      throw TimeoutException('$serial still running', timeout);
    }
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}

/// An emulator launched by [launchAndroidEmulator].
class AndroidEmulatorLaunch {
  /// The AVD launched.
  final String avd;

  /// The console port of the emulator.
  final int port;

  /// The adb serial of the emulator (`emulator-<port>`).
  String get serial => androidEmulatorSerial(port);

  /// An emulator of the AVD [avd] on the console [port].
  AndroidEmulatorLaunch({required this.avd, required this.port});

  /// Stops the emulator, see [killAndroidEmulator].
  Future<void> kill({Duration timeout = const Duration(minutes: 1)}) =>
      killAndroidEmulator(serial, timeout: timeout);

  @override
  String toString() => 'AndroidEmulatorLaunch($avd, $serial)';
}

/// The devices and the AVDs of the machine, see [getAndroidDevicesState].
class AndroidDevicesState {
  /// The devices known by adb (`adb devices -l`), any state.
  final List<AdbDeviceInfo> devices;

  /// The AVD name of each online emulator, by serial.
  final Map<String, String?> runningAvdNames;

  /// The AVDs of the machine, empty when the emulator is not installed.
  final List<String> avds;

  /// The [devices], the [runningAvdNames] and the [avds] of the machine.
  AndroidDevicesState({
    required this.devices,
    required this.runningAvdNames,
    required this.avds,
  });
}

/// Reads the devices known by adb, the AVD of the running emulators and the
/// AVDs of the machine (empty when `emulator` cannot run).
///
/// `adb` and `emulator` must be on the PATH, see [listAndroidEmulatorAvds].
Future<AndroidDevicesState> getAndroidDevicesState() async {
  var result = await _quietShell().runExecutableArguments('adb', [
    'devices',
    '-l',
  ]);
  var devices = adbDeviceInfosParseLines(result.outLines);
  var runningAvdNames = <String, String?>{
    for (var device in devices)
      if (device.type == adbDeviceStateOnline && device.serial != null)
        device.serial!: await getAndroidEmulatorAvdName(device.serial!),
  };
  List<String> avds;
  try {
    avds = await listAndroidEmulatorAvds();
  } catch (_) {
    avds = [];
  }
  return AndroidDevicesState(
    devices: devices,
    runningAvdNames: runningAvdNames,
    avds: avds,
  );
}

/// The device given to the action of [withAndroidDevice].
class AndroidRunDevice {
  /// The adb serial of the device.
  final String serial;

  /// The AVD of the emulator, `null` for a phone.
  final String? avd;

  /// `true` when [withAndroidDevice] launched the emulator.
  final bool launched;

  /// The device [serial], its [avd] and whether it was [launched].
  AndroidRunDevice({required this.serial, this.avd, this.launched = false});

  @override
  String toString() =>
      '$serial${avd == null ? '' : ' ($avd)'}${launched ? ' launched' : ''}';
}

/// Runs [action] on a booted device: an online one or an emulator launched
/// for it ([androidEmulatorRunChooseTarget] picks it from [serial] and
/// [avd]), then stops the emulator it launched unless [keep].
///
/// [noWindow], [emulatorArguments] and [bootTimeout] are the ones of
/// [launchAndroidEmulator]. [onLaunching] is called with the serial of an
/// emulator before it is launched (to stop it on an interruption). Returns
/// the result of [action]. Throws a [StateError] when no device can be
/// chosen, a [TimeoutException] when the device does not boot.
///
/// `adb` and `emulator` must be on the PATH: call
/// `initAndroidBuildEnvironment()` (`build_utils.dart`) first.
Future<T> withAndroidDevice<T>(
  Future<T> Function(AndroidRunDevice device) action, {
  String? serial,
  String? avd,
  bool keep = false,
  bool noWindow = false,
  List<String> emulatorArguments = const [],
  Duration bootTimeout = const Duration(minutes: 5),
  void Function(String serial)? onLaunching,
}) async {
  var state = await getAndroidDevicesState();
  var target = androidEmulatorRunChooseTarget(
    devices: state.devices,
    runningAvdNames: state.runningAvdNames,
    avds: state.avds,
    serial: serial,
    avd: avd,
  );
  var avdToLaunch = target.avdToLaunch;
  if (avdToLaunch == null) {
    var deviceSerial = target.serial!;
    await waitForAdbDeviceBootCompleted(deviceSerial, timeout: bootTimeout);
    return await action(
      AndroidRunDevice(
        serial: deviceSerial,
        avd: state.runningAvdNames[deviceSerial],
      ),
    );
  }
  var port = androidEmulatorFreePort(
    state.devices.map((device) => device.serial).nonNulls,
  );
  onLaunching?.call(androidEmulatorSerial(port));
  var launch = await launchAndroidEmulator(
    avd: avdToLaunch,
    port: port,
    noWindow: noWindow,
    arguments: emulatorArguments,
    bootTimeout: bootTimeout,
  );
  try {
    return await action(
      AndroidRunDevice(serial: launch.serial, avd: avdToLaunch, launched: true),
    );
  } finally {
    if (!keep) {
      stdout.writeln('Stopping ${launch.serial}...');
      await launch.kill();
    }
  }
}

/// Launches the AVD [avd] and waits until it is booted.
///
/// The emulator is detached: it lives on after the program, stop it with
/// [AndroidEmulatorLaunch.kill]. [port] is its console port (its serial is
/// `emulator-<port>`), the first free one by default
/// ([androidEmulatorFreePort]). [noWindow] runs it without a window
/// (`-no-window`, CI or a remote session), [arguments] are added to the
/// `emulator` command line (`-no-snapshot-load`, `-wipe-data`...).
///
/// Throws a [TimeoutException] when it is not booted after [bootTimeout]
/// (5 minutes by default), the emulator being stopped first. The `emulator`
/// must be on the PATH, see [listAndroidEmulatorAvds].
Future<AndroidEmulatorLaunch> launchAndroidEmulator({
  required String avd,
  int? port,
  bool noWindow = false,
  List<String> arguments = const [],
  Duration bootTimeout = const Duration(minutes: 5),
}) async {
  port ??= androidEmulatorFreePort(await _adbSerials());
  var launch = AndroidEmulatorLaunch(avd: avd, port: port);
  var shell = Shell(
    options: ShellOptions(
      mode: ProcessStartMode.detached,
      verbose: false,
      commandVerbose: true,
    ),
  );
  await shell.runExecutableArguments('emulator', [
    '-avd',
    avd,
    '-port',
    '$port',
    if (noWindow) '-no-window',
    ...arguments,
  ]);
  try {
    await waitForAdbDeviceBootCompleted(launch.serial, timeout: bootTimeout);
  } catch (_) {
    try {
      await launch.kill();
    } catch (_) {}
    rethrow;
  }
  return launch;
}
