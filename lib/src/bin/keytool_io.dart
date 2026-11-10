import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/bin/keytool.dart';

/// Gets the signing certificate's SHA-1 digest (upper case, colon-separated
/// hex) of the apk at [apkPath], by running `keytool -printcert -jarfile`.
///
/// Returns the digest, or `null` if it couldn't be found in the output.
Future<String?> apkExtractSha1Digest(String apkPath) async {
  var shell = Shell(verbose: false);
  var lines = (await shell.run(
    'keytool -printcert -jarfile ${shellArgument(apkPath)}',
  )).outLines;
  var sha1Digest = keytoolOutLinesExtractSha1Digest(lines);
  return sha1Digest;
}
