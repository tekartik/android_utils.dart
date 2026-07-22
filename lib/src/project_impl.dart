import 'package:fs_shim/utils/path.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_android_utils/apk_utils.dart' as utils;
import 'package:tekartik_android_utils/src/gradle/gradle.dart';

/// Default module name for Android projects, used as [AndroidModule.module]
/// when none is specified.
const androidModuleDefault = 'app';

/// A named module (e.g. Gradle sub-project) within an [AndroidProject].
class AndroidModule {
  /// The project this module belongs to.
  final AndroidProject project;

  /// Module name, defaults to [androidModuleDefault].
  final String module;

  /// Creates a reference to the module named [module] (defaults to
  /// [androidModuleDefault]) within [project].
  AndroidModule({required this.project, this.module = androidModuleDefault});
}

/// An Android project on disk, providing helpers to resolve Gradle targets
/// and build/locate/name its apk outputs.
class AndroidProject {
  /// Path to the Android project's root directory.
  String path;

  /// Creates a reference to the Android project rooted at [path].
  AndroidProject(this.path);

  /// Builds the `ProcessCmd` for `./gradlew <target>:assemble<flavor>Release`,
  /// where [target] is a Gradle target path (e.g. `':app'` or `'app'`,
  /// see [targetToGradleTarget]) and [flavor] (if given) is prepended to
  /// the `Release` build variant name.
  ProcessCmd buildApkCmd(String target, {String? flavor}) {
    var gradleTarget = targetToGradleTarget(target);
    var cmd = ProcessCmd(gradleExecutable, [
      '$gradleTarget:assemble${flavor}Release',
    ], workingDirectory: path);
    return cmd;
  }

  /// Renames the release apk built for the Gradle [target] (e.g. `':app'`
  /// or `'app'`) to a name derived from its info, via `nameApk`.
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

  /// Splits a Gradle [target] path (e.g. `':app:sub'` or `'app/sub'`) on
  /// `:` and further splits each segment on the platform path separator,
  /// returning the flattened path segments.
  static List<String> targetToParts(String target) {
    var parts = <String>[];
    var segments = target.split(':');
    for (var segment in segments) {
      parts.addAll(contextPathSplit(context, segment));
    }
    return parts;
  }

  /// Normalizes a Gradle [target] path (see [targetToParts]) into
  /// colon-separated Gradle target syntax, e.g. `':app:sub'`.
  static String targetToGradleTarget(String target) {
    var parts = targetToParts(target);
    return ':${parts.join(':')}';
  }

  /// Normalizes a Gradle [target] path (see [targetToParts]) into a
  /// filesystem-style relative path, e.g. `'app/sub'`.
  String targetToPath(String target) {
    var parts = targetToParts(target);
    return joinAll(parts);
  }

  /// The `release` build mode name, for use as [getApkPath]'s `mode`.
  static const String modeRelease = 'release';

  /// The `debug` build mode name, for use as [getApkPath]'s `mode`.
  static const String modeDebug = 'debug';

  /// The default `app` module name.
  static const String moduleApp = 'app';

  /// Path to the project's Gradle wrapper executable (`gradlew`).
  String get gradleExecutable => join(path, gradleShellExecutableFilename);

  /// Computes the expected output path of a built apk.
  ///
  /// [module] defaults to [moduleApp], [mode] defaults to [modeRelease]
  /// (typically [modeRelease] or [modeDebug]). If [flavor] is given, the
  /// path includes the flavor-specific output directory and filename;
  /// otherwise the plain module/mode path is used.
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
