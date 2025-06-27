// ignore_for_file: depend_on_referenced_packages

import 'package:dev_build/menu/menu_io.dart';
import 'package:dev_build/shell.dart';
import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_app_date/date_time_utils.dart';
import 'package:tekartik_app_dev_menu/dev_menu.dart';

var deviceIdVar = 'tkadb_device_id'.kvFromVar();

String? get deviceId => deviceIdVar.value;
void main(List<String> args) {
  mainMenuConsole(args, () {
    keyValuesMenu('vars', [deviceIdVar]);
    item('select device id', () async {
      var deviceId = deviceIdVar.value;
      write('Current device id: $deviceId');
      var devices = await listDevices();
      await showMenu(() {
        for (var device in devices) {
          item(device, () async {
            await deviceIdVar.set(device);
            write('Selected device id: $device');
          });
        }
        item('none', () async {
          await deviceIdVar.set(null);
          write('Selected no device');
        });
      });
    });
    item('snap screen', () async {
      var adb = 'adb ${deviceId != null ? '-s $deviceId' : ''}';
      var shell = Shell();
      await shell.run('$adb shell screencap -p /sdcard/snapshot.png');
      write('Screen captured to /sdcard/snapshot.png');
      var localPath =
          '.local/snapshot_${DateTime.now().sanitizeToSeconds()}.png';
      await shell.run('$adb pull /sdcard/snapshot.png $localPath');
      write('Screen pulled to current directory as $localPath');
    });
  });
}
