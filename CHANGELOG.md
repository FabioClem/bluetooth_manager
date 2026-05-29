# Changelog

All notable changes to this project are documented in this file.

## 2.0.1

- **Android:** add `namespace` in `android/build.gradle` (required by AGP 8+),
  bump `compileSdk` to 35, `minSdk` to 21, and align Java compatibility to 17.

## 2.0.0

- **New native architecture for iOS and macOS.** Each platform now has its
  own Swift plugin target (`ios/`, `macos/`) sharing the same channel names
  (`bluetooth_manager`, `bluetooth_manager/events`) but compiled against
  `Flutter` / `FlutterMacOS` respectively.
- **Dart layer split by platform.** `BluetoothManagerPath` routes calls to
  dedicated implementations: `BluetoothManagerIOS` and `BluetoothManagerMacOS`
  under `lib/path/ios/` and `lib/path/macos/`.
- **macOS support (first-class).** Read the Bluetooth adapter state, stream
  state changes via `EventChannel` (`CBCentralManagerDelegate`) and open the
  Bluetooth pane in System Settings through `enableBluetooth` /
  `disableBluetooth` (returns `ActionResponse.openedIOSSettings`, same as iOS).
- **iOS plugin rebuilt on CoreBluetooth.**
  - Lazy-initialises `CBCentralManager`, so the Bluetooth permission prompt
    appears only on the first state read or stream subscription — not at app
    launch.
  - Event-driven state stream via `CBCentralManagerDelegate` (no polling).
  - Concurrent state reads through a pending-results queue with a 3-second
    timeout that resolves to `uknow` when the delegate never reports a state.
  - `CBManagerState` values other than `poweredOn` / `poweredOff` map to
    `BluetoothState.uknow` instead of throwing at runtime.
  - `openBluetoothSettings` tries Bluetooth-specific URLs and falls back to
    the app’s Settings page when the system rejects deep links.
- Example app includes a `macos/` runner with Bluetooth sandbox entitlement
  and `NSBluetoothAlwaysUsageDescription`.
- Documentation updated across `README.md` and dartdoc comments.

## 1.0.12

- **macOS support.** Read the Bluetooth adapter state, stream state changes
  via `EventChannel` (`CBCentralManagerDelegate`) and open the Bluetooth pane
  in System Settings through `enableBluetooth` / `disableBluetooth` (returns
  `ActionResponse.openedIOSSettings`, same as iOS).
- Example app includes a `macos/` runner with Bluetooth sandbox entitlement
  and `NSBluetoothAlwaysUsageDescription`.

## 1.0.11

- **iOS now works.** The Swift plugin was missing `import Flutter` and never
  compiled; added it and wired the plugin correctly.
- **iOS state reading is safe.** `CBManagerState` values that are not
  `poweredOn` / `poweredOff` are now mapped to `BluetoothState.uknow`
  instead of returning strings not present in the enum (which used to throw
  a `TypeError` at runtime).
- **iOS lazy-initialises `CBCentralManager`**, so the Bluetooth permission
  prompt is no longer shown at app launch — it now appears only when the
  first state read or stream subscription happens.
- **iOS supports concurrent state reads** through a queue of pending
  results and adds a 3-second timeout that resolves with `uknow` if the
  delegate never reports a state.
- `openBluetoothSettings` on iOS (invoked by `enableBluetooth` /
  `disableBluetooth`) keeps returning `ActionResponse.openedIOSSettings`.
- **Event-driven state stream on both platforms.** `getBluetoothStateStream`
  is now backed by an `EventChannel` (`bluetooth_manager/events`) — a
  `BroadcastReceiver` on Android and `CBCentralManagerDelegate` on iOS.
  No more polling. The `timer` parameter is kept for backwards
  compatibility but ignored.
- **Android robustness.**
  - Fixed a broken Java reference-equality check on the plugin result
    (`callResult == "version_error"`) that meant the error branch never
    fired.
  - Android 13+ (API 33): `enableBluetooth` / `disableBluetooth` now
    return `responseError` explicitly, because `BluetoothAdapter.enable()`
    / `disable()` are no-ops for non-privileged apps on that SDK.
  - Missing `BLUETOOTH_CONNECT` permission is now caught and reported as
    `responseError` instead of crashing.
- **`enumFromString` is null-safe and generic** (`T? enumFromString<T>`).
  All Dart platform implementations fall back to `BluetoothState.uknow` /
  `ActionResponse.responseError` when the native side returns an
  unexpected value, so the plugin never throws a `TypeError`.
- **Podspec metadata** updated (version, summary, homepage, author).
- Documentation updated across `README.md` and dartdoc comments.

## 0.0.11

- Added documentation and usage examples.

## 0.0.1

- Initial release: read the Bluetooth state and enable/disable it on Android.
