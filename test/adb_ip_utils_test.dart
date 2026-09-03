import 'package:tekartik_android_utils/src/adb_ip_utils.dart'
    show
        adbShellIpRouteGetParseIp,
        adbShellIpAddrShowParseIp,
        adbShellGetPropIpAddressParseIp;
import 'package:test/test.dart';

// Captured from a Zebra MyDevice, including the shell prompts.
const ipAddrShowOutput = r'''
MyDevice:/ $ ip addr show dev wlan0
8: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 3000
    link/ether 78:b8:d6:6d:62:8f brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.54/24 brd 192.168.1.255 scope global wlan0
       valid_lft forever preferred_lft forever
    inet6 2a01:cb1d:8224:6900:ede1:8d28:2891:7f1b/64 scope global temporary dynamic
       valid_lft 86359sec preferred_lft 559sec
    inet6 2a01:cb1d:8224:6900:8ebc:820f:8645:149b/64 scope global dynamic mngtmpaddr stable-privacy
       valid_lft 86359sec preferred_lft 559sec
    inet6 fe80::319d:4f87:380:a116/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
MyDevice:/ $ ''';

const getPropOutput = r'''
MyDevice:/ $ getprop dhcp.wlan0.ipaddress
192.168.1.54
MyDevice:/ $ ''';

const ipRouteGetOutput = r'''
MyDevice:/ $ ip route get 1.1.1.1
1.1.1.1 via 192.168.1.1 dev wlan0 table 1008 src 192.168.1.54 uid 2000
    cache
MyDevice:/ $ ''';

void main() {
  group('adb_ip_utils', () {
    test('ip route get', () {
      expect(adbShellIpRouteGetParseIp(ipRouteGetOutput), '192.168.1.54');
      // Raw output, as returned by `adb shell`
      expect(
        adbShellIpRouteGetParseIp(
          '1.1.1.1 via 192.168.1.1 dev wlan0 table 1008 src 192.168.1.54 uid 2000 \n    cache \n',
        ),
        '192.168.1.54',
      );
      expect(adbShellIpRouteGetParseIp(''), isNull);
      expect(
        adbShellIpRouteGetParseIp('RTNETLINK answers: Network is unreachable'),
        isNull,
      );
    });

    test('ip addr show', () {
      expect(adbShellIpAddrShowParseIp(ipAddrShowOutput), '192.168.1.54');
      expect(adbShellIpAddrShowParseIp(''), isNull);
      // inet6 only
      expect(
        adbShellIpAddrShowParseIp(
          '    inet6 fe80::319d:4f87:380:a116/64 scope link stable-privacy',
        ),
        isNull,
      );
      expect(
        adbShellIpAddrShowParseIp('Device "wlan0" does not exist.'),
        isNull,
      );
    });

    test('getprop dhcp.wlan0.ipaddress', () {
      expect(adbShellGetPropIpAddressParseIp(getPropOutput), '192.168.1.54');
      expect(adbShellGetPropIpAddressParseIp('192.168.1.54\n'), '192.168.1.54');
      expect(adbShellGetPropIpAddressParseIp(''), isNull);
      expect(adbShellGetPropIpAddressParseIp('\n'), isNull);
      expect(adbShellGetPropIpAddressParseIp('not an ip'), isNull);
    });
  });
}
