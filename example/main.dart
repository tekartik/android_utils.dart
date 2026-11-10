import 'dart:io';

import 'package:tekartik_android_utils/adb_device.dart';
import 'package:tekartik_android_utils/build_utils.dart';

/// Prints the Android installation found on this machine, then the
/// connected devices (when adb is found).
Future<void> main() async {
  var context = await getAndroidBuildContext();
  stdout.writeln('sdk          ${context.androidSdkPath}');
  stdout.writeln('build-tools  ${context.androidSdkBuildToolsPath}');
  stdout.writeln('studio jdk   ${context.androidStudioJdkPath}');

  // adb, aapt, apksigner, sdkmanager... on the PATH of the next commands.
  await initAndroidBuildEnvironment();
  try {
    stdout.writeln('devices      ${await listDevices()}');
  } catch (e) {
    stderr.writeln('adb not found: $e');
  }
}
