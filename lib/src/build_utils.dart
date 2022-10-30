import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:process_run/src/shell_utils.dart' // ignore: implementation_imports
    show
        shellSplit;

import 'import_io.dart';

/// Initialized using [initAndroidBuildEnvironment]
/// Valid actions are composed of a verb and an optional direct object:
/// -   list              : Lists existing targets or virtual devices.
/// -   list avd          : Lists existing Android Virtual Devices.
/// -   list target       : Lists existing targets.
/// -   list device       : Lists existing devices.
/// - create avd          : Creates a new Android Virtual Device.
/// -   move avd          : Moves or renames an Android Virtual Device.
/// - delete avd          : Deletes an Android Virtual Device.
// String avdmanager;

/// Initialized using [initAndroidBuildEnvironment]
// String adb;

abstract class AndroidBuildContext {
  String? get androidStudioPath;

  String? get androidStudioJdkPath;

  String? get androidSdkPath;

  String? get androidSdkBuildToolsPath;

  String? get androidSdkPlatformToolsPath;

  String? get androidSdkToolsPath;

  String? get androidSdkCommandLineToolsPath;

  /// ANDROID_AVD_HOME or ~/.android/avd
  /// Tested on linux for now
  String? get androidAvdHomePath;

  Version? get sdkVersion;
}

class AndroidBuildContextImpl implements AndroidBuildContext {
  @override
  String? androidStudioPath;
  @override
  String? androidStudioJdkPath;
  @override
  String? androidSdkPath;
  @override
  String? androidSdkBuildToolsPath;

  @override
  Version? sdkVersion;

  @override
  String? get androidSdkPlatformToolsPath =>
      androidSdkPath == null ? null : join(androidSdkPath!, 'platform-tools');

  @override
  String? get androidSdkToolsPath =>
      androidSdkPath == null ? null : join(androidSdkPath!, 'tools');

  @override
  String? androidSdkCommandLineToolsPath;

  @override
  String? get androidAvdHomePath =>
      shellEnvironment['ANDROID_AVD_HOME'] ??
      join(userHomePath, '.android', 'avd');
}

/// read registry key at give path.
///
/// Not fully safe (for example does not handle content starting with a space) but ok for many scenarios
Future<String?> readRegistryString(String path, String key) async {
  try {
    // We'll get lines like
    // HKEY_LOCAL_MACHINE\SOFTWARE\Android Studio
    //    Path    REG_SZ    C:\Program Files\Android\Android Studio New
    //
    var lines = (await run(
            'reg query ${shellArgument(path)} /v ${shellArgument(key)}',
            verbose: false))
        .outLines
        .map((e) => e.trimLeft())
        .where((element) => element.split(' ').first == key);
    if (lines.isNotEmpty) {
      // Ok skip the key and look for REG_SZ
      var regSz = 'REG_SZ';
      var line = lines.first.substring(key.length).trimLeft();
      if (line.startsWith(regSz)) {
        var content = line.substring(regSz.length).trimLeft();
        return content;
      }
    }
  } catch (_) {}
  return null;
}

/// To deprecate, type error
///
/// DO NOT REMOVE
Future<AndroidBuildContext> getAndroidBuildContent({int? sdkVersion}) async {
  return getAndroidBuildContext(sdkVersion: sdkVersion);
}

Future<AndroidBuildContext> getAndroidBuildContext({int? sdkVersion}) async {
  AndroidBuildContext context;

  var asDirs = <String>[];
  var sdkDirs = <String>[];

  String? asDir;
  String? sdkDir;

  // devPrint(shellEnvironment);
  // Try env var
  var envAndroidSdkRoot = shellEnvironment['ANDROID_SDK_ROOT'];
  if (envAndroidSdkRoot != null) {
    sdkDirs.add(envAndroidSdkRoot);
  }

  // Find AS
  if (Platform.isLinux) {
    // Look for shortcut
    var shortcutFile = join(
        userHomePath, '.local/share/applications/jetbrains-studio.desktop');

    // [Desktop Entry]
    // Version=1.0
    // Type=Application
    // Name=Android Studio
    // Icon=/opt/app/android-studio/bin/studio.png
    // Exec="/opt/app/android-studio/bin/studio.sh" %f
    try {
      var content = await File(shortcutFile).readAsString();
      for (var line in LineSplitter.split(content)) {
        var lineParts = line.split('=');
        if (lineParts[0].toLowerCase() == 'exec') {
          if (lineParts.length > 1) {
            var exec = lineParts[1];
            exec = shellSplit(exec)[0];
            asDirs.add(dirname(dirname(exec)));
            break;
          }
        }
      }
    } catch (_) {
      // devPrint(_);
    }
  }
  if (Platform.isMacOS) {
    asDirs.addAll(['/Applications/Android Studio.app/Contents']);
    sdkDirs.addAll([join(userHomePath, 'Library', 'Android', 'sdk')]);
  }
  if (Platform.isWindows) {
    // Find registry
    // Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Android Studio
    // Key Path
    try {
      // HKEY_LOCAL_MACHINE\SOFTWARE\Android Studio
      //     Path    REG_SZ    C:\Program Files\Android\Android Studio New
      var asDir =
          await readRegistryString('HKLM\\SOFTWARE\\Android Studio', 'Path');

      if (asDir?.isNotEmpty ?? false) {
        asDirs.add(asDir!);
      }
    } catch (_) {}

    // Find registry
    // Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Android Studio
    // Key Path
    try {
      // HKEY_LOCAL_MACHINE\SOFTWARE\Android Studio
      //     Path    REG_SZ    C:\Program Files\Android\Android Studio New
      var sdkDir =
          await readRegistryString('HKLM\\SOFTWARE\\Android Studio', 'SdkPath');

      if (sdkDir?.isNotEmpty ?? false) {
        sdkDirs.add(sdkDir!);
      }
    } catch (_) {}
    // Default old location
    asDirs.addAll(['C:\\Program Files\\Android\\Android Studio']);
    var localAppData = shellEnvironment['LOCALAPPDATA'];
    if (localAppData != null) {
      sdkDirs.addAll([join(localAppData, 'Android', 'Sdk')]);
    }
  }

  for (var dir in asDirs) {
    if (Directory(dir).existsSync()) {
      asDir = dir;
      break;
    }
  }
  for (var dir in sdkDirs) {
    if (Directory(dir).existsSync()) {
      sdkDir = dir;
      break;
    }
  }

  String? sdkBuildToolsDir;
  String? sdkCommandLineToolsDir;
  String? asJdkDir;
  Version? readSdkVersion;

  if (sdkDir != null) {
    {
      // build tools
      var versions = (Directory(join(sdkDir, 'build-tools'))
              .listSync()
              .whereType<Directory>()
              .map((e) => parseVersion(basename(e.path)))
              .where((v) => sdkVersion == null || v.major == sdkVersion)
              .toList()
            ..sort())
          .reversed
          .toList();
      if (versions.isNotEmpty) {
        readSdkVersion = versions.first;
        sdkBuildToolsDir =
            join(sdkDir, 'build-tools', readSdkVersion.toString());
      }
    }
    {
      // command line tools
      var commandLineToolsBasePath = join(sdkDir, 'cmdline-tools');
      if (Directory(commandLineToolsBasePath).existsSync()) {
        var versionTexts = await (Directory(commandLineToolsBasePath)
            .list()
            .where((e) => e is Directory)
            .map((e) => basename(e.path))
            .toList());

        if (versionTexts.isNotEmpty) {
          // Use latest if found
          if (versionTexts.contains('latest')) {
            sdkCommandLineToolsDir = join(commandLineToolsBasePath, 'latest');
          } else {
            var versions = (versionTexts
                    .map((e) => parseVersion(e))
                    .where((v) => sdkVersion == null || v.major == sdkVersion)
                    .toList()
                  ..sort())
                .reversed
                .toList();
            if (versions.isNotEmpty) {
              sdkCommandLineToolsDir =
                  join(commandLineToolsBasePath, versions.first.toString());
            }
          }
        }
      }
    }
  }
  if (asDir != null) {
    for (var subDir in [
      // Linux
      join('jre', 'bin'),
      // Macos
      if (Platform.isMacOS) ...[
        // 2021-09 Android studio
        'jre/Contents/Home/bin',

        // Pre 2021-08 android studio
        'jre/jdk/Contents/Home/bin'
      ]
    ]) {
      var dir = join(asDir, subDir);
      if (Directory(dir).existsSync()) {
        asJdkDir = dirname(dir);
        break;
      }
    }
  }

  context = AndroidBuildContextImpl()
    ..androidStudioPath = asDir
    ..androidStudioJdkPath = asJdkDir
    ..androidSdkPath = sdkDir
    ..androidSdkBuildToolsPath = sdkBuildToolsDir
    ..androidSdkCommandLineToolsPath = sdkCommandLineToolsDir
    ..sdkVersion = readSdkVersion;
  return context;
}

Future<ShellEnvironment>? _androidBuildEnvironmentFuture;

/// Get shell environment to merge
Future<ShellEnvironment> getAndroidBuildEnvironment(
    {AndroidBuildContext? context, int? sdkVersion}) async {
  var environment = ShellEnvironment.empty();
  // Add proper Java from Android Studio
  context ??= await getAndroidBuildContext(sdkVersion: sdkVersion);
  if (context.androidStudioJdkPath != null) {
    environment.paths.prepend(join(context.androidStudioJdkPath!, 'bin'));
  }
  if (context.androidSdkBuildToolsPath != null) {
    environment.paths.prepend(context.androidSdkBuildToolsPath!);
  }
  if (context.androidSdkToolsPath != null) {
    environment.paths.prepend(join(context.androidSdkToolsPath!, 'bin'));
  }
  if (context.androidSdkPlatformToolsPath != null) {
    environment.paths.prepend(join(context.androidSdkPlatformToolsPath!));
  }
  if (context.androidSdkCommandLineToolsPath != null) {
    environment.paths
        .prepend(join(context.androidSdkCommandLineToolsPath!, 'bin'));
  }
  // emulator
  if (context.androidSdkPath != null) {
    environment.paths.prepend(join(context.androidSdkPath!, 'emulator'));
  }
  return environment;
}

/// If specified, [context] and [sdkVersion] are used
Future<void> initAndroidBuildEnvironment(
    {AndroidBuildContext? context, int? sdkVersion}) async {
  await (_androidBuildEnvironmentFuture ??= () async {
    var buildEnvironment = await getAndroidBuildEnvironment(
        context: context, sdkVersion: sdkVersion);
    var environment = ShellEnvironment()..merge(buildEnvironment);

    shellEnvironment = environment;
    return environment;
  }());
}

/*
Future<Map<String, String>> get androidEnvironment async {
    var map = Map<String, String>.from(userEnvironment);
    return map;
  }*/
