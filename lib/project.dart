import 'package:fs_shim/utils/part.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/apk_utils.dart' as utils;
import 'package:tekartik_io_utils/io_utils_import.dart';
import 'package:tekartik_build_utils/gradle/gradle.dart';

class AndroidProject {
  String path;

  AndroidProject(this.path);

  // target can be :app ot app
  ProcessCmd buildApkCmd(String target, {String flavor}) {
    String gradleTarget = targetToGradleTarget(target);
    ProcessCmd cmd = new ProcessCmd(
        gradleExecutable, ['$gradleTarget:assemble${flavor}Release'],
        workingDirectory: path);
    return cmd;
  }

  // target can be :app ot app
  Future nameApk(String target) {
    String targetPath = targetToPath(target);
    String baseTarget = basename(targetPath);
    return utils.nameApk(join(path, targetPath, 'build', 'outputs', 'apk',
        '${baseTarget}-release.apk'));
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

  static const String modeRelease = "release";
  static const String modeDebug = "debug";

  static const String moduleApp = "app";

  String get gradleExecutable => join(path, gradleShellExecutableFilename);

  // mode: debug/release
  String getApkPath({String flavor, String module, String mode}) {
    module ??= moduleApp;
    mode ??= modeRelease;
    if (flavor == null) {
      return join(
          path, module, 'build', 'outputs', 'apk', mode, "$module-$mode.apk");
    } else {
      return join(path, 'app', 'build', 'outputs', 'apk', flavor, mode,
          '${module}-${flavor}-${mode}.apk');
    }
  }
}
