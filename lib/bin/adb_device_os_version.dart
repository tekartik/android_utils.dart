// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_android_utils/src/import_io.dart';

const String _flagHelp = 'help';
const String _optionSerial = 'serial';

/// Script name
const String scriptName = 'adb_device_os_version';

/// Prints the Android version (`ro.build.version.release`) and the SDK level
/// (`ro.build.version.sdk`) of a connected device.
Future main(List<String> args) async {
  var parser = ArgParser()
    ..addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false)
    ..addOption(
      _optionSerial,
      abbr: 's',
      help: 'Device serial, defaults to the first connected device',
    );

  var results = parser.parse(args);

  if (results.flag(_flagHelp)) {
    stdout.writeln('$scriptName [-s <serial_number>]');
    stdout.writeln(parser.usage);
    return;
  }

  var serial = await findDevice(serial: results.option(_optionSerial));
  if (serial == null) {
    stderr.writeln('no device found');
    exitCode = 1;
    return;
  }
  var device = AdbDevice(serial);
  Future<String> getProp(String name) async =>
      (await device.runShellCommand('getprop $name')).trim();
  var release = await getProp('ro.build.version.release');
  var sdk = await getProp('ro.build.version.sdk');
  stdout.writeln('$serial: Android $release (sdk $sdk)');
}
