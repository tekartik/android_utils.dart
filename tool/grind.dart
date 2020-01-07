import 'dart:async';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart';

Future main(List<String> args) => grind(args);

@Task()
Future test() => TestRunner().testAsync();

@DefaultTask()
@Depends(test)
void build() {
  Pub.build();
}

@Task()
void clean() => defaultClean();

@Task()
Future name() async {
  runDartScript('bin/apk_name_it.dart',
      arguments: [join('test', 'data', 'app-release.apk')]);
}

@Task()
Future info() async {
  runDartScript('bin/apk_info.dart', arguments: [
    join('test', 'data', 'app-release.apk'),
    join('test', 'data', 'tmp')
  ]);
}
