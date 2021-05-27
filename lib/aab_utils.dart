// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The apk_utils library.
library apk_utils;

import 'dart:async';

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/manifest_info.dart';
import 'package:tekartik_io_utils/io_utils_import.dart';

export 'package:tekartik_android_utils/src/apk_info.dart';

bool? _bundleToolSupported;

/// True if aapt si present and supported
bool get bundleToolSupported =>
    _bundleToolSupported ??= whichSync('bundletool') != null;

class AabInfo extends ManifestInfo {}

Future<AabInfo> getAabInfo(String aabFilePath, {bool verbose = false}) async {
  var result = await run(
      'bundletool dump manifest --bundle ${shellArgument(aabFilePath)}',
      verbose: verbose);
  var lines = result.outText;
  var manifestInfo = AabInfo()..fromXml(lines);
  return manifestInfo;
}
