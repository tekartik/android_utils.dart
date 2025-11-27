import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_app_dev_menu/dev_menu.dart';

/// Show a menu to select device id and set it to the provided KeyValue
void keyValueDeviceIdMenu(KeyValue kvDeviceId) {
  keyValuesMenu('vars', [kvDeviceId]);
  _keyValueDeviceIdMenu(kvDeviceId);
}

/// Show a menu to select device ids and set them to the provided KeyValues
void keyValuesDeviceIdMenu(List<KeyValue> deviceIds) {
  menu('device ids config', () {
    keyValuesMenu('vars', deviceIds);
    for (var kvDeviceId in deviceIds) {
      _keyValueDeviceIdMenu(kvDeviceId);
    }
  });
}

/// Show a menu to select device id and set it to the provided KeyValue
void _keyValueDeviceIdMenu(KeyValue kvDeviceId) {
  item('${kvDeviceId.key} - select device id', () async {
    var deviceId = kvDeviceId.value;
    write('Current device id: $deviceId');
    var devices = await listDevices();
    await showMenu(() {
      for (var device in devices) {
        item(device, () async {
          await kvDeviceId.set(device);
          write('Selected device id: $device');
          await popMenu();
        });
      }
      item('none', () async {
        await kvDeviceId.set(null);
        write('Selected no device');
        await popMenu();
      });
    });
  });
}
