import 'dart:convert';

import 'package:tekartik_android_utils/adb_utils.dart';
import 'package:test/test.dart';

void main() {
  group('adbDeviceInfosParseLines', () {
    const output = '''
* daemon not running; starting now at tcp:5037
* daemon started successfully
List of devices attached
emulator-5554          device product:sdk_gphone64_x86_64 model:sdk_gphone64_x86_64 device:emu64xa transport_id:1
R58M12345AB            unauthorized usb:1-1 transport_id:3
192.168.1.54:5555      offline transport_id:4
0123456789ABCDEF\tdevice

''';
    late List<AdbDeviceInfo> infos;
    setUpAll(() {
      infos = adbDeviceInfosParseLines(LineSplitter.split(output));
    });

    test('all listed devices', () {
      expect(infos.map((info) => info.serial), [
        'emulator-5554',
        'R58M12345AB',
        '192.168.1.54:5555',
        '0123456789ABCDEF',
      ]);
      expect(infos.last.type, 'device');
    });

    test('product, model and device', () {
      var info = infos.first;
      expect(info.serial, 'emulator-5554');
      expect(info.type, 'device');
      expect(info.product, 'sdk_gphone64_x86_64');
      expect(info.model, 'sdk_gphone64_x86_64');
      expect(info.device, 'emu64xa');
    });

    test('unauthorized and offline', () {
      expect(infos[1].type, 'unauthorized');
      expect(infos[1].product, isNull);
      expect(infos[1].model, isNull);
      expect(infos[1].device, isNull);
      expect(infos[2].type, 'offline');
    });

    test('nothing before the list header', () {
      expect(adbDeviceInfosParseLines(['emulator-5554 device']), isEmpty);
    });
  });
}
