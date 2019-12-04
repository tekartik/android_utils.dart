import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
dartfmt -n --set-exit-if-changed .
dartanalyzer --fatal-warnings --fatal-infos .
# pub run build_runner test -- -p vm
pub run test -p vm
''');
}
