import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/avd_utils.dart';
import 'package:tekartik_android_utils/src/import.dart';
import 'package:tekartik_io_utils/directory_utils.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

Future<void> main() async {
  var iniFiles = await getAvdIniFileNames();

  var fmt = NumberFormat();
  for (var iniFile in iniFiles) {
    var lines = await File(iniFile).readAsLines();
    var map = parseIniLines(lines);
    var path = await File(map['path'] as String).resolveSymbolicLinks();

    var sb = StringBuffer();
    sb.write(basenameWithoutExtension(iniFile).padLeft(30));
    sb.write(' ');
    sb.write(fmt.format(await dirSize(path)).toString().padLeft(15));
    if (dirname(path) != dirname(iniFile)) {
      sb.write(' ');
      sb.write(path);
    }
    stdout.writeln(sb);
  }
}
