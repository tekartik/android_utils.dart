import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_android_utils/adb_utils.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var androidFromEnv = ShellEnvironment().vars['TK_ANDROID_UTILS_ANDROID_FROM'];
  var firstDevice = await findDevice(serial: 'emulator-5554');
  print('firstDevice: $firstDevice, androidFromEnv: $androidFromEnv');
  group('device', () {
    var androidFrom = androidFromEnv;
    var device = firstDevice;
    if (androidFrom != null && device != null) {
      test('list root files', () async {
        var shell = Shell();
        await shell.run('adb -s $device shell ls -l /');
      });
      test('copy from', () async {
        var deviceAdb = DeviceAdb(device);
        await deviceAdb.pullDirectory(androidFrom, '.local/localTo');
      });
      test('file exists', () async {
        var deviceAdb = DeviceAdb(device);
        var fileExists = await deviceAdb.fileExists(androidFrom);
        expect(fileExists, isTrue);
        fileExists = await deviceAdb.fileExists('${androidFrom}_dummy');
        expect(fileExists, isFalse);
      });
    }
  }, skip: firstDevice == null || androidFromEnv == null);
}
