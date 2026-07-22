import 'package:process_run/shell.dart';

bool? _apksignerSupported;

/// Checks if the `apksigner` tool is available on the system.
bool get apksignerSupported =>
    _apksignerSupported ??= whichSync('apksigner') != null;

/// Gets the signing certificate's SHA-1 digest of the apk at [apkPath], by
/// running `apksigner verify --print-certs` and parsing its output.
///
/// If [verbose] is `true` (defaults to `false`), the underlying command's
/// output is logged.
///
/// Returns the digest, or `null` if it couldn't be found in the output.
Future<String?> getApkSha1(String apkPath, {bool verbose = false}) async {
  var outLines = (await Shell(
    verbose: verbose,
  ).run('apksigner verify --print-certs $apkPath')).outLines;
  return extractApkSignerSha1Digest(outLines);
}

/// Extracts the `certificate SHA-1 digest` value from [lines] — the output
/// of `apksigner verify --print-certs`.
///
/// Returns the digest, or `null` if no matching line is found.
String? extractApkSignerSha1Digest(Iterable<String> lines) {
  for (var line in lines) {
    var pre = 'certificate SHA-1 digest: ';
    var index = line.indexOf(pre);
    if (index > 1) {
      return line.substring(index + pre.length).trim().split(' ').first.trim();
    }
  }
  return null;
}
