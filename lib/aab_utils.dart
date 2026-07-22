// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The aab_utils library: utilities for reading Android App Bundle (`.aab`)
/// metadata via `bundletool`.
library;

import 'dart:async';

import 'package:process_run/shell.dart';
import 'package:tekartik_android_utils/src/manifest_info.dart';

export 'package:tekartik_android_utils/src/apk_info.dart';

bool? _bundleToolSupported;

/// Whether the `bundletool` executable is available on the current `PATH`.
/// The result is cached after the first check.
bool get bundleToolSupported =>
    _bundleToolSupported ??= whichSync('bundletool') != null;

/// Manifest information extracted from an Android App Bundle (`.aab`) file
/// via [getAabInfo].
class AabInfo extends ManifestInfo {}

/// Reads the manifest of the `.aab` file at [aabFilePath] (via
/// `bundletool dump manifest`) and parses it into an [AabInfo].
///
/// If [verbose] is `true` (defaults to `false`), the underlying command's
/// output is logged.
///
/// Requires `bundletool` to be installed and on the `PATH`.
Future<AabInfo> getAabInfo(String aabFilePath, {bool verbose = false}) async {
  var result = await run(
    'bundletool dump manifest --bundle ${shellArgument(aabFilePath)}',
    verbose: verbose,
  );
  var lines = result.outText;
  var manifestInfo = AabInfo()..fromXml(lines);
  return manifestInfo;
}
