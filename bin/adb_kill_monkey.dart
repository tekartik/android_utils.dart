#!/usr/bin/env dart
library tekartik_script.bin.adb_kill_monkey;

import 'dart:async';

import 'package:tekartik_android_utils/bin/adb_kill_monkey.dart'
    as adb_kill_monkey;

Future main(List<String> arguments) => adb_kill_monkey.main(arguments);
