#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/src/import.dart';

const String _flagHelp = 'help';
const String _flagVersionName = 'versionName';

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addOption(
    _flagVersionName,
    abbr: 'v',
    help: 'Version name',
    defaultsTo: null,
  );

  var results = parser.parse(args);

  parser.parse(args);

  var help = parseBool(results[_flagHelp])!;
  //String versionName = results[_flagVersionName];

  void usage() {
    stdout.writeln('apk_name_it <path_to_apk_file> [<dst_folder>]');
    stdout.writeln(parser.usage);
  }

  if (help) {
    usage();
    return;
  }

  if (results.rest.isNotEmpty) {
    // New just give the apk
    var apkFilePath = results.rest[0];
    String? outFolderPath;

    if (results.rest.length > 1) {
      outFolderPath = results.rest[1];
    }
    /*
    if (!await new File(apkFile).exists()) {
      stdout.writeln('$apkFile does not exist');
      exit(1);
    }

    String content = '${apkFile}.content';
    try {
      await new Directory(content).delete(recursive: true);
    } catch (_) {}

    ProcessResult result = await Process.run('aapt', ['dump', 'badging', apkFile]);
    List<String> lines = LineSplitter.split(result.stdout.toString());
    ApkInfo apkInfo;
    for (String line in lines) {
      apkInfo = parseBadgingLine(line);
      if (apkInfo != null) {
        break;
      }
    }

    if (apkInfo != null) {
      copyApk(apkFile, apkInfo);
    } else {
      stdout.writeln('cannot read info on $apkFile');
      exit(1);
    }
    */
    await nameApk(apkFilePath, outFolderPath: outFolderPath);
  }
  /*
    //nameIt(apkFile, join(content, 'AndroidManifest.xml'));
  } else {
    if (results.rest.length == 2) {
      nameIt(results.rest[0], results.rest[1], versionName: versionName);
    }
    */
  else {
    stderr.writeln('Missing apk file name');
    usage();
  }
}
