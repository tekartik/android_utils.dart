import 'package:args/args.dart';
import 'package:tekartik_android_utils/src/avd_utils.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

Future<void> main(List<String> arguments) async {
  var parser =
      ArgParser()
        ..addFlag('force', abbr: 'f', help: 'Force')
        ..addFlag('help', abbr: 'h', help: 'This help');
  var result = parser.parse(arguments);
  var rest = result.rest;
  var force = result['force'] as bool;
  var help = result['help'] as bool;

  if (help) {
    stdout.writeln('usage mode_avd <avd_name> <folder>');
    stdout.writeln(parser.usage);
    return;
  }
  String? avd;
  String? folder;
  if (rest.isNotEmpty) {
    avd = rest.first;
  }
  if (rest.length > 1) {
    folder = rest[1];
  }
  if (avd == null || folder == null) {
    stderr.writeln('usage mode_avd <avd_name> <folder>');
    exit(1);
  }
  await moveAvdFolder(avd: avd, dst: folder, force: force);
}
