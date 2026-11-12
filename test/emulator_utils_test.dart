import 'package:tekartik_android_utils/adb_utils.dart';
import 'package:tekartik_android_utils/emulator_utils.dart';
import 'package:test/test.dart';

AdbDeviceInfo _device(String serial, [String type = 'device']) =>
    AdbDeviceInfo()
      ..serial = serial
      ..type = type;

void main() {
  group('emulator_utils', () {
    test('emulatorListAvdsParseLines', () {
      expect(
        emulatorListAvdsParseLines([
          'INFO    | Storing crashdata in: /tmp/android-alex/emu-crash.db',
          'Pixel_9',
          'Nexus_7_2012_API_29',
          '',
          'bg_remove.bench-2',
        ]),
        ['Pixel_9', 'Nexus_7_2012_API_29', 'bg_remove.bench-2'],
      );
      expect(emulatorListAvdsParseLines([]), isEmpty);
    });

    test('adbEmuAvdNameParseLines', () {
      expect(
        adbEmuAvdNameParseLines(['bg_remove_bench\r', 'OK\r']),
        'bg_remove_bench',
      );
      expect(adbEmuAvdNameParseLines(['OK']), isNull);
      expect(
        adbEmuAvdNameParseLines(['error: could not connect to TCP port 5554']),
        isNull,
      );
      expect(adbEmuAvdNameParseLines([]), isNull);
    });

    test('androidEmulatorSerialPort', () {
      expect(androidEmulatorSerialPort('emulator-5554'), 5554);
      expect(androidEmulatorSerialPort('emulator-5556'), 5556);
      expect(androidEmulatorSerialPort('192.168.1.54:5555'), isNull);
      expect(androidEmulatorSerialPort('21051522507133'), isNull);
      expect(androidEmulatorSerial(5558), 'emulator-5558');
    });

    test('androidEmulatorFreePort', () {
      expect(androidEmulatorFreePort([]), 5554);
      expect(androidEmulatorFreePort(['emulator-5554', 'R58M123']), 5556);
      expect(androidEmulatorFreePort(['emulator-5556']), 5554);
      expect(
        () => androidEmulatorFreePort([
          for (var port = 5554; port <= 5682; port += 2) 'emulator-$port',
        ]),
        throwsStateError,
      );
    });

    test('androidCommandWithDevice', () {
      expect(
        androidCommandWithDevice([
          'flutter',
          'test',
          'integration_test/sqflite_test.dart',
          '--plain-name',
          'exception',
        ], 'emulator-5554'),
        [
          'flutter',
          'test',
          '-d',
          'emulator-5554',
          'integration_test/sqflite_test.dart',
          '--plain-name',
          'exception',
        ],
      );
      expect(
        androidCommandWithDevice([
          '/opt/flutter/bin/flutter',
          'run',
        ], 'emulator-5556'),
        ['/opt/flutter/bin/flutter', 'run', '-d', 'emulator-5556'],
      );
      // Device already given
      for (var command in [
        ['flutter', 'test', '-d', 'linux'],
        ['flutter', 'test', '--device-id', 'R58M123'],
        ['flutter', 'test', '--device-id=R58M123'],
      ]) {
        expect(androidCommandWithDevice(command, 'emulator-5554'), command);
      }
      // No device option: ANDROID_SERIAL only
      for (var command in [
        ['flutter', 'build', 'apk'],
        ['./gradlew', 'connectedAndroidTest'],
        ['adb', 'shell', 'ls'],
        ['flutter'],
      ]) {
        expect(androidCommandWithDevice(command, 'emulator-5554'), command);
      }
    });

    group('androidEmulatorRunChooseTarget', () {
      var avds = ['Pixel_9', 'bg_remove_bench'];
      String choose({
        List<AdbDeviceInfo> devices = const [],
        Map<String, String?> runningAvdNames = const {},
        List<String>? avdList,
        String? serial,
        String? avd,
      }) => androidEmulatorRunChooseTarget(
        devices: devices,
        runningAvdNames: runningAvdNames,
        avds: avdList ?? avds,
        serial: serial,
        avd: avd,
      ).toString();

      test('serial', () {
        expect(
          choose(devices: [_device('R58M123')], serial: 'R58M123'),
          'use R58M123',
        );
        expect(
          () => choose(
            devices: [_device('R58M123', 'unauthorized')],
            serial: 'R58M123',
          ),
          throwsStateError,
        );
      });

      test('avd', () {
        var devices = [_device('emulator-5554'), _device('emulator-5556')];
        var running = {
          'emulator-5554': 'bg_remove_bench',
          'emulator-5556': 'Pixel_9',
        };
        expect(
          choose(devices: devices, runningAvdNames: running, avd: 'Pixel_9'),
          'use emulator-5556',
        );
        expect(
          choose(
            devices: [_device('emulator-5554')],
            runningAvdNames: {'emulator-5554': 'bg_remove_bench'},
            avd: 'Pixel_9',
          ),
          'launch Pixel_9',
        );
        // Offline emulator of the avd: launch another one
        expect(
          choose(
            devices: [_device('emulator-5556', 'offline')],
            runningAvdNames: {'emulator-5556': 'Pixel_9'},
            avd: 'Pixel_9',
          ),
          'launch Pixel_9',
        );
        expect(() => choose(avd: 'Unknown'), throwsStateError);
      });

      test('default', () {
        // Emulator first
        expect(
          choose(devices: [_device('R58M123'), _device('emulator-5554')]),
          'use emulator-5554',
        );
        expect(choose(devices: [_device('R58M123')]), 'use R58M123');
        expect(
          choose(
            devices: [_device('emulator-5554', 'offline')],
            avdList: ['A'],
          ),
          'launch A',
        );
        expect(() => choose(), throwsStateError);
        expect(() => choose(avdList: []), throwsStateError);
      });
    });
  });
}
