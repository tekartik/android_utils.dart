/// Pure parsing helpers for the output of the shell commands used to find
/// a device ip address. No `dart:io` dependency so it can run anywhere.
library;

final _ipv4RegExp = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');

/// Parses the output of `ip route get 1.1.1.1` (as run on an Android
/// device) and returns the source ip address (`src <ip>`).
///
/// Example output:
/// ```
/// 1.1.1.1 via 192.168.1.1 dev wlan0 table 1008 src 192.168.1.54 uid 2000
///     cache
/// ```
///
/// Returns `null` if no `src` address is found.
String? adbShellIpRouteGetParseIp(String output) {
  var match = RegExp(r'\bsrc\s+(\d{1,3}(?:\.\d{1,3}){3})\b').firstMatch(output);
  return match?.group(1);
}

/// Parses the output of `ip addr show dev wlan0` (as run on an Android
/// device) and returns the first IPv4 address (`inet <ip>/<prefix>`).
///
/// Example output:
/// ```
/// 8: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
///     link/ether 78:b8:d6:6d:62:8f brd ff:ff:ff:ff:ff:ff
///     inet 192.168.1.54/24 brd 192.168.1.255 scope global wlan0
///     inet6 fe80::319d:4f87:380:a116/64 scope link stable-privacy
/// ```
///
/// Returns `null` if no `inet` address is found (`inet6` entries are
/// ignored).
String? adbShellIpAddrShowParseIp(String output) {
  var match = RegExp(
    r'\binet\s+(\d{1,3}(?:\.\d{1,3}){3})/\d+',
  ).firstMatch(output);
  return match?.group(1);
}

/// Parses the output of `getprop dhcp.wlan0.ipaddress` (as run on an
/// Android device) and returns the ip address it contains.
///
/// The output is expected to be the ip address alone on a line; any other
/// line (such as a shell prompt) is ignored.
///
/// Returns `null` if no line is a valid IPv4 address.
String? adbShellGetPropIpAddressParseIp(String output) {
  for (var line in output.split('\n')) {
    var text = line.trim();
    if (_ipv4RegExp.hasMatch(text)) {
      return text;
    }
  }
  return null;
}
