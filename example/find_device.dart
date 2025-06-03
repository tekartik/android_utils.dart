import 'dart:io';

import 'package:tekartik_android_utils/adb_device.dart';

/// Main dart
Future<void> main(List<String> arguments) async {
  // Example usage of findDevice
  for (var serial in ['any', 'any:5555', null, 'emulator-5554']) {
    stdout.writeln('Find device $serial:');
    var device = await findDevice(serial: serial);
    if (device != null) {
      stdout.writeln('  Found device: $device');
    } else {
      stderr.writeln('  No device found');
    }
  }
}
