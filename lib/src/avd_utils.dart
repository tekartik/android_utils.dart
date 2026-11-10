import 'dart:io';

import 'package:fs_shim/utils/io/copy.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:tekartik_android_utils/build_utils.dart';
import 'package:tekartik_android_utils/src/import.dart';

/// AVD information
class AvdInfo {
  /// Name of the AVD
  String? name;

  /// Device name
  String? device;

  /// Path to the AVD
  String? path;

  /// Target of the AVD
  String? target;

  /// Skin of the AVD
  String? skin;

  /// SD card of the AVD
  String? sdCard;
}

/// Parses [lines] — the stdout of `avdmanager list avd` — into one
/// [AvdInfo] per AVD entry (entries are separated by `----` lines).
///
/// Returns an empty list if [lines] contains no valid entries.
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

/// Runs `avdmanager list avd` and parses its output into [AvdInfo]s, one
/// per configured AVD.
///
/// [initAndroidBuildEnvironment] must have been called first.
Future<List<AvdInfo?>> getAvdInfos() async {
  var lines = (await run('avdmanager list avd')).outLines;
  return avdInfosParseLines(lines);
}

/// Returns the absolute, normalized paths of all `.ini` files directly
/// under the Android SDK's AVD home directory, sorted alphabetically.
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

/// Moves the on-disk folder (and updates the `.ini` file) of the AVD named
/// [avd] into the [dst] directory.
///
/// [dst] may be relative (the `.ini` file gets its absolute path); a [dst]
/// naming the folder already holding the AVD (trailing slash, relative
/// path, symbolic link) does nothing.
///
/// If a folder for [avd] already exists under [dst], the move is skipped
/// unless [force] is `true` (defaults to `false`), in which case the
/// existing destination folder is deleted first. Writes progress to
/// stdout/stderr; does nothing (besides logging to stderr) if no AVD named
/// [avd] is found.
Future<void> moveAvdFolder({
  required String avd,
  required String dst,
  bool force = false,
}) async {
  var iniFiles = await getAvdIniFileNames();
  // Absolute (written in the .ini file) and canonical (compared with the
  // resolved avd folder: a trailing slash, a relative path or a link to
  // the same folder must not delete the avd).
  dst = normalize(absolute(dst));
  var canonicalDst = dst;
  if (Directory(dst).existsSync()) {
    canonicalDst = await Directory(dst).resolveSymbolicLinks();
  }

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
      if (avdTopDir != canonicalDst) {
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
        var content = (await File(
          iniFile,
        ).readAsString()).replaceAll(pathInIniFile, dstPath);
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
