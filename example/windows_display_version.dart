import 'package:tekartik_android_utils/src/build_utils.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

Future<void> main() async {
  if (Platform.isWindows) {
    var displayVersion = await readRegistryString(
      'HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion',
      'DisplayVersion',
    );
    stdout.writeln(displayVersion);
  }
}
