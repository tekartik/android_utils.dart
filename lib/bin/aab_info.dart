#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:tekartik_android_utils/aab_utils.dart';
import 'package:tekartik_android_utils/src/import.dart';

const String _flagHelp = 'help';

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);

  var results = parser.parse(args);

  parser.parse(args);

  var help = parseBool(results[_flagHelp])!;

  void _usage() {
    print('apk_info <path_to_apk_file>');
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  if (results.rest.length == 1) {
    // New just give the apk
    var aabFilePath = results.rest[0];
    /*
    if (!await new File(apkFile).exists()) {
      print('$apkFile does not exist');
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
      print('cannot read info on $apkFile');
      exit(1);
    }
    */
    var aabInfo = await getAabInfo(aabFilePath);
    print('name : ${aabInfo.name}');
    print('versionCode : ${aabInfo.versionCode}');
    print('versionName : ${aabInfo.versionName}');
  }
}
