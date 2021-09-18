import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';

// ignore: implementation_imports
import 'package:process_run/src/shell_utils.dart'
    show envPathSeparator, envPathKey;
import 'package:process_run/src/shell_utils.dart' // ignore: implementation_imports
    show
        shellSplit;
//import 'package:tekartik_build_utils/common_import.dart';
import 'package:tekartik_common_utils/version_utils.dart';

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
  String? get androidSdkPlatformToolsPath =>
      androidSdkPath == null ? null : join(androidSdkPath!, 'platform-tools');

  @override
  String? get androidSdkToolsPath =>
      androidSdkPath == null ? null : join(androidSdkPath!, 'tools');

  @override
  String? androidSdkCommandLineToolsPath;
}

Future<String?> readRegistryString(String path, String key) async {
  // Find registry
  // Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Android Studio
  // Key Path
  try {
    // HKEY_LOCAL_MACHINE\SOFTWARE\Android Studio
    //     Path    REG_SZ    C:\Program Files\Android\Android Studio New
    var lines = (await run(
            'reg query ${shellArgument(path)} /v ${shellArgument(key)}',
            verbose: false))
        .outLines
        .map((e) => e.trim())
        .where((element) => element.startsWith('Path'));
    var regSz = 'REG_SZ';
    var line = lines.first;
    var index = line.indexOf(regSz);
    if (index != -1) {
      var asDir = line.substring(index + regSz.length).trim();
      return asDir;
    }
  } catch (_) {
    return null;
  }
}

Future<AndroidBuildContext> getAndroidBuildContent({int? sdkVersion}) async {
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
        sdkBuildToolsDir =
            join(sdkDir, 'build-tools', versions.first.toString());
      }
    }
    {
      // command line tools
      var commandLineToolsBasePath = join(sdkDir, 'cmdline-tools');
      var versionTexts = (Directory(commandLineToolsBasePath)
          .listSync()
          .whereType<Directory>()
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
  if (asDir != null) {
    for (var subDir in [
      // Linux
      join('jre', 'bin'),
      // Macos
      if (Platform.isMacOS) 'jre/jdk/Contents/Home/bin'
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
    ..androidSdkCommandLineToolsPath = sdkCommandLineToolsDir;
  return context;
}

Future<ShellEnvironment>? _androidBuildEnvironmentFuture;

/// Prepend a path to the shell environment used
void shellEnvironmentPrependPath(String path) {
  print('Adding path $path');
  var env = Map<String, String>.from(shellEnvironment);
  var paths = env[envPathKey]!.split(envPathSeparator);
  env[envPathKey] = (paths..insert(0, path)).join(envPathSeparator);
  shellEnvironment = env;
}

// Extra shell to merge
Future<ShellEnvironment> getAndroidBuildEnvironment({int? sdkVersion}) async {
  var environment = ShellEnvironment.empty();
  // Add proper Java from Android Studio
  var context = await getAndroidBuildContent(sdkVersion: sdkVersion);
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

Future<void> initAndroidBuildEnvironment({int? sdkVersion}) async {
  await (_androidBuildEnvironmentFuture ??= () async {
    var environment = ShellEnvironment()
      ..merge(await getAndroidBuildEnvironment());

    shellEnvironment = environment;
    return environment;
  }());
}

/*
Future<Map<String, String>> get androidEnvironment async {
    var map = Map<String, String>.from(userEnvironment);
    return map;
  }*/
