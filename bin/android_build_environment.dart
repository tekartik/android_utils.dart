import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main() async {
  var context = await getAndroidBuildContent();
  print('                androidSdkPath: ${context.androidSdkPath}');
  print('             androidStudioPath: ${context.androidStudioPath}');
  print('          androidStudioJdkPath: ${context.androidStudioJdkPath}');
  print('      androidSdkBuildToolsPath: ${context.androidSdkBuildToolsPath}');
  print(
      '   androidSdkPlatformToolsPath: ${context.androidSdkPlatformToolsPath}');
  print('           androidSdkToolsPath: ${context.androidSdkToolsPath}');
  print(
      'androidSdkCommandLineToolsPath: ${context.androidSdkCommandLineToolsPath}');

  await initAndroidBuildEnvironment();
  print(await which('sdkmanager'));
  print(await which('java'));
}
