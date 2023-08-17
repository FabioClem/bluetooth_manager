// ignore_for_file: avoid_print

import 'dart:async';

import 'package:bluetooth_manager/models/bluetooth_models.dart';
import 'package:flutter/material.dart';

import 'package:bluetooth_manager/bluetooth_manager.dart';

import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothManager bluetoothManager = BluetoothManager();

  late BluetoothState _bluetoothState = BluetoothState.uknow;

  StreamSubscription<BluetoothState>? subscription;
  bool isListenerOn = false;

  @override
  void initState() {
    setBluetoothPermission();
    super.initState();
  }

  setBluetoothPermission() async {
    print(await Permission.bluetooth.request().isGranted);
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Bluetooth State: ',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    _bluetoothState.toString().split('.').last,
                    style: TextStyle(
                      fontSize: 24,
                      color: _bluetoothState == BluetoothState.on
                          ? Colors.green
                          : _bluetoothState == BluetoothState.off
                              ? Colors.red
                              : Colors.grey,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  /// cancel the listener if they are active and get the state
                  if (subscription != null) {
                    setState(() {
                      isListenerOn = false;
                    });
                    subscription!.cancel();
                  }

                  /// Get bluetooth state
                  /// and set info [BluetoothState] in local _bluetoothState
                  BluetoothState bluetoothState =
                      await bluetoothManager.getBluetoothState();
                  setState(() {
                    _bluetoothState = bluetoothState;
                  });
                },
                child: const Text('Get bluetooth State'),
              ),
              const SizedBox(height: 50),
              Text(
                isListenerOn ? 'Listener On' : 'Listener Off',
                style: const TextStyle(fontSize: 16),
              ),
              ElevatedButton(
                onPressed: () async {
                  /// Listen bluetooth state
                  /// and set info [BluetoothState] in local _bluetoothState
                  /// dont forget to cancel if you are not using
                  setState(() {
                    isListenerOn = !isListenerOn;
                  });
                  subscription = bluetoothManager
                      .getBluetoothStateStream(timer: 500)
                      .listen((BluetoothState bluetoothState) {
                    // Do your logic here...
                    setState(() {
                      _bluetoothState = bluetoothState;
                    });
                  });
                },
                child: const Text('Listen/Pause bluetooth State'),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  /// valid bluetooth state
                  if (_bluetoothState == BluetoothState.on) {
                    /// if bluetooth state is on disable
                    /// and get [ActionResponse]
                    ActionResponse actionResponse =
                        await bluetoothManager.disableBluetooth();
                    print(actionResponse);
                  } else {
                    /// if bluetooth state is off enable
                    /// /// and get [ActionResponse]
                    ActionResponse actionResponse =
                        await bluetoothManager.enableBluetooth();
                    print(actionResponse);
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
