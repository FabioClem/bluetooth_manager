# bluetooth_manager

A lightweight Flutter plugin to read the Bluetooth adapter state on Android,
iOS and macOS, listen to state changes and — when the platform allows it — turn
Bluetooth on or off.

| Feature                        | Android                         | iOS / macOS                             |
| ------------------------------ | ------------------------------- | --------------------------------------- |
| Read current Bluetooth state   | Yes                             | Yes (via `CoreBluetooth`)               |
| Stream state changes (events)  | `BluetoothAdapter.ACTION_STATE_CHANGED` | `CBCentralManagerDelegate` |
| Enable Bluetooth               | Yes (API < 33)\*                | Opens the system Bluetooth settings     |
| Disable Bluetooth              | Yes (API < 33)\*                | Opens the system Bluetooth settings     |

> \* Starting with Android 13 (API 33), `BluetoothAdapter.enable()` and
> `disable()` are deprecated and are no-ops for regular apps. In that case the
> plugin returns `ActionResponse.responseError`. On iOS, programmatic toggling
> is not allowed by the OS, so the plugin falls back to opening the system
> Bluetooth settings.

---

## Installation

Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  bluetooth_manager: ^2.0.0
```

Or, to depend on the latest commit from GitHub:

```yaml
dependencies:
  bluetooth_manager:
    git:
      url: https://github.com/FabioClem/bluetooth_manager.git
```

Then fetch the dependency:

```bash
flutter pub get
```

Minimum requirements:

- Dart SDK `>=2.15.1 <4.0.0`
- Flutter `>=2.5.0`
- Android `minSdkVersion 19` (KitKat) or higher
- iOS `13.0+`
- macOS `10.13+`

---

## Permissions

### Android

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />

<!-- Android 12 (API 31) and above -->
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

On Android 12+ you must also request `BLUETOOTH_CONNECT` at runtime. The
example app uses [`permission_handler`](https://pub.dev/packages/permission_handler)
for that:

```dart
import 'package:permission_handler/permission_handler.dart';

await Permission.bluetooth.request();
await Permission.bluetoothConnect.request(); // Android 12+
```

### iOS

Add the usage description to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to devices.</string>
```

The Bluetooth permission prompt is shown only when your app first calls
`getBluetoothState()` or subscribes to `getBluetoothStateStream()` — the
native plugin lazy-initialises `CBCentralManager` and does not trigger the
prompt at launch.

If you want `enableBluetooth` / `disableBluetooth` to try opening the
Bluetooth settings screen, add `App-Prefs` to the allowed URL schemes. When
iOS blocks those deep links (common on recent versions), the plugin falls
back to your app’s page in the Settings app:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>App-Prefs</string>
</array>
```

### macOS

Add the usage description to `macos/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to devices.</string>
```

Enable the Bluetooth sandbox entitlement in
`macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<key>com.apple.security.device.bluetooth</key>
<true/>
```

`enableBluetooth` / `disableBluetooth` open the Bluetooth pane in System
Settings (`x-apple.systempreferences:…`).

---

## Usage

Import the library and create a `BluetoothManager` instance:

```dart
import 'package:bluetooth_manager/bluetooth_manager.dart';
import 'package:bluetooth_manager/models/bluetooth_models.dart';

final bluetoothManager = BluetoothManager();
```

### 1. Read the current state

```dart
final BluetoothState state = await bluetoothManager.getBluetoothState();

switch (state) {
  case BluetoothState.on:
    // Bluetooth is on
    break;
  case BluetoothState.off:
    // Bluetooth is off
    break;
  case BluetoothState.uknow:
    // State could not be determined
    break;
}
```

### 2. Listen to state changes

`getBluetoothStateStream` is event-driven: it emits only when the adapter
state actually changes (plus one initial emission with the current state on
subscription). On Android it is backed by a `BroadcastReceiver` on
`BluetoothAdapter.ACTION_STATE_CHANGED`; on iOS and macOS by
`CBCentralManagerDelegate.centralManagerDidUpdateState`. Remember to cancel
the subscription when you no longer need it:

```dart
final subscription = bluetoothManager
    .getBluetoothStateStream()
    .listen((BluetoothState state) {
  // React to the new state...
});

// Later, when you're done:
await subscription.cancel();
```

> The `timer` parameter (`getBluetoothStateStream({int timer = 1000})`) is
> kept for backwards compatibility with the old polling implementation and
> is now ignored.

### 3. Enable / disable Bluetooth

```dart
final ActionResponse onResp = await bluetoothManager.enableBluetooth();
final ActionResponse offResp = await bluetoothManager.disableBluetooth();
```

Possible values of `ActionResponse`:

| Value                   | Meaning                                                                |
| ----------------------- | ---------------------------------------------------------------------- |
| `bluetoothIsOn`         | Android: the adapter was turned on by this call.                       |
| `bluetoothIsOff`        | Android: the adapter was turned off by this call.                      |
| `bluetoothAlreadyOn`    | Android: the adapter was already on.                                   |
| `bluetoothAlreadyOff`   | Android: the adapter was already off.                                  |
| `responseError`         | Native side failed (unsupported SDK, missing permission, Android 13+). |
| `openedIOSSettings`     | iOS / macOS: the system Bluetooth settings screen was opened.          |

---

## API reference

### `class BluetoothManager`

| Method                                            | Returns                      | Description                                     |
| ------------------------------------------------- | ---------------------------- | ----------------------------------------------- |
| `getBluetoothState()`                             | `Future<BluetoothState>`     | One-shot read of the adapter state.             |
| `getBluetoothStateStream({int timer = 1000})`     | `Stream<BluetoothState>`     | Event-driven stream of state changes (timer is legacy, ignored). |
| `enableBluetooth()`                               | `Future<ActionResponse>`     | Turns Bluetooth on (Android) or opens settings (iOS / macOS). |
| `disableBluetooth()`                              | `Future<ActionResponse>`     | Turns Bluetooth off (Android) or opens settings (iOS / macOS). |

### `enum BluetoothState`

`on`, `off`, `uknow`.

> Note: the value is spelled `uknow` (without the "n") for backwards
> compatibility with older releases of the plugin.

### `enum ActionResponse`

`bluetoothIsOn`, `bluetoothIsOff`, `bluetoothAlreadyOn`, `bluetoothAlreadyOff`,
`responseError`, `openedIOSSettings`.

---

## Platform notes

- On **Android 13+ (API 33)** the programmatic enable/disable of the adapter
  is blocked by the system for regular apps. `enableBluetooth` /
  `disableBluetooth` will typically return `responseError`. Prefer guiding the
  user to the system settings in that case.
- On **iOS** there is no public API to toggle Bluetooth. The plugin tries
  Bluetooth-specific settings URLs and, if the system rejects them, opens your
  app’s Settings page instead. Both paths return `openedIOSSettings`.
  Intermediate `CBManagerState` values (`resetting`, `unauthorized`,
  `unsupported`, etc.) are reported as `BluetoothState.uknow`.
- On **macOS** toggling is also not exposed to apps. The plugin opens the
  Bluetooth pane in System Settings and returns `openedIOSSettings`. State
  reading and streaming use the same CoreBluetooth + `EventChannel` stack as
  iOS, with a dedicated native target under `macos/`.
- The state stream is implemented through a native `EventChannel`
  (`bluetooth_manager/events`). It emits once at subscription time with the
  current state and then again each time the adapter changes state, so there
  is no polling and no battery impact.

---

## Full example

A runnable example lives in the [`example/`](example/) directory. To run it:

```bash
cd example
flutter pub get
flutter run              # device / simulator
flutter run -d macos     # macOS desktop
```

---

## Development

- Android development works on macOS, Linux and Windows.
- iOS and macOS development require macOS with Xcode installed.
- Run the tests with `flutter test` from the repository root.

Contributions are welcome — feel free to open an issue or a PR on
[GitHub](https://github.com/FabioClem/bluetooth_manager).
