import 'package:process_run/shell.dart';

/// Supports:
///
/// `any:5555`: first ip device
/// `any` or `<null>`: first device
/// `<serial>`
Future<String?> findDevice({String? serial}) async {
  if (serial?.startsWith('any:') ?? false) {
    return await findIpDevice(port: int.parse(serial!.split(':').last));
  } else if (serial == 'any' || serial == 'null') {
    return await findFirstDevice();
  }
  return null;
}

Future<String?> findIpDevice({int port = 5555}) async {
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
