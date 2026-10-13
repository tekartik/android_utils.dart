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

/// Whether the `aapt` executable is available on the current `PATH`. The
/// result is cached after the first check.
bool get aaptSupported => _aaptSupported ??= whichSync('aapt') != null;

/// Runs `aapt dump badging` on the apk at [apkFilePath] and parses its
/// output into an [ApkInfo].
///
/// If [verbose] is `true`, the underlying command's output is logged.
///
/// Returns `null` if no badging info line could be parsed from the output.
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

/// Reads the apk at [apkFilePath] with [getApkInfo] and copies it (via
/// [copyApk]) to a name derived from its package name, version name and
/// version code, in [outFolderPath] (defaults to the apk's own directory).
///
/// Throws a [StateError] if [apkFilePath] doesn't exist or its info
/// couldn't be read.
Future nameApk(String apkFilePath, {String? outFolderPath}) async {
  if (!File(apkFilePath).existsSync()) {
    throw StateError('$apkFilePath does not exist');
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
    throw StateError('cannot read info on $apkFilePath');
  }
}

/// Copies the apk at [apkFilePath] to `<name>-<versionName>-<versionCode>.apk`
/// (derived from [apkInfo]) inside [outFolderPath] (defaults to the apk's
/// own directory). Does nothing if the computed destination is the same
/// file as the source.
Future copyApk(
  String apkFilePath,
  ApkInfo apkInfo, {
  String? outFolderPath,
}) async {
  var dstFileName =
      '${apkInfo.name}-${apkInfo.versionName}-${apkInfo.versionCode}.apk';

  var dst = join(outFolderPath ?? dirname(apkFilePath), dstFileName);
  stdout.writeln('naming: $dst');
  if (canonicalize(apkFilePath) == canonicalize(dst)) {
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

/// Copies (via [copyApk]) the apk at [apkFilePath] to a name derived from
/// the app info parsed out of the Android manifest XML at
/// [manifestFilePath].
///
/// [versionName] overrides the version name read from the manifest; if
/// omitted, the manifest's own version name is used.
///
/// Throws a [StateError] if [apkFilePath] doesn't end in `.apk` or
/// [manifestFilePath] doesn't end in `.xml`.
Future nameIt(
  String apkFilePath,
  String manifestFilePath, {
  String? versionName,
}) {
  if (extension(apkFilePath) != '.apk') {
    throw StateError('$apkFilePath is not an android .apk file');
  }
  if (extension(manifestFilePath) != '.xml') {
    throw StateError('$manifestFilePath is not an android .xml file');
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
