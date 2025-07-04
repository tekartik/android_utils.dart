import 'package:tekartik_android_utils/aab_utils.dart';
import 'package:xml/xml.dart';

/// Manifest information for an APK or AAB file.
class ManifestInfo extends ApkInfo {
  /// build from an XML string.
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
