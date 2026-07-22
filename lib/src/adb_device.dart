import 'package:process_run/shell.dart';

/// Resolves [serial] to a connected device's `adb` serial.
///
/// [serial] accepts several forms:
/// - `'any:5555'` (or any `'any:<port>'`) — the first IP device listening
///   on that port, as found by [findIpDevice].
/// - `'any'` or `null` — the first connected device, as found by
///   [findFirstDevice].
/// - any other value — treated as an exact serial; returned only if it
///   appears in [listDevices].
///
/// Returns the resolved serial, or `null` if no matching device is
/// connected.
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

/// Lists the serials of all devices currently connected to `adb`, by
/// running `adb devices` and parsing its output.
///
/// Returns an empty list if no devices are connected.
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

/// Finds the first connected device whose serial ends with `:[port]`
/// (i.e. a device connected over TCP/IP), such as `192.168.1.10:5555`.
///
/// [port] defaults to `5555`, the standard `adb` TCP/IP port.
///
/// Returns that device's serial, or `null` if none matches.
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

/// Finds the serial of the first device returned by [listDevices].
///
/// Returns `null` if no device is connected.
Future<String?> findFirstDevice() async {
  var devices = await listDevices();
  return devices.firstOrNull;
}
