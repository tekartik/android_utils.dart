import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:tekartik_android_utils/src/build_utils.dart';
import 'package:tekartik_common_utils/ini_file_utils.dart';
import 'package:tekartik_io_utils/directory_utils.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

Future<void> main(List<String> arguments) async {
  /*var parser = ArgParser();
  var result = parser.parse(arguments);
  var rest = result.rest;

  String? avd;
  String? folder;
  if (rest.isNotEmpty) {
    avd = rest.first;
  }
  if (rest.length > 1) {
    folder = rest[1];
  }*/
  var bc = await getAndroidBuildContent();
  var iniFiles = (await Directory(bc.androidAvdHomePath!)
      .list()
      .where((event) => extension(event.path) == '.ini')
      .map((event) => event.path)
      .toList())
    ..sort();

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
