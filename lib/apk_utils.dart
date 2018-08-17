// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The apk_utils library.
library apk_utils;

import 'dart:async';
import 'dart:io';

import 'package:fs_shim/utils/io/copy.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/src/aapt_badging_line_parser.dart';
import 'package:tekartik_android_utils/src/apk_info.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';
import 'package:xml/xml.dart';

class ManifestInfo {
  String versionName;
  String packageName;
  String versionCodeName;

  ManifestInfo(String xmlText) {
    var xml = parse(xmlText);
    XmlElement manifestElement = xml.findElements("manifest").first;
    for (XmlAttribute attribute in manifestElement.attributes) {
      String name = attribute.name.toString();
      //print(name);
      switch (name) {
        case "package":
          packageName = attribute.value;
          break;
        case "android:versionName":
          versionName = attribute.value;
          break;
        case "android:versionCode":
          versionCodeName = attribute.value;
          break;
      }
    }
  }
}

Future<ApkInfo> getApkInfo(String apkFilePath, {bool verbose}) async {
  ProcessResult result = await run("aapt", ['dump', 'badging', apkFilePath],
      commandVerbose: verbose);
  Iterable<String> lines = LineSplitter.split(result.stdout.toString());
  ApkInfo apkInfo;
  for (String line in lines) {
    apkInfo = parseBadgingLine(line);
    if (apkInfo != null) {
      break;
    }
  }
  return apkInfo;
}

Future nameApk(String apkFilePath, {String outFolderPath}) async {
  if (!await new File(apkFilePath).exists()) {
    throw ("$apkFilePath does not exist");
  }

  String content = "${apkFilePath}.content";
  try {
    await new Directory(content).delete(recursive: true);
  } catch (_) {}

  /*
  ProcessResult result =
      await run("aapt", ['dump', 'badging', apkFile], commandVerbose: true);
  List<String> lines = LineSplitter.split(result.stdout.toString());
  for (String line in lines) {
    apkInfo = parseBadgingLine(line);
    if (apkInfo != null) {
      break;
    }
  }

  */
  ApkInfo apkInfo = await getApkInfo(apkFilePath);

  if (apkInfo != null) {
    await copyApk(apkFilePath, apkInfo, outFolderPath: outFolderPath);
  } else {
    throw ("cannot read info on $apkFilePath");
  }
}

Future copyApk(String apkFilePath, ApkInfo apkInfo,
    {String outFolderPath}) async {
  String dstFileName =
      "${apkInfo.name}-${apkInfo.versionName}-${apkInfo.versionCode}.apk";

  String dst = join(outFolderPath ?? dirname(apkFilePath), dstFileName);
  stdout.writeln('naming: $dst');
  if (absolute(apkFilePath) == absolute(dstFileName)) {
    stderr.writeln('name is already fine');
    return;
  } else {
    await copyFile(new File(apkFilePath), new File(dst));
    /*
    if (outFolderPath != null) {
      if (new Directory(outFolderPath).)
    }
    */
    //await new File(apkFilePath).copy(dst);

  }
  stdout.writeln('  size: ${new File(dst).statSync().size}');
}

Future nameIt(String apkFilePath, String manifestFilePath,
    {String versionName}) {
  if (extension(apkFilePath) != ".apk") {
    throw "$apkFilePath is not an android .apk file";
  }
  if (extension(manifestFilePath) != ".xml") {
    throw "$manifestFilePath is not an android .xml file";
  }
  print(apkFilePath);
  print(manifestFilePath);

  String xmlText = new File(manifestFilePath).readAsStringSync();
  print(xmlText);

  ManifestInfo info = new ManifestInfo(xmlText);

  if (versionName == null) {
    versionName = info.versionName;
  }

  return copyApk(apkFilePath,
      new ApkInfo(info.packageName, versionName, info.versionCodeName));
}
