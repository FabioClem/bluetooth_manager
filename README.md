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
    BluetoothState bluetoothState =
                      await bluetoothManager.getBluetoothState();
    print(bluetoothState);

```

### Example listener bluetooth state

```dart
    // Get bluetooth state Listener
    // return a BluetoothState
    // on, off and unknow
    bluetoothManager.getBluetoothStateStream().listen((BluetoothState bluetoothState) {
        print(bluetoothState);
        // Do your logic here...
    });
```

### Example turn on/off bluetooth

```dart
    // Enable bluetooth
    // you can call only await 
    // bluetoothManager.disableBluetooth() or await bluetoothManager.enableBluetooth()
    // if you don't want the response
    ActionResponse actionResponse = await bluetoothManager.disableBluetooth();
    print(actionResponse);
    // Disble bluetooth
    ActionResponse actionResponse = await bluetoothManager.enableBluetooth();
    print(actionResponse);
```