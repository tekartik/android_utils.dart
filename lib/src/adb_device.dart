import 'package:process_run/shell.dart';

/// Supports:
///
/// `any:5555`: first ip device
/// `any` or `<null>`: first device
/// `<serial>`
Future<String?> findDevice({String? serial}) async {
  if (serial?.startsWith('any:') ?? false) {
    return await findIpDevice(port: int.parse(serial!.split(':').last));
  } else if (serial == 'any' || serial == null) {
    return await findFirstDevice();
  } else {
    var devices = await listDevices();
    if (devices.contains(serial)) {
      return serial;
    }
  }
  return null;
}

/// Lists all connected devices.
Future<List<String>> listDevices() async {
  var outlines = (await run('adb devices', verbose: false)).outLines;
  var devices = <String>[];
  for (var line in outlines) {
    if (line.startsWith('List of')) {
      continue;
    }
    try {
      var first = line.split(' ').first.split('\t').first;
      if (first.isNotEmpty) {
        devices.add(first);
      }
    } catch (_) {}
  }
  return devices;
}

/// Finds the first IP device with the specified port.
Future<String?> findIpDevice({int port = 5555}) async {
  var devices = await listDevices();
  for (var device in devices) {
    try {
      if (device.endsWith(':$port')) {
        return device;
      }
    } catch (_) {}
  }
  return null;
}

/// Finds the first device.
Future<String?> findFirstDevice() async {
  var devices = await listDevices();
  return devices.firstOrNull;
}
