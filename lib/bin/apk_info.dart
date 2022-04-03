#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/src/import.dart';

const String _flagHelp = 'help';
const String _flagVersionName = 'versionName';

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addOption(_flagVersionName,
      abbr: 'v', help: 'Version name', defaultsTo: null);

  var results = parser.parse(args);

  parser.parse(args);

  var help = parseBool(results[_flagHelp])!;
  var versionName = results[_flagVersionName]?.toString();

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
    var apkFilePath = results.rest[0];
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
    var apkInfo = (await getApkInfo(apkFilePath))!;
    print('name : ${apkInfo.name}');
    print('versionCode : ${apkInfo.versionCode}');
    print('versionName : ${apkInfo.versionName}');
    try {
      print('SHA1 : ${await apkExtractSha1Digest(apkFilePath)}');
    } catch (e) {
      stderr.writeln('Fail to extract sha1: $e');
    }

    //nameIt(apkFile, join(content, 'AndroidManifest.xml'));
  } else {
    if (results.rest.length == 2) {
      await nameIt(results.rest[0], results.rest[1], versionName: versionName);
    } else {
      print('Missing apk file name');
      _usage();
    }
  }
}
