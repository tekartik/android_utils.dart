#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

const String _flagHelp = 'help';

const String scriptName = 'adb_tcpip';

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
  //parser.addFlag(_flagVersionName, abbr: 'v', help: 'Version name', negatable: false);

  var results = parser.parse(args);

  parser.parse(args);

  var help = parseBool(results[_flagHelp])!;

  void _usage() {
    print(scriptName);
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  var port = 5555;

  var cmd = adbCmd(['-d', 'tcpip', '$port']);
  await runCmd(cmd, verbose: true);

  await sleep(2000);

  String? ipAddress;
  for (var i = 0; i < 5; i++) {
    cmd = adbCmd(['-d', 'shell', 'ip', '-f', 'inet', 'addr', 'show', 'wlan0']);
    var result = await runCmd(cmd, verbose: true);
    for (var line in LineSplitter.split(result.stdout.toString())) {
      var prefix = 'inet ';
      var index = line.indexOf(prefix);
      if (index >= 0) {
        line = line.substring(index + prefix.length);
        index = line.indexOf('/');
        ipAddress = line.substring(0, index);
        print(ipAddress);
        break;
      }
    }

    if (ipAddress != null) {
      break;
    }
    await sleep(500);
  }

  if (ipAddress == null) {
    stderr.writeln('no ip address found');
  } else {
    cmd = adbCmd(['connect', '$ipAddress:$port']);
    await runCmd(cmd, verbose: true);

    cmd = adbCmd(['devices']);
    await runCmd(cmd, verbose: true);
  }
}
