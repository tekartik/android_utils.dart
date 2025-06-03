#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/build_utils.dart';
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
  var versionName = results[_flagVersionName]?.toString();

  void usage() {
    stdout.writeln('apk_info <path_to_apk_file>');
    stdout.writeln(parser.usage);
  }

  if (help) {
    usage();
    return;
  }

  if (results.rest.length == 1) {
    // New just give the apk
    var apkFilePath = results.rest[0];
    await initAndroidBuildEnvironment();
    var apkInfo = (await getApkInfo(apkFilePath))!;
    stdout.writeln('name : ${apkInfo.name}');
    stdout.writeln('versionCode : ${apkInfo.versionCode}');
    stdout.writeln('versionName : ${apkInfo.versionName}');
    try {
      stdout.writeln('SHA1 : ${await apkExtractSha1Digest(apkFilePath)}');
    } catch (e) {
      stderr.writeln('Fail to extract sha1: $e');
    }

    //nameIt(apkFile, join(content, 'AndroidManifest.xml'));
  } else {
    if (results.rest.length == 2) {
      await nameIt(results.rest[0], results.rest[1], versionName: versionName);
    } else {
      stdout.writeln('Missing apk file name');
      usage();
    }
  }
}
