import 'package:tekartik_android_utils/src/shell/shell.dart';

String _gradleExecutableFilename;
String get gradleShellExecutableFilename =>
    _gradleExecutableFilename ??= getBashOrBatExecutableFilename('gradlew');
