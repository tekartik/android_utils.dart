#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:tekartik_android_utils/src/import.dart';
import 'package:tekartik_cmd_utils/kill_cmd.dart';

const String _flagHelp = 'help';

/// The name of the script.
const String scriptName = 'kill_emu';

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);

  var results = parser.parse(args);

  parser.parse(args);

  var help = parseBool(results[_flagHelp])!;
  void usage() {
    stdout.writeln('kill the android (qemu) emulator process(es)');
    stdout.writeln('  $scriptName');
    stdout.writeln(parser.usage);
  }

  if (help) {
    usage();
    return;
  }

  if (Platform.isWindows) {
    //await dart .\bin\kill_cmd.dart qemu-system-i386.exe
    await killAllCommandsByName('qemu-system-i386.exe');
    await killAllCommandsByName('qemu-system-x86_64.exe');
  } else {
    await killAllCommandsByName('qemu');
  }

  /*
  ProcessCmd cmd = new ProcessCmd('ps', ['x', '-o', 'pid,cmd']);
  ProcessResult processResult = await runCmd(cmd, commandVerbose: true);
  PsParser psParser = new PsParser(processResult.stdout.toString());
  List<PsLine> lines = psParser.findByCmd('qemu');
  if (lines.isEmpty) {
    stderr.writeln('qemu process not found');
  } else {
    for (PsLine line in lines) {
      stdout.writeln(line);
      ProcessCmd cmd = new ProcessCmd('kill', ['-9', '${line.pid}']);
      await runCmd(cmd, verbose: true);
    }
  }
  */

  //await runCmd(cmd, verbose: true);
}
