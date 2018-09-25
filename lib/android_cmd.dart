import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';

ProcessCmd _adbCmd(List<String> args) {
  return ProcessCmd('adb', args);
}

ProcessCmd adbCmd(List<String> args) => _adbCmd(args);

List<String> adbMonkeyArgs(
    {String packageName, int count, int sysKeysPercent = 0}) {
  count ??= 50000;
  List<String> args = ['shell', 'monkey'];
  if (packageName != null) {
    args.addAll(['-p', packageName]);
  }
  if (sysKeysPercent != null) {
    args.addAll(['--pct-syskeys', "$sysKeysPercent"]);
  }

  args.addAll(["$count"]);

  return args;
}

const String defaultEmulatorSerialNumber = "emulator-5554";
// http://stackoverflow.com/questions/20155376/android-stop-emulator-from-command-line
// adb -s emulator-5554 emu kill
ProcessCmd adbKillEmulator({String emulatorName}) {
  emulatorName ??= defaultEmulatorSerialNumber;
  return ProcessCmd('adb', ['-s', emulatorName, 'emu', 'kill']);
}

List<String> shellPsAdbArgs() {
  return ['shell', 'ps'];
}

List<String> shellKill(int pid) {
  return ['shell', 'kill', '${pid}'];
}

class AdbTarget {
  final String serial;

  AdbTarget({this.serial});

  ProcessCmd adbCmd(List<String> args) {
    args ??= [];
    if (serial != null) {
      args.insertAll(0, ["-s", serial]);
    }
    return _adbCmd(args);
  }
}

ProcessCmd nameApkCommand({String flavor}) {
  String filename;
  if (flavor == null) {
    filename = "app-release";
  } else {
    filename = join(flavor, "release", "app-${flavor}-release");
  }
  return ProcessCmd(
      'apk_name_it', [join('app', 'build', 'outputs', 'apk', '$filename.apk')]);
}
