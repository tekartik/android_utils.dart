#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/android_cmd.dart';

const String _FLAG_HELP = 'help';
//const String _FLAG_VERSION_NAME = 'versionName';
const String _OPTION_EMULATOR_NAME = 'emulatorName';

const String scriptName = "adb_kill_emu";

main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_FLAG_HELP, abbr: 'h', help: 'Usage help', negatable: false);
  //parser.addFlag(_FLAG_VERSION_NAME, abbr: 'v', help: 'Version name', negatable: false);
  parser.addOption(_OPTION_EMULATOR_NAME,
      abbr: 'e',
      help: 'Emulator name',
      defaultsTo: defaultEmulatorSerialNumber);

  var results = parser.parse(args);

  parser.parse(args);

  bool help = results[_FLAG_HELP];
  String emulatorName = results[_OPTION_EMULATOR_NAME];

  _usage() {
    print("${scriptName} [<emulator_name>");
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  ProcessCmd cmd = adbKillEmulator(emulatorName: emulatorName);
  await runCmd(cmd, verbose: true);
}
