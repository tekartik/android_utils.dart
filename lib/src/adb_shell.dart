import 'dart:io';

import 'package:tekartik_android_utils/src/import.dart';

/// A parser for the output of the `ps` command run over an `adb shell`.
class ShellPsParser {
  /// The parsed header line (column names), or `null` if [shellPsStdout]
  /// passed to the constructor was empty.
  PsHeader? header;

  /// Every non-header line of the `ps` output, parsed as [PsLine]s, in the
  /// order they appeared.
  List<PsLine> lines = [];

  /// Parses [shellPsStdout] (the full stdout of a `ps` command), treating
  /// its first line as the column [header] and every subsequent line as an
  /// entry in [lines].
  ShellPsParser(String shellPsStdout) {
    var lines = LineSplitter.split(shellPsStdout);

    for (var line in lines) {
      if (header == null) {
        header = PsHeader(line);
      } else {
        this.lines.add(PsLine(line, header: header));
      }
    }
  }

  /// Finds the first entry in [lines] whose [PsLine.name] equals [name].
  ///
  /// Returns `null` if no such entry exists.
  PsLine? findByName(String name) {
    for (var line in lines) {
      try {
        if (line.name == name) {
          return line;
        }
      } catch (e) {
        stdout.writeln(e);
        stdout.writeln(line);
      }
    }
    return null;
  }
}

// USER      PID   PPID  VSIZE  RSS   WCHAN            PC  NAME
/// The header line of `ps` output (e.g.
/// `USER      PID   PPID  VSIZE  RSS   WCHAN            PC  NAME`), used to
/// map column names to positions in each [PsLine].
class PsHeader extends _PsLineBase {
  /// Parses [line] (the raw header text) into whitespace-separated column
  /// names, made available via [findPartIndex].
  PsHeader(super.line) {
    //devstdout.writeln(_parts);
  }

  /// Returns the 0-based column index of [name] (e.g. `'PID'`), or `-1` if
  /// no column with that name exists in this header.
  int findPartIndex(String name) {
    return _parts.indexOf(name);
  }
}

PsHeader _defaultHeader = PsHeader(
  'USER      PID   PPID  VSIZE  RSS   WCHAN            PC  NAME',
);

/// A single process entry parsed from a `ps` output line.
class PsLine extends _PsLineBase {
  late PsHeader _header;

  /// Parses one `ps` output [line] into whitespace-separated columns.
  ///
  /// [header] provides the column-name-to-index mapping used by [pid];
  /// if omitted, a default header matching the standard Android `ps`
  /// column layout is used.
  PsLine(super.line, {PsHeader? header}) {
    _header = header ?? _defaultHeader;
  }

  /// The process ID, parsed from the `PID` column as located via [header].
  int get pid => int.parse(_getColumn('PID')!);

  String? _getColumn(String name) {
    var index = _header.findPartIndex(name);
    if (index >= 0) {
      return _parts[index];
    }
    return null;
  }

  /// The process/command name, taken from the fixed 9th whitespace-
  /// separated column of the line (matching the standard `ps` layout,
  /// regardless of [header]).
  String get name => _parts[8]; //_getColumn('NAME');
  // shell     7398  1310  1217116 16816 binder_thr a9529424 S com.android.commands.monkey
}

/// Regular expression matching one or more whitespace characters, used to
/// split `ps` output lines into columns.
var spaceSplitRegExp = RegExp('\\s+');

class _PsLineBase {
  late List<String> _parts;

  _PsLineBase(String line) {
    _parts = line.split(spaceSplitRegExp);
  }

  @override
  String toString() => _parts.join(' ');
}
