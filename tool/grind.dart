import 'package:grinder/grinder.dart';
import 'package:path/path.dart';

main(args) => grind(args);

@Task()
test() => new TestRunner().testAsync();

@DefaultTask()
@Depends(test)
build() {
  Pub.build();
}

@Task()
clean() => defaultClean();

@Task()
name() async {
  runDartScript('bin/apk_name_it.dart', arguments: [join("test", "data", "app-release.apk")]);
}

@Task()
info() async {
  runDartScript('bin/apk_info.dart', arguments: [join("test", "data", "app-release.apk"), join("test", "data", "tmp")]);
}
