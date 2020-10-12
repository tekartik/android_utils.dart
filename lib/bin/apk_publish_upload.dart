#!/usr/bin/env dart
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:args/args.dart';
import 'package:googleapis/androidpublisher/v3.dart';
import 'package:googleapis/people/v1.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/apk_utils.dart';
import 'package:tekartik_io_auth_utils/io_auth_utils.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

final List<String> scopes = [
  //emailScope,
  AndroidpublisherApi.AndroidpublisherScope
]; //['email'];

const String alphaTrackName = 'alpha';

const String _flagHelp = 'help';
const String _optionAuth = 'auth';

Future main(List<String> args) async {
  var parser = ArgParser();

  parser.addFlag(_flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addOption(_optionAuth, help: 'Auth json definition', defaultsTo: null);

  var results = parser.parse(args);

  parser.parse(args);

  var help = parseBool(results[_flagHelp]);
  var versionName = results[_optionAuth]?.toString();

  void _usage() {
    print('apk_publish_upload <path_to_apk_file> --auth auth.json');
    print(parser.usage);
  }

  if (help) {
    _usage();
    return;
  }

  if (results.rest.length == 1) {
    // New just give the apk
    var apkFile = results.rest[0];
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
    await nameApk(apkFile);

    //nameIt(apkFile, join(content, 'AndroidManifest.xml'));
  } else {
    if (results.rest.length == 2) {
      await nameIt(results.rest[0], results.rest[1], versionName: versionName);
    } else if (results.rest.isEmpty) {
      var foundTestData = false;

      //String testAuthJsonPath = join('bin', 'tmp', 'client_secret_124267391961-qu3lag0eht68os2cfuj4khn4rb3i6k4g.apps.googleusercontent.com.json');
      var testAuthJsonPath = join('bin', 'tmp',
          'client_secret_243871252418-n20l8un6s86fi5vhkm8gm0d9kg7knige.apps.googleusercontent.com.json');

      if (File(testAuthJsonPath).existsSync()) {
        foundTestData = true;
        Map map = parseJsonObject(await File(testAuthJsonPath).readAsString());
        print(map);

        var authClientInfo =
            await AuthClientInfo.load(filePath: testAuthJsonPath);
        print(authClientInfo);
        var authClient = await authClientInfo.getClient(scopes);

        try {
          var peopleApi = PeopleApi(authClient);
          var person = await peopleApi.people.get('me');
          print(person.toJson());
        } catch (e) {
          stderr.writeln('PlusApi error $e');
        }

        var api = AndroidpublisherApi(authClient);
        /*
        String packageName = 'com.tekartik.buvettekpcm';
        AppEdit appEdit = await api.edits.insert(null, packageName);
        print(appEdit.toJson());
        await api.edits.delete(packageName, appEdit.id);
        */

        var packageName = 'com.tekartik.miniexp';
        var appEdit = await api.edits.insert(null, packageName);
        try {
          print(appEdit.toJson());

          var apkFilePath = join('test', 'data', 'app-release.apk');

          var apkInfo = await getApkInfo(apkFilePath);
          print('name : ${apkInfo.name}');
          print('versionCode : ${apkInfo.versionCode}');
          print('versionName : ${apkInfo.versionName}');

          var data = await File(apkFilePath).readAsBytes();
          var media = commons.Media(Stream.fromIterable([data]), data.length);
          print('uploading ${data.length}...');
          var apk = await api.edits.apks
              .upload(packageName, appEdit.id, uploadMedia: media);
          print('uploaded');
          print('versionCode: ${apk.versionCode}');

          var track = Track();
          // track.track = trackName;
          track.releases = [
            TrackRelease()
              ..versionCodes = [apk.versionCode.toString()]
              ..status = 'completed'
          ]; // v2:versionCodes = [versionCode];
          track = await api.edits.tracks
              .update(track, packageName, appEdit.id, alphaTrackName);
          print('versionCodes: ${track.releases.first.versionCodes}');

          await api.edits.commit(packageName, appEdit.id);
          print('commited');
        } catch (e) {
          try {
            await api.edits.delete(packageName, appEdit.id);
          } catch (e2) {
            stderr.writeln('edits.delete error $e2');
          }
          rethrow;
        }
      }
      if (!foundTestData) {
        print('Missing apk file name');
        _usage();
      }
    }
  }
}
