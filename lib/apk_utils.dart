// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The apk_utils library.
library apk_utils;

import 'dart:async';
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/src/apk_info.dart';
import 'package:tekartik_android_utils/src/aapt_badging_line_parser.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';
import 'package:process_run/cmd_run.dart';

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

Future nameApk(String apkFile) async {
  if (!await new File(apkFile).exists()) {
    throw("$apkFile does not exist");
  }

  String content = "${apkFile}.content";
  try {
    await new Directory(content).delete(recursive: true);
  } catch (_) {}

  ProcessResult result =
      await run("aapt", ['dump', 'badging', apkFile], commandVerbose: true);
  List<String> lines = LineSplitter.split(result.stdout.toString());
  ApkInfo apkInfo;
  for (String line in lines) {
    apkInfo = parseBadgingLine(line);
    if (apkInfo != null) {
      break;
    }
  }

  if (apkInfo != null) {
    await copyApk(apkFile, apkInfo);
  } else {
    throw("cannot read info on $apkFile");
  }
}

Future copyApk(String apkFilePath, ApkInfo apkInfo) async {
  String dstFileName =
      "${apkInfo.name}-${apkInfo.versionName}-${apkInfo.versionCode}.apk";

  String dst = join(dirname(apkFilePath), dstFileName);
  stdout.writeln('naming: $dst');
  if (absolute(apkFilePath) == absolute(dstFileName)) {
    stderr.writeln('name is already fine');
    return;
  } else {
    await new File(apkFilePath).copy(dst);
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
