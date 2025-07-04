#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/adb_shell.dart';
import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:tekartik_android_utils/src/import_io.dart';

const String _flagHelp = 'help';
//const String _flagVersionName = 'versionName';
const String _optionSerialNumber = 'serial';

/// Script name
const String scriptName = 'adb_kill_monkey';

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
  //parser.addFlag(_flagVersionName, abbr: 'v', help: 'Version name', negatable: false);
  parser.addOption(
    _optionSerialNumber,
    abbr: 's',
    help: 'Serial name',
    defaultsTo: defaultEmulatorSerialNumber,
  );

  var results = parser.parse(args);

  parser.parse(args);
  //bool verbose = false;

  var help = parseBool(results[_flagHelp])!;
  var serialNumber = results[_optionSerialNumber]?.toString();

  void usage() {
    stdout.writeln('$scriptName [-s <serial_number>]');
    stdout.writeln(parser.usage);
  }

  if (help) {
    usage();
    return;
  }

  var target = AdbTarget(serial: serialNumber);
  var cmd = target.adbCmd(shellPsAdbArgs());
  var result = await runCmd(cmd, verbose: false, commandVerbose: true);
  var shellPsParser = ShellPsParser(result.stdout.toString());

  var processName = 'com.android.commands.monkey';
  var psLine = shellPsParser.findByName(processName);
  if (psLine == null) {
    stderr.writeln('Process $processName not found');
  } else {
    stdout.writeln(psLine);
    cmd = target.adbCmd(shellKill(psLine.pid));
    await runCmd(cmd, verbose: true);
  }
  /*
  List<String> lines = LineSplitter.split(result.stdout.toString());
  for (String line in lines) {
    print(line);
  }
  print(lines);
  */
}
