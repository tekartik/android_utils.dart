import 'package:tekartik_io_utils/io_utils_import.dart';
import 'package:process_run/cmd_run.dart';
import 'package:path/path.dart';
import 'package:fs_shim/utils/part.dart';
import 'package:tekartik_android_utils/apk_utils.dart' as utils;
class AndroidProject {
  String path;
  AndroidProject(this.path);
  // target can be :app ot app
  ProcessCmd buildApkCmd(String target) {
    String gradleTarget = targetToGradleTarget(target);
    ProcessCmd cmd =   new ProcessCmd(
          '$path/gradlew', ['$gradleTarget:assembleRelease'], workingDirectory: path);
    return cmd;
  }
  // target can be :app ot app
  Future nameApk(String target) {
    String targetPath = targetToPath(target);
    String baseTarget = basename(targetPath);
    return utils.nameApk(join(path, targetPath, 'build', 'outputs', 'apk', '${baseTarget}-release.apk'));
  }

  static List<String> targetToParts(String target) {
    List<String> parts = [];
    List<String> segments = target.split(':');
    for (String segment in segments) {
      parts.addAll(splitParts(segment));
    }
    return parts;

  }
  static String targetToGradleTarget(String target) {
    List<String> parts = targetToParts(target);
    return ':${parts.join(':')}';

  }

  String targetToPath(String target) {
    List<String> parts = targetToParts(target);
    return '${joinAll(parts)}';
  }
}