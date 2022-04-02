import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_android_utils/src/import.dart';

/// Adb log options
class AdbLogOptions {
  /// Optional all logs are displayed otherwise
  final String? package;

  /// Optional `any` for first device, `any:<port>` for device by ip
  final String? serial;

  /// Verbose commands
  final bool verbose;

  AdbLogOptions(
      {required this.package, required this.serial, this.verbose = false});
}

/// Log for a given device and package
Future<void> adbLog(AdbLogOptions options) async {
  var serial = await findDevice(serial: options.serial);
  //var verbose = options.verbose;

  var adb = 'adb';
  if (serial != null) {
    adb = 'adb -s ${shellArgument(serial)}';
  }

  var package = options.package;
  if (package != null) {
    var pidShell =
        Shell(throwOnError: false, verbose: false, commandVerbose: false);
    Shell? logcatShell;
    int? pid;
    while (true) {
      var output =
          (await pidShell.run('$adb shell pidof ${shellArgument(package)}'))
              .outText
              .trim();
      var newPid = int.tryParse(output);
      if (newPid != pid) {
        pid = newPid;
        () async {
          logcatShell?.kill();
          if (newPid != null) {
            var deviceDate = DateTime.parse((await run(
                        '$adb shell date +%Y-%m-%dT%H:%M:%S',
                        verbose: false))
                    .outText
                    .trim())
                .subtract(Duration(seconds: 5));
            //   -T '<time>'     Print most recent lines since specified time (not imply -d)
            //                   count is pure numerical, time is 'MM-DD hh:mm:ss.mmm...'
            //                   'YYYY-MM-DD hh:mm:ss.mmm...' or 'sssss.mmm...' format
            // var outputDate = outputFormat.format(inputDate);
            var minDate = deviceDate.toIso8601String().replaceAll('T', ' ');
            try {
              var shell =
                  logcatShell = Shell(throwOnError: false, verbose: true);
              await shell.run(
                  '$adb logcat --pid=$newPid -T ${shellArgument(minDate)}');
            } catch (_) {}
          }
        }()
            .unawait();
      }
      await sleep(1000);
    }
  } else {
    await run('$adb logcat');
  }
}
