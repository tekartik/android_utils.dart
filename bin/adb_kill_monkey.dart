#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:tekartik_android_utils/adb_shell.dart';
import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:process_run/cmd_run.dart';

const String _FLAG_HELP = 'help';
//const String _FLAG_VERSION_NAME = 'versionName';
const String _OPTION_SERIAL_NUMBER = 'serial';

const String scriptName = "adb_kill_monkey";

main(List<String> args) async {
  var parser = new ArgParser();

  parser.addFlag(_FLAG_HELP, abbr: 'h', help: 'Usage help', negatable: false);
  //parser.addFlag(_FLAG_VERSION_NAME, abbr: 'v', help: 'Version name', negatable: false);
  parser.addOption(_OPTION_SERIAL_NUMBER,
      abbr: 's', help: 'Serial name', defaultsTo: defaultEmulatorSerialNumber);

  var results = parser.parse(args);

  parser.parse(args);
  //bool verbose = false;

  bool help = results[_FLAG_HELP];
  String serialNumber = results[_OPTION_SERIAL_NUMBER];

  _usage() {
    print("${scriptName} [-s <serial_number>]");
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  AdbTarget target = new AdbTarget(serial: serialNumber);
  ProcessCmd cmd = target.adbCmd(shellPsAdbArgs());
  ProcessResult result =
      await runCmd(cmd, verbose: false, commandVerbose: true);
  ShellPsParser shellPsParser = new ShellPsParser(result.stdout.toString());

  String processName = "com.android.commands.monkey";
  PsLine psLine = shellPsParser.findByName(processName);
  if (psLine == null) {
    stderr.writeln("Process ${processName} not found");
  } else {
    stdout.writeln(psLine);
    cmd = target.adbCmd(shellKill(psLine.pid));
    runCmd(cmd, verbose: true);
  }
  /*
  List<String> lines = LineSplitter.split(result.stdout.toString());
  for (String line in lines) {
    print(line);
  }
  print(lines);
  */
}
