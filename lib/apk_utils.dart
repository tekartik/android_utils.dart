// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The apk_utils library.
library;

import 'dart:io';

import 'package:fs_shim/utils/io/copy.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/which.dart';
import 'package:tekartik_android_utils/aab_utils.dart';
import 'package:tekartik_android_utils/src/aapt_badging_line_parser.dart';
import 'package:tekartik_android_utils/src/import.dart';

export 'src/apk_get_sha1.dart' show getApkSha1;
export 'src/apk_info.dart' show ApkInfo;
export 'src/bin/keytool_io.dart' show apkExtractSha1Digest;

bool? _aaptSupported;

/// True if aapt si present and supported
bool get aaptSupported => _aaptSupported ??= whichSync('aapt') != null;

Future<ApkInfo?> getApkInfo(String apkFilePath, {bool? verbose}) async {
  var result = await runExecutableArguments('aapt', [
    'dump',
    'badging',
    apkFilePath,
  ], commandVerbose: verbose);
  var lines = LineSplitter.split(result.stdout.toString());
  ApkInfo? apkInfo;
  for (var line in lines) {
    apkInfo = parseBadgingLine(line);
    if (apkInfo != null) {
      break;
    }
  }
  return apkInfo;
}

Future nameApk(String apkFilePath, {String? outFolderPath}) async {
  if (!File(apkFilePath).existsSync()) {
    throw ('$apkFilePath does not exist');
  }

  var content = '$apkFilePath.content';
  try {
    await Directory(content).delete(recursive: true);
  } catch (_) {}

  /*
  ProcessResult result =
      await run('aapt', ['dump', 'badging', apkFile], commandVerbose: true);
  List<String> lines = LineSplitter.split(result.stdout.toString());
  for (String line in lines) {
    apkInfo = parseBadgingLine(line);
    if (apkInfo != null) {
      break;
    }
  }

  */
  var apkInfo = await getApkInfo(apkFilePath);

  if (apkInfo != null) {
    await copyApk(apkFilePath, apkInfo, outFolderPath: outFolderPath);
  } else {
    throw ('cannot read info on $apkFilePath');
  }
}

Future copyApk(
  String apkFilePath,
  ApkInfo apkInfo, {
  String? outFolderPath,
}) async {
  var dstFileName =
      '${apkInfo.name}-${apkInfo.versionName}-${apkInfo.versionCode}.apk';

  var dst = join(outFolderPath ?? dirname(apkFilePath), dstFileName);
  stdout.writeln('naming: $dst');
  if (absolute(apkFilePath) == absolute(dstFileName)) {
    stderr.writeln('name is already fine');
    return;
  } else {
    await copyFile(File(apkFilePath), File(dst));
    /*
    if (outFolderPath != null) {
      if (new Directory(outFolderPath).)
    }
    */
    //await new File(apkFilePath).copy(dst);
  }
  stdout.writeln('  size: ${File(dst).statSync().size}');
}

Future nameIt(
  String apkFilePath,
  String manifestFilePath, {
  String? versionName,
}) {
  if (extension(apkFilePath) != '.apk') {
    throw '$apkFilePath is not an android .apk file';
  }
  if (extension(manifestFilePath) != '.xml') {
    throw '$manifestFilePath is not an android .xml file';
  }
  stdout.writeln(apkFilePath);
  stdout.writeln(manifestFilePath);

  var xmlText = File(manifestFilePath).readAsStringSync();
  stdout.writeln(xmlText);

  var info = AabInfo()..fromXml(xmlText);

  versionName ??= info.versionName;

  return copyApk(
    apkFilePath,
    ApkInfo(
      name: info.name,
      versionName: versionName,
      versionCode: info.versionCode,
    ),
  );
}
