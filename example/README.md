# bluetooth_manager_example

A minimal Flutter app that demonstrates every feature of the
[`bluetooth_manager`](../) plugin:

- reading the current Bluetooth state with `getBluetoothState()`;
- subscribing to state changes with `getBluetoothStateStream()`;
- toggling the adapter with `enableBluetooth()` / `disableBluetooth()`
  (on iOS this opens the system Bluetooth settings);
- requesting Android runtime permissions through
  [`permission_handler`](https://pub.dev/packages/permission_handler)
  (iOS and macOS rely on Core Bluetooth via the plugin — see below).

## Permissions in this example

| Platform | How permissions are handled |
| -------- | --------------------------- |
| Android  | `permission_handler` requests `bluetooth` and `bluetoothConnect` on startup. |
| iOS      | Skipped in Dart. The plugin shows the Core Bluetooth dialog on first state read; requires `NSBluetoothAlwaysUsageDescription` in `ios/Runner/Info.plist`. |
| macOS    | Skipped in Dart. Same as iOS; requires `NSBluetoothAlwaysUsageDescription` and the Bluetooth sandbox entitlement in `macos/Runner/*.entitlements`. |

> Do **not** call `Permission.bluetooth` on iOS/macOS in this example: `permission_handler` has no macOS implementation, and on iOS Bluetooth support must be enabled explicitly in the Podfile (`PERMISSION_BLUETOOTH=1`).

## Running

```bash
flutter pub get
flutter run              # picks a connected device
flutter run -d macos     # macOS desktop
```

## UI overview

| Button                       | What it does                                                          |
| ---------------------------- | --------------------------------------------------------------------- |
| **Get bluetooth State**      | Cancels any active listener and performs a one-shot read of the state. |
| **Listen/Pause bluetooth State** | Starts a polling stream (500 ms) and updates the UI on every emission. |
| **Turn on/off**              | Toggles the adapter based on the last known state.                    |

See [`lib/main.dart`](lib/main.dart) for the full source.
