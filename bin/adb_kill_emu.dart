#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:args/args.dart';
import 'package:path/path.dart';
import 'dart:io';

const String _FLAG_HELP = 'help';
//const String _FLAG_VERSION_NAME = 'versionName';
const String _OPTION_EMULATOR_NAME = 'emulatorName';

main(List<String> args) async {
  var parser = new ArgParser();

  parser.addFlag(_FLAG_HELP, abbr: 'h', help: 'Usage help', negatable: false);
  //parser.addFlag(_FLAG_VERSION_NAME, abbr: 'v', help: 'Version name', negatable: false);
  parser.addOption(_OPTION_EMULATOR_NAME,
      abbr: 'e', help: 'Emulator name', defaultsTo: null);

  var results = parser.parse(args);

  parser.parse(args);

  bool help = results[_FLAG_HELP];
  String emulatorName = results[_OPTION_EMULATOR_NAME];

  _usage() {
    print("${basename(Platform.script.toFilePath())} [<emulator_name>");
    print(parser.usage);

  }
  if (help) {
    _usage();
    return;
  }

  ProcessCmd cmd = adbKillEmulator(emulatorName: emulatorName);
  await runCmd(cmd);
}
