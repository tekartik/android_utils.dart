import 'package:tekartik_android_utils/aab_utils.dart';
import 'package:xml/xml.dart';

/// Manifest information for an APK or AAB file, populated by parsing the
/// manifest XML with [fromXml].
class ManifestInfo extends ApkInfo {
  /// Parses [xmlText] (an `AndroidManifest.xml` document) and populates
  /// [ApkInfo.name], [ApkInfo.versionName] and [ApkInfo.versionCode] from
  /// its `<manifest>` element's `package`, `android:versionName` and
  /// `android:versionCode` attributes. Attributes not present in the XML
  /// leave the corresponding field unchanged.
  void fromXml(String xmlText) {
    // devPrint(xmlText);
    var xml = XmlDocument.parse(xmlText);
    var manifestElement = xml.findElements('manifest').first;
    for (var attribute in manifestElement.attributes) {
      var name = attribute.name.toString();
      // devPrint('$name:${attribute.value}');
      switch (name) {
        case 'package':
          this.name = attribute.value;
          break;
        case 'android:versionName':
          versionName = attribute.value;
          break;
        case 'android:versionCode':
          versionCode = attribute.value;
          break;
      }
    }
  }
}
