import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:tekartik_android_utils/emulator_utils.dart';

/// The name of the script.
const String scriptName = 'android_emu_run';

const _flagHelp = 'help';
const _flagList = 'list';
const _flagKeep = 'keep';
const _flagWindow = 'window';
const _optionAvd = 'avd';
const _optionSerial = 'serial';
const _optionBootTimeout = 'boot-timeout';
const _optionEmulatorArg = 'emulator-arg';

/// Runs a command on an Android device, launching an emulator when needed.
///
/// [args]: the options, then the command (after `--` or the first
/// non-option argument), see the usage (`--help`). Sets [exitCode] to the
/// one of the command.
Future<void> main(List<String> args) async {
  var parser = ArgParser(allowTrailingOptions: false)
    ..addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false)
    ..addFlag(
      _flagList,
      abbr: 'l',
      help: 'List the devices and the AVDs',
      negatable: false,
    )
    ..addOption(
      _optionAvd,
      abbr: 'a',
      help: 'AVD to use: its running emulator, or a new one',
    )
    ..addOption(
      _optionSerial,
      abbr: 's',
      help: 'Online device to use (adb serial)',
    )
    ..addFlag(
      _flagKeep,
      abbr: 'k',
      help: 'Keep the emulator launched running after the command',
      negatable: false,
    )
    ..addFlag(
      _flagWindow,
      help: 'Show the window of the emulator launched',
      defaultsTo: true,
    )
    ..addOption(
      _optionBootTimeout,
      help: 'Boot timeout in seconds',
      defaultsTo: '300',
    )
    ..addMultiOption(
      _optionEmulatorArg,
      help: 'Argument added to the emulator command line (repeatable)',
    );

  ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }
  if (results.flag(_flagHelp)) {
    stdout.writeln('''
Runs a command on an Android device, launching an emulator when needed.

  $scriptName [options] [--] [command...]

Device: --serial, otherwise the running emulator of --avd or a new one,
otherwise the first online emulator or device, otherwise the only AVD.
The command gets ANDROID_SERIAL (adb, gradle) and, for flutter run/test/
drive/install/attach/logs/screenshot, -d <serial>. An emulator launched is
stopped after the command unless --keep. Without a command, the device is
made ready and kept.

Example:
  $scriptName --avd Pixel_9 -- flutter test integration_test

${parser.usage}''');
    return;
  }

  await initAndroidBuildEnvironment();

  if (results.flag(_flagList)) {
    var state = await getAndroidDevicesState();
    stdout.writeln('Devices:');
    for (var device in state.devices) {
      var avd = state.runningAvdNames[device.serial];
      stdout.writeln(
        '  ${device.serial} ${device.type} ${device.model ?? ''}'
        '${avd == null ? '' : ' avd:$avd'}',
      );
    }
    stdout.writeln('AVDs:');
    for (var avd in state.avds) {
      stdout.writeln('  $avd');
    }
    return;
  }

  var command = results.rest;
  var keep = results.flag(_flagKeep) || command.isEmpty;

  // Launched by us: stopped at the end (unless kept) and on ctrl-c.
  String? launchingSerial;
  Shell? commandShell;
  var sigintSubscription = ProcessSignal.sigint.watch().listen((_) async {
    stderr.writeln('Interrupted');
    var shell = commandShell;
    var serial = launchingSerial;
    if (shell != null) {
      // The run ends, withAndroidDevice stops the emulator.
      shell.kill();
    } else {
      if (serial != null && !keep) {
        await killAndroidEmulator(serial);
      }
      exit(130);
    }
  });
  try {
    exitCode = await withAndroidDevice(
      (device) async {
        stdout.writeln('Device $device ready');
        if (command.isEmpty) {
          return 0;
        }
        var environment = ShellEnvironment()
          ..vars['ANDROID_SERIAL'] = device.serial;
        var shell = commandShell = Shell(
          environment: environment,
          throwOnError: false,
        );
        var deviceCommand = androidCommandWithDevice(command, device.serial);
        try {
          var result = await shell.runExecutableArguments(
            deviceCommand.first,
            deviceCommand.sublist(1),
          );
          return result.exitCode;
        } on ShellException catch (e) {
          // Not found or killed (ctrl-c).
          stderr.writeln(e.message);
          var code = e.result?.exitCode ?? 1;
          return code == 0 ? 1 : code;
        } finally {
          commandShell = null;
        }
      },
      serial: results.option(_optionSerial),
      avd: results.option(_optionAvd),
      keep: keep,
      noWindow: !results.flag(_flagWindow),
      emulatorArguments: results.multiOption(_optionEmulatorArg),
      bootTimeout: Duration(
        seconds: int.parse(results.option(_optionBootTimeout)!),
      ),
      onLaunching: (serial) {
        launchingSerial = serial;
        stdout.writeln('Launching $serial...');
      },
    );
  } on StateError catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
  } on TimeoutException catch (e) {
    stderr.writeln('$e');
    exitCode = 1;
  } finally {
    await sigintSubscription.cancel();
  }
}
