/// Certificate fingerprints:
///	 MD5:  69:3D:D9:FE:2B:39:4A:68:59:A8:DD:78:6C:E8:9A:3B
///	 SHA1: 40:F1:83:3D:77:C2:F4:E1:55:66:EA:EA:1F:87:DC:7A:90:24:6C:48
///
/// will give:
///
///  40:F1:83:3D:77:C2:F4:E1:55:66:EA:EA:1F:87:DC:7A:90:24:6C:48
String keytoolOutLinesExtractSha1Digest(Iterable<String> lines) {
  var before = 'Certificate fingerprints';
  var beforeNeeded = true;
  for (var line in lines) {
    if (beforeNeeded) {
      if (line.contains(before)) {
        beforeNeeded = false;
      }
    } else {
      var pre = 'SHA1: ';
      var index = line.indexOf(pre);
      if (index > 1) {
        return line
            .substring(index + pre.length)
            .trim()
            .split(' ')
            .first
            .trim()
            .split(':')
            .join(':')
            .toUpperCase();
      }
    }
  }
  return null;
}
