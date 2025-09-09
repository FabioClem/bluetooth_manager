# bluetooth_manager

Manage Bluetooth on Android and iOS devices with Flutter.

This plugin allows you to:

- Check Bluetooth state (on, off, unknown)
- Turn Bluetooth on/off (Android only)
- Listen to state changes via stream

## Platform Support

- **Android**: Full control (enable/disable/check state)
- **iOS**: State check only (due to platform limitations)

## Installation

Add to your `pubspec.yaml`:

```yaml
bluetooth_manager:
  git:
    url: https://github.com/FabioClem/bluetooth_manager.git
```

Run:

```zsh
flutter pub get
```

## Permissions

### Android

Add to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" /> <!-- Android 12+ -->
```

### iOS

Add to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to devices.</string>
```

## How to Use

Import the library:

```dart
import 'package:bluetooth_manager/bluetooth_manager.dart';
```

### Check Bluetooth State

```dart
BluetoothState bluetoothState = await bluetoothManager.getBluetoothState();
print(bluetoothState); // on, off, unknown
```

### Listen to State Changes

```dart
bluetoothManager.getBluetoothStateStream().listen((BluetoothState state) {
  print(state);
  // Your logic here...
});
```

### Enable/Disable Bluetooth (Android only)

```dart
ActionResponse response = await bluetoothManager.enableBluetooth();
print(response); // success, failed, not_supported

ActionResponse response = await bluetoothManager.disableBluetooth();
print(response);
```

## Notes

- On iOS, it is not possible to enable/disable Bluetooth via code, only check the state.
- On Android 12+, you may need to request permissions at runtime.

## Development Environment

- To build and test on iOS, you need a Mac with Xcode.
- On Linux/Windows, only Android development is supported.

## Full Example

See the `example/` directory for a sample app.
