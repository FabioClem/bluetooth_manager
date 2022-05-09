import 'package:bluetooth_manager/models/bluetooth_models.dart';
import 'package:flutter/material.dart';

import 'package:bluetooth_manager/bluetooth_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BluetoothState _bluetoothState = BluetoothState.uknow;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Bluetooth State: $_bluetoothState\n'),
              ElevatedButton(
                onPressed: () async {
                  /// Get bluetooth state
                  /// and set info [BluetoothState] in local _bluetoothState
                  await BluetoothManager.getBluetoothState
                      .then((value) async => {
                            setState(() {
                              _bluetoothState = value!;
                            }),
                          });
                },
                child: const Text('Get bluetooth State'),
              ),
              ElevatedButton(
                onPressed: () async {
                  /// valid bluetooth state
                  if (_bluetoothState == BluetoothState.on) {
                    /// if bluetooth state is on disable
                    /// and get [ActionResponse]
                    await BluetoothManager.disableBluetooth().then(
                      (value) => {
                        ///...
                        print(value),
                      },
                    );
                  } else {
                    /// if bluetooth state is off enable
                    /// /// and get [ActionResponse]
                    await BluetoothManager.enableBluetooth().then(
                      (value) => {
                        ///...
                        print(value),
                      },
                    );
                  }
                },
                child: const Text('Turn on/off'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
