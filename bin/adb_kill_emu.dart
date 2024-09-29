#!/usr/bin/env dart

library;

import 'dart:async';

import 'package:tekartik_android_utils/bin/adb_kill_emu.dart' as adb_kill_emu;

Future main(List<String> arguments) => adb_kill_emu.main(arguments);
