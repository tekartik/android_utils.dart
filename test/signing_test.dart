@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:tekartik_android_utils/signing.dart';
import 'package:test/test.dart';

/// Captures what is written to stdout (IOOverrides).
class _CaptureStdout implements Stdout {
  final buffer = StringBuffer();
  @override
  void write(Object? object) => buffer.write(object);
  @override
  void writeln([Object? object = '']) => buffer.writeln(object);
  @override
  void add(List<int> data) => buffer.write(utf8.decode(data));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<String> _captureStdout(Future<void> Function() action) async {
  var capture = _CaptureStdout();
  await IOOverrides.runZoned(action, stdout: () => capture);
  return capture.buffer.toString();
}

void main() {
  group('signing', () {
    var module = AndroidModule(project: AndroidProject('.'));
    var options = SigningOptions(keystore: 'app.jks', password: 'pwd');
    test('printGradleConfig', () async {
      var text = await _captureStdout(
        () => module.printGradleConfig(signinOptions: options),
      );
      expect(text, contains("storeFile file('app.jks')"));
      expect(text, contains("keyPassword 'pwd'"));
    });
    test('printGradleConfigKts', () async {
      var text = await _captureStdout(
        () => module.printGradleConfigKts(signinOptions: options),
      );
      expect(text, contains('storeFile = file("app.jks")'));
    });
  });
}
