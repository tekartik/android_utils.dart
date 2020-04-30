#!/usr/bin/env dart

library tekartik_script.bin.adb_device_os_version;

import 'dart:async';

import 'package:tekartik_android_utils/bin/adb_device_os_version.dart'
    as adb_device_os_version;

Future main(List<String> arguments) => adb_device_os_version.main(arguments);
