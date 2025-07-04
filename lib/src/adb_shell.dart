import 'dart:io';

import 'package:tekartik_android_utils/src/import.dart';

/// A parser for the output of the `ps` command in shell.
class ShellPsParser {
  /// Found header
  PsHeader? header;

  /// List of parsed lines
  List<PsLine> lines = [];

  /// Creates a [ShellPsParser] instance by parsing the provided [shellPsStdout].
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

  /// Finds lines by the command name.
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
/// Shell header line
class PsHeader extends _PsLineBase {
  /// List of parts in the header line
  PsHeader(super.line) {
    //devstdout.writeln(_parts);
  }

  /// Fint par index
  int findPartIndex(String name) {
    return _parts.indexOf(name);
  }
}

PsHeader _defaultHeader = PsHeader(
  'USER      PID   PPID  VSIZE  RSS   WCHAN            PC  NAME',
);

/// Represents a line in the output of the `ps` command in shell.
class PsLine extends _PsLineBase {
  late PsHeader _header;

  /// Creates a [PsLine] instance with the provided [line] and an optional [header].
  PsLine(super.line, {PsHeader? header}) {
    _header = header ?? _defaultHeader;
  }

  /// Process ID
  int get pid => int.parse(_getColumn('PID')!);

  String? _getColumn(String name) {
    var index = _header.findPartIndex(name);
    if (index >= 0) {
      return _parts[index];
    }
    return null;
  }

  /// name
  String get name => _parts[8]; //_getColumn('NAME');
  // shell     7398  1310  1217116 16816 binder_thr a9529424 S com.android.commands.monkey
}

/// Regular expression to split parts by spaces
var spaceSplitRegExp = RegExp('\\s+');

class _PsLineBase {
  late List<String> _parts;

  _PsLineBase(String line) {
    _parts = line.split(spaceSplitRegExp);
  }

  @override
  String toString() => _parts.join(' ');
}
