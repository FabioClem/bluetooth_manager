# bluetooth_manager

Bluetooth Manager it's a Android Plugin to control the bluetooth basics, turning on/off and get the state.

## How to Start

Import the library

```dart
    import 'package:bluetooth_manager/bluetooth_manager.dart';
```

## Use exemple
### Example get bluetooth state

```dart
    // Get bluetooth state
    // return a BluetoothState
    // on, off and unknow
    await BluetoothManager.getBluetoothState.then((value) async => {
        // ...
        print(value)
    });

```

### Example turn on/off bluetooth

```dart
    // Enable bluetooth
    await BluetoothManager.enableBluetooth();
    // Disble bluetooth
    await BluetoothManager.disableBluetooth();
```

### Example turn on/off bluetooth with ActionResponse

```dart

    // return a ActionResponse
    // bluetoothIsOn, bluetoothIsOff, bluetoothAlreadyOn, bluetoothAlreadyOff, responseError

    // Enable bluetooth and return state
    await BluetoothManager.enableBluetooth().then((value) => {
        // ...
        print(value),
    });
    // Disble bluetooth and return state
    await BluetoothManager.disableBluetooth().then((value) => {
        // ...
        print(value),
     });

    
```