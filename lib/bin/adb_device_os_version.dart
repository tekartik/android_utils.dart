#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/android_cmd.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

const String _flagHelp = 'help';

const String scriptName = "adb_device_os_version";

main(List<String> args) async {
  var parser = new ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
  //parser.addFlag(_FLAG_VERSION_NAME, abbr: 'v', help: 'Version name', negatable: false);

  var results = parser.parse(args);

  parser.parse(args);

  bool help = results[_flagHelp];

  _usage() {
    print("${scriptName}");
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  int port = 5555;

  ProcessCmd cmd = adbCmd(['-d', 'tcpip', '$port']);
  await runCmd(cmd, verbose: true);

  await sleep(2000);

  String ipAddress;
  for (int i = 0; i < 5; i++) {
    cmd = adbCmd(['-d', 'shell', 'ip', '-f', 'inet', 'addr', 'show', 'wlan0']);
    ProcessResult result = await runCmd(cmd, verbose: true);
    for (String line in LineSplitter.split(result.stdout.toString())) {
      String prefix = "inet ";
      int index = line.indexOf(prefix);
      if (index >= 0) {
        line = line.substring(index + prefix.length);
        index = line.indexOf("/");
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
    stderr.writeln("no ip address found");
  } else {
    cmd = adbCmd(['connect', '$ipAddress:$port']);
    await runCmd(cmd, verbose: true);

    cmd = adbCmd(['devices']);
    await runCmd(cmd, verbose: true);
  }
}
