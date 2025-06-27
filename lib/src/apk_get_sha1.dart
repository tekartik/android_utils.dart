import 'package:process_run/shell.dart';

bool? _apksignerSupported;
bool get apksignerSupported =>
    _apksignerSupported ??= whichSync('apksigner') != null;

Future<String?> getApkSha1(String apkPath, {bool verbose = false}) async {
  var outLines = (await Shell(
    verbose: verbose,
  ).run('apksigner verify --print-certs $apkPath')).outLines;
  return extractApkSignerSha1Digest(outLines);
}

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
