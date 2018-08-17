#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:args/args.dart';
import 'package:tekartik_cmd_utils/kill_cmd.dart';

const String _FLAG_HELP = 'help';

const String scriptName = "kill_emu";

main(List<String> args) async {
  var parser = new ArgParser();

  parser.addFlag(_FLAG_HELP, abbr: 'h', help: 'Usage help', negatable: false);

  var results = parser.parse(args);

  parser.parse(args);

  bool help = results[_FLAG_HELP];
  _usage() {
    stdout.writeln("kill the android (qemu) emulator process(es)");
    stdout.writeln("  ${scriptName}");
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  await killCommand("qemu");
/*
  ProcessCmd cmd = new ProcessCmd("ps", ["x", "-o", "pid,cmd"]);
  ProcessResult processResult = await runCmd(cmd, commandVerbose: true);
  PsParser psParser = new PsParser(processResult.stdout.toString());
  List<PsLine> lines = psParser.findByCmd("qemu");
  if (lines.isEmpty) {
    stderr.writeln("qemu process not found");
  } else {
    for (PsLine line in lines) {
      print(line);
      ProcessCmd cmd = new ProcessCmd("kill", ["-9", "${line.pid}"]);
      await runCmd(cmd, verbose: true);
    }
  }
  */

  //await runCmd(cmd, verbose: true);
}
