import 'package:process_run/shell.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

/// Supports:
///
/// `any:5555`: first ip device
/// `any`: first device
/// <serial>
Future<String?> findDevice(String serial) async {
  if (serial.startsWith('any:')) {
    return await findIpDevice(int.parse(serial.split(':').last));
  } else if (serial == 'any') {
    return await findFirstDevice();
  }
  return serial;
}

Future<String?> findIpDevice(int port) async {
  var outlines = (await run('adb devices', verbose: false)).outLines;
  String? ipDevice;
  for (var line in outlines) {
    try {
      var first = line.split(' ').first.split('\t').first;
      if (first.endsWith(':$port')) {
        ipDevice = first;
        break;
      }
    } catch (_) {}
  }
  return ipDevice;
}

Future<String?> findFirstDevice() async {
  var outlines = (await run('adb devices', verbose: false)).outLines;
  String? serial;
  for (var line in outlines) {
    if (line.startsWith('List of')) {
      continue;
    }
    try {
      var first = line.split(' ').first.split('\t').first;
      if (first.isNotEmpty) {
        serial = first;
        break;
      }
    } catch (_) {}
  }
  return serial;
}
