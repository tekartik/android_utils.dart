import 'dart:io';

import 'package:fs_shim/utils/io/copy.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:tekartik_android_utils/src/import.dart';

class AvdInfo {
  String? name;
  String? device;
  String? path;
  String? target;
  String? skin;
  String? sdCard;
}

List<AvdInfo?> avdInfosParseLines(Iterable<String> lines) {
  var list = <AvdInfo?>[];
  AvdInfo? avdInfo;
  String? key;
  String? value;

  void validatePreviousValue() {
    if (avdInfo != null && key != null && value != null) {
      // We expect the name first
      if (avdInfo!.name != null || key == 'name') {
        switch (key) {
          case 'name':
            avdInfo!.name = value;
            break;
          case 'device':
            avdInfo!.device = value;
            break;
          case 'path':
            avdInfo!.path = value;
            break;
          case 'target':
            avdInfo!.target = value;
            break;
          case 'skin':
            avdInfo!.skin = value;
            break;
          case 'sdcard':
            avdInfo!.sdCard = value;
            break;
        }
      }
      key = null;
      value = null;
    }
  }

  void validatePreviousAvd() {
    if (avdInfo != null && avdInfo!.name != null) {
      list.add(avdInfo);
      avdInfo = null;
    }
  }

  for (var line in lines) {
    if (line.startsWith('----')) {
      validatePreviousValue();
      validatePreviousAvd();
    }
    avdInfo ??= AvdInfo();
    var parts = line.split(':');

    if (parts[0].length < 10) {
      validatePreviousValue();
      key = parts[0].toLowerCase().trim();
    }
    if (parts.length > 1) {
      var partValue = parts.sublist(1).join(':').trim();
      if (value != null) {
        value = '$value\n$partValue';
      } else {
        value = partValue;
      }
    }
  }
  validatePreviousValue();
  validatePreviousAvd();
  return list;
}

/// [initAndroidBuildEnvironment] must have been called first
Future<List<AvdInfo?>> getAvdInfos() async {
  var lines = (await run('avdmanager list avd')).outLines;
  return avdInfosParseLines(lines);
}

Future<List<String>> getAvdIniFileNames() async {
  var bc = await getAndroidBuildContext();
  var iniFiles =
      (await Directory(bc.androidAvdHomePath!)
            .list()
            .where((event) => extension(event.path).toLowerCase() == '.ini')
            .map((event) => normalize(absolute(event.path)))
            .toList())
        ..sort();
  return iniFiles;
}

Future<void> moveAvdFolder({
  required String avd,
  required String dst,
  bool force = false,
}) async {
  var iniFiles = await getAvdIniFileNames();

  var found = false;
  for (var iniFile in iniFiles) {
    // devPrint(basename(iniFile));
    if (basenameWithoutExtension(iniFile) == avd) {
      found = true;
      var lines = await File(iniFile).readAsLines();
      var map = parseIniLines(lines);
      var pathInIniFile = map['path'] as String;

      late String path;
      try {
        path = await File(pathInIniFile).resolveSymbolicLinks();
      } catch (_) {
        path = join(dirname(iniFile), '$avd.avd');
        stdout.writeln('Missing dest folder try local avd file $path');
        path = await File(path).resolveSymbolicLinks();
      }

      var sb = StringBuffer();

      var avdTopDir = dirname(path);
      if (avdTopDir != dst) {
        var dstPath = join(dst, '$avd.avd');
        stdout.writeln('Moving $path to $dstPath...');

        if (Directory(dstPath).existsSync()) {
          stdout.writeln('Directory already exists');
          if (!force) {
            return;
          }
        }

        try {
          await Directory(dstPath).delete(recursive: true);
        } catch (_) {}
        await copyDirectory(Directory(path), Directory(dstPath));

        stdout.writeln('Updating $iniFile');
        var content = (await File(iniFile).readAsString()).replaceAll(
          pathInIniFile,
          dstPath,
        );
        await File(iniFile).writeAsString(content);

        stdout.writeln('Deleting $path');
        // Delete source
        await Directory(path).delete(recursive: true);
      }
      sb.write(basenameWithoutExtension(iniFile).padLeft(30));
      if (dirname(path) != dirname(iniFile)) {
        sb.write(' ');
        sb.write(path);
      }
      stdout.writeln(sb);
    }
  }

  if (!found) {
    stderr.writeln('Could not find avd $avd');
  }
}
