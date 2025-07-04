import 'package:process_run/shell.dart';

bool? _apksignerSupported;

/// Checks if the `apksigner` tool is available on the system.
bool get apksignerSupported =>
    _apksignerSupported ??= whichSync('apksigner') != null;

/// Gets the SHA-1 digest of the APK file using `apksigner`.
Future<String?> getApkSha1(String apkPath, {bool verbose = false}) async {
  var outLines = (await Shell(
    verbose: verbose,
  ).run('apksigner verify --print-certs $apkPath')).outLines;
  return extractApkSignerSha1Digest(outLines);
}

/// Extracts the SHA-1 digest from the output lines of `apksigner`.
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
