#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:tekartik_android_utils/src/import_io.dart';

const String _flagHelp = 'help';
//const String _flagVersionName = 'versionName';
const String _optionEmulatorName = 'emulatorName';

/// Script name
const String scriptName = 'adb_kill_emu';

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
  //parser.addFlag(_flagVersionName, abbr: 'v', help: 'Version name', negatable: false);
  parser.addOption(
    _optionEmulatorName,
    abbr: 'e',
    help: 'Emulator name',
    defaultsTo: defaultEmulatorSerialNumber,
  );

  var results = parser.parse(args);

  parser.parse(args);

  var help = parseBool(results[_flagHelp])!;
  var emulatorName = results[_optionEmulatorName]?.toString();

  void usage() {
    stdout.writeln('$scriptName [<emulator_name>');
    stdout.writeln(parser.usage);
  }

  if (help) {
    usage();
    return;
  }

  var cmd = adbKillEmulator(emulatorName: emulatorName);
  await runCmd(cmd, verbose: true);
}
