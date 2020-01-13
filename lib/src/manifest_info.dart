import 'package:tekartik_android_utils/aab_utils.dart';
import 'package:xml/xml.dart';

class ManifestInfo extends ApkInfo {
  void fromXml(String xmlText) {
    // devPrint(xmlText);
    var xml = parse(xmlText);
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
