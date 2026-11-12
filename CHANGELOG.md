# Changelog

## 0.6.8

- Add `emulator_utils.dart`: list the AVDs, launch an emulator and wait for its boot, stop it
- Add the `android_emu_run` script: run a command (`flutter test integration_test`...) on a device, launching an emulator when needed
- Requires `process_run` 1.4.4 (detached start)

## 0.6.7

- Add `AdbDevice` class with `getIp()` to find a device internal ip address
- Add `adb_ip_utils.dart` parsers (`ip route get`, `ip addr show`, `getprop`), usable on web

## 0.4.2

- kill_emu working on windows

## 0.2.0

- Add apk_kill_monkey

## 0.1.0

- Initial version, apk_name_it, apk_info, apk_kill_emu
