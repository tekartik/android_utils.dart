import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_android_utils/src/import.dart';

/// Options controlling [adbLog].
class AdbLogOptions {
  /// Package name to filter `logcat` output to (only lines from that
  /// package's running process). If `null`, all device logs are streamed
  /// unfiltered.
  final String? package;

  /// Device to target, resolved the same way as [findDevice]'s `serial`
  /// parameter (e.g. `null`/`'any'` for the first device, `'any:<port>'`
  /// for an IP device, or an exact serial). If `null`, `adb` targets
  /// whichever single device is connected.
  final String? serial;

  /// Whether to run the underlying shell commands verbosely.
  final bool verbose;

  /// Creates options for [adbLog] targeting [package] on the device
  /// resolved from [serial], defaulting [verbose] to `false`.
  AdbLogOptions({
    required this.package,
    required this.serial,
    this.verbose = false,
  });
}

/// Streams `adb logcat` output for the device/package described by
/// [options] to stdout, running indefinitely until the process is killed.
///
/// If [AdbLogOptions.package] is set, this polls for the package's process
/// ID and restarts `logcat` filtered to that PID whenever it changes
/// (e.g. after an app restart), rather than using `logcat`'s own package
/// filtering.
Future<void> adbLog(AdbLogOptions options) async {
  var serial = await findDevice(serial: options.serial);
  //var verbose = options.verbose;

  var adb = 'adb';
  if (serial != null) {
    adb = 'adb -s ${shellArgument(serial)}';
  }

  var package = options.package;
  if (package != null) {
    var pidShell = Shell(
      throwOnError: false,
      verbose: false,
      commandVerbose: false,
    );
    Shell? logcatShell;
    int? pid;
    while (true) {
      var output = (await pidShell.run(
        '$adb shell pidof ${shellArgument(package)}',
      )).outText.trim();
      var newPid = int.tryParse(output);
      if (newPid != pid) {
        pid = newPid;
        () async {
          logcatShell?.kill();
          if (newPid != null) {
            var deviceDate = DateTime.parse(
              (await run(
                '$adb shell date +%Y-%m-%dT%H:%M:%S',
                verbose: false,
              )).outText.trim(),
            ).subtract(const Duration(seconds: 5));
            //   -T '<time>'     Print most recent lines since specified time (not imply -d)
            //                   count is pure numerical, time is 'MM-DD hh:mm:ss.mmm...'
            //                   'YYYY-MM-DD hh:mm:ss.mmm...' or 'sssss.mmm...' format
            // var outputDate = outputFormat.format(inputDate);
            var minDate = deviceDate.toIso8601String().replaceAll('T', ' ');
            try {
              var shell = logcatShell = Shell(
                throwOnError: false,
                verbose: true,
              );
              await shell.run(
                '$adb logcat --pid=$newPid -T ${shellArgument(minDate)}',
              );
            } catch (_) {}
          }
        }().unawait();
      }
      await sleep(1000);
    }
  } else {
    await run('$adb logcat');
  }
}
