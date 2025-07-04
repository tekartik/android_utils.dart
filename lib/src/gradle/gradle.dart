import 'package:tekartik_android_utils/src/shell/shell.dart';

String? _gradleExecutableFilename;

/// Returns the filename of the Gradle shell executable.
String get gradleShellExecutableFilename =>
    _gradleExecutableFilename ??= getBashOrBatExecutableFilename('gradlew');
