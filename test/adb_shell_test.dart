@TestOn('vm')
// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library apk_utils_test;

import 'package:dev_test/test.dart';
import 'package:tekartik_android_utils/adb_shell.dart';

void main() {
  group('adb_shell', () {
    test('ps_line', () async {
      // await runCmd(adbCmd(['shell', 'ps']));
      var psLine = PsLine(
          'shell     7398  1310  1217116 16816 binder_thr a9529424 S com.android.commands.monkey');
      expect(psLine.pid, 7398);
      expect(psLine.name, 'com.android.commands.monkey');
      expect(psLine.toString(),
          'shell 7398 1310 1217116 16816 binder_thr a9529424 S com.android.commands.monkey');
    });

    test('ps_parser', () {
      var out = '''
USER      PID   PPID  VSIZE  RSS   WCHAN            PC  NAME
root      1     0     8504   1504  SyS_epoll_ 00000000 S /init
root      2     0     0      0       kthreadd 00000000 S kthreadd
root      3     2     0      0     smpboot_th 00000000 S ksoftirqd/0
''';
      var parser = ShellPsParser(out);
      expect(parser.findByName('/init').pid, 1);
    });
  });
}
