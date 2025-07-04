import 'package:fs_shim/utils/path.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/apk_utils.dart' as utils;
import 'package:tekartik_android_utils/src/gradle/gradle.dart';

/// Default module name for Android projects
const androidModuleDefault = 'app';

/// Represents an Android module within a project
class AndroidModule {
  /// Project
  final AndroidProject project;

  /// Module name, defaults to [androidModuleDefault]
  final String module;

  /// Creates an instance of [AndroidModule]
  AndroidModule({required this.project, this.module = androidModuleDefault});
}

/// Represents an Android project with methods to build and manage APKs
class AndroidProject {
  /// Path to the Android project directory
  String path;

  /// Constructor for [AndroidProject]
  AndroidProject(this.path);

  /// target can be :app ot app
  ProcessCmd buildApkCmd(String target, {String? flavor}) {
    var gradleTarget = targetToGradleTarget(target);
    var cmd = ProcessCmd(gradleExecutable, [
      '$gradleTarget:assemble${flavor}Release',
    ], workingDirectory: path);
    return cmd;
  }

  /// target can be :app ot app
  Future nameApk(String target) {
    var targetPath = targetToPath(target);
    var baseTarget = basename(targetPath);
    return utils.nameApk(
      join(
        path,
        targetPath,
        'build',
        'outputs',
        'apk',
        '$baseTarget-release.apk',
      ),
    );
  }

  /// target to parts
  static List<String> targetToParts(String target) {
    var parts = <String>[];
    var segments = target.split(':');
    for (var segment in segments) {
      parts.addAll(contextPathSplit(context, segment));
    }
    return parts;
  }

  /// Target to Gradle target
  static String targetToGradleTarget(String target) {
    var parts = targetToParts(target);
    return ':${parts.join(':')}';
  }

  /// Joins all parts into a path
  String targetToPath(String target) {
    var parts = targetToParts(target);
    return joinAll(parts);
  }

  /// Release mode constant
  static const String modeRelease = 'release';

  /// Debug mode constant
  static const String modeDebug = 'debug';

  /// Application module name constant
  static const String moduleApp = 'app';

  /// Gradle shell executable filename
  String get gradleExecutable => join(path, gradleShellExecutableFilename);

  /// mode: debug/release
  String getApkPath({String? flavor, String? module, String? mode}) {
    module ??= moduleApp;
    mode ??= modeRelease;
    if (flavor == null) {
      return join(
        path,
        module,
        'build',
        'outputs',
        'apk',
        mode,
        '$module-$mode.apk',
      );
    } else {
      return join(
        path,
        'app',
        'build',
        'outputs',
        'apk',
        flavor,
        mode,
        '$module-$flavor-$mode.apk',
      );
    }
  }
}
