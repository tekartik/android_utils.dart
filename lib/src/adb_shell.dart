import 'package:tekartik_android_utils/src/import.dart';

class ShellPsParser {
  PsHeader? header;
  List<PsLine> lines = [];

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

  PsLine? findByName(String name) {
    for (var line in lines) {
      try {
        if (line.name == name) {
          return line;
        }
      } catch (e) {
        print(e);
        print(line);
      }
    }
    return null;
  }
}

// USER      PID   PPID  VSIZE  RSS   WCHAN            PC  NAME
class PsHeader extends _PsLineBase {
  PsHeader(String line) : super(line) {
    //devPrint(_parts);
  }

  int findPartIndex(String name) {
    return _parts.indexOf(name);
  }
}

PsHeader _defaultHeader =
    PsHeader('USER      PID   PPID  VSIZE  RSS   WCHAN            PC  NAME');

class PsLine extends _PsLineBase {
  late PsHeader _header;

  PsLine(String line, {PsHeader? header}) : super(line) {
    _header = header ?? _defaultHeader;
  }

  int get pid => int.parse(_getColumn('PID')!);

  String? _getColumn(String name) {
    var index = _header.findPartIndex(name);
    if (index >= 0) {
      return _parts[index];
    }
    return null;
  }

  String get name => _parts[8]; //_getColumn('NAME');
// shell     7398  1310  1217116 16816 binder_thr a9529424 S com.android.commands.monkey
}

var spaceSplitRegExp = RegExp('\\s+');

class _PsLineBase {
  late List<String> _parts;

  _PsLineBase(String line) {
    _parts = line.split(spaceSplitRegExp);
  }

  @override
  String toString() => _parts.join(' ');
}
