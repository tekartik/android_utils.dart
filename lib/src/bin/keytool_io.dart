import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/bin/keytool.dart';

/// Extract upper case SHA1
Future<String> apkExtractSha1Digest(String apkPath) async {
  var shell = Shell(verbose: false);
  var lines =
      (await shell.run('keytool -printcert -jarfile $apkPath')).outLines;
  var sha1Digest = keytoolOutLinesExtractSha1Digest(lines);
  return sha1Digest;
}
