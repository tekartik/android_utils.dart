#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:tekartik_common_utils/bool_utils.dart';

const String _flagHelp = 'help';
//const String _flagVersionName = 'versionName';
const String _optionEmulatorName = 'emulatorName';

const String scriptName = "adb_kill_emu";

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
  //parser.addFlag(_flagVersionName, abbr: 'v', help: 'Version name', negatable: false);
  parser.addOption(_optionEmulatorName,
      abbr: 'e',
      help: 'Emulator name',
      defaultsTo: defaultEmulatorSerialNumber);

  var results = parser.parse(args);

  parser.parse(args);

  bool help = parseBool(results[_flagHelp]);
  String emulatorName = results[_optionEmulatorName]?.toString();

  void _usage() {
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
