#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/src/apk_info.dart';

const String _FLAG_HELP = 'help';
const String _FLAG_VERSION_NAME = 'versionName';

main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_FLAG_HELP, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addOption(_FLAG_VERSION_NAME,
      abbr: 'v', help: 'Version name', defaultsTo: null);

  var results = parser.parse(args);

  parser.parse(args);

  bool help = results[_FLAG_HELP];
  String versionName = results[_FLAG_VERSION_NAME];

  _usage() {
    print("apk_info <path_to_apk_file>");
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  if (results.rest.length == 1) {
    // New just give the apk
    String apkFilePath = results.rest[0];
    /*
    if (!await new File(apkFile).exists()) {
      print("$apkFile does not exist");
      exit(1);
    }

    String content = "${apkFile}.content";
    try {
      await new Directory(content).delete(recursive: true);
    } catch (_) {}

    ProcessResult result = await Process.run("aapt", ['dump', 'badging', apkFile]);
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
      print("cannot read info on $apkFile");
      exit(1);
    }
    */
    ApkInfo apkInfo = await getApkInfo(apkFilePath);
    print('name : ${apkInfo.name}');
    print('versionCode : ${apkInfo.versionCode}');
    print('versionName : ${apkInfo.versionName}');

    //nameIt(apkFile, join(content, "AndroidManifest.xml"));
  } else {
    if (results.rest.length == 2) {
      nameIt(results.rest[0], results.rest[1], versionName: versionName);
    } else {
      print("Missing apk file name");
      _usage();
    }
  }
}
