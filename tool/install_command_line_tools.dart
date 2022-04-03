import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/build_utils.dart';

Future<void> main() async {
  var context = await getAndroidBuildContext();

  await initAndroidBuildEnvironment(context: context);
  await run('sdkmanager --install "cmdline-tools;latest"');
}
