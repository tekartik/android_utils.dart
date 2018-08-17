#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:args/args.dart';
import 'package:googleapis/androidpublisher/v2.dart';
import 'package:googleapis/plus/v1.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_android_utils/src/apk_info.dart';
import 'package:tekartik_io_auth_utils/io_auth_utils.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

final List<String> scopes = [
  //emailScope,
  AndroidpublisherApi.AndroidpublisherScope
]; //["email"];

const String alphaTrackName = "alpha";

const String _FLAG_HELP = 'help';
const String _OPTION_AUTH = 'auth';

main(List<String> args) async {
  var parser = new ArgParser();

  parser.addFlag(_FLAG_HELP, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addOption(_OPTION_AUTH,
      help: 'Auth json definition', defaultsTo: null);

  var results = parser.parse(args);

  parser.parse(args);

  bool help = results[_FLAG_HELP];
  String versionName = results[_OPTION_AUTH];

  _usage() {
    print("apk_publish_upload <path_to_apk_file> --auth auth.json");
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  if (results.rest.length == 1) {
    // New just give the apk
    String apkFile = results.rest[0];
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
    await nameApk(apkFile);

    //nameIt(apkFile, join(content, "AndroidManifest.xml"));
  } else {
    if (results.rest.length == 2) {
      nameIt(results.rest[0], results.rest[1], versionName: versionName);
    } else if (results.rest.length == 0) {
      bool foundTestData = false;

      //String testAuthJsonPath = join("bin", "tmp", "client_secret_124267391961-qu3lag0eht68os2cfuj4khn4rb3i6k4g.apps.googleusercontent.com.json");
      String testAuthJsonPath = join("bin", "tmp",
          "client_secret_243871252418-n20l8un6s86fi5vhkm8gm0d9kg7knige.apps.googleusercontent.com.json");

      if (await new File(testAuthJsonPath).exists()) {
        foundTestData = true;
        Map map = json.decode(await new File(testAuthJsonPath).readAsString());
        print(map);

        AuthClientInfo authClientInfo =
            await AuthClientInfo.load(filePath: testAuthJsonPath);
        print(authClientInfo);
        Client authClient = await authClientInfo.getClient(scopes);

        try {
          PlusApi plusApi = new PlusApi(authClient);
          Person person = await plusApi.people.get("me");
          print(person.toJson());
        } catch (e) {
          stderr.writeln("PlusApi error $e");
        }

        AndroidpublisherApi api = new AndroidpublisherApi(authClient);
        /*
        String packageName = "com.tekartik.buvettekpcm";
        AppEdit appEdit = await api.edits.insert(null, packageName);
        print(appEdit.toJson());
        await api.edits.delete(packageName, appEdit.id);
        */

        String packageName = "com.tekartik.miniexp";
        AppEdit appEdit = await api.edits.insert(null, packageName);
        try {
          print(appEdit.toJson());

          String apkFilePath = join("test", "data", "app-release.apk");

          ApkInfo apkInfo = await getApkInfo(apkFilePath);
          print('name : ${apkInfo.name}');
          print('versionCode : ${apkInfo.versionCode}');
          print('versionName : ${apkInfo.versionName}');

          List<int> data = await new File(apkFilePath).readAsBytes();
          commons.Media media =
              new commons.Media(new Stream.fromIterable([data]), data.length);
          print('uploading ${data.length}...');
          Apk apk = await api.edits.apks
              .upload(packageName, appEdit.id, uploadMedia: media);
          print('uploaded');
          print("versionCode: ${apk.versionCode}");

          Track track = new Track()..versionCodes = [apk.versionCode];
          track = await api.edits.tracks
              .update(track, packageName, appEdit.id, alphaTrackName);
          print("versionCodes: ${[track.versionCodes]}");

          await api.edits.commit(packageName, appEdit.id);
          print('commited');
        } catch (e) {
          try {
            await api.edits.delete(packageName, appEdit.id);
          } catch (e2) {
            stderr.writeln("edits.delete error $e2");
          }
          rethrow;
        }
      }
      if (!foundTestData) {
        print("Missing apk file name");
        _usage();
      }
    }
  }
}
