import 'dart:async';

import 'models/bluetooth_models.dart';
import 'path/conf.dart';

class BluetoothManager {
  final bluetoothManagerPath = BluetoothManagerPath();

  /// get bluetooth state with response [BluetoothState]
  ///
  /// Response on, off, uknow
  Future<BluetoothState> getBluetoothState() async {
    try {
      return await bluetoothManagerPath.getState();
    } catch (e) {
      rethrow;
    }
  }

  /// get bluetooth Stream state with response [BluetoothState]
  /// you can pass timer in milliseconds the default is 1000
  ///
  /// getBluetoothStateStream(timer: 1000).listen((event) {
  ///   print(event);
  /// });
  ///
  /// Response on, off, uknow
  Stream<BluetoothState> getBluetoothStateStream({int timer = 1000}) async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: timer < 500 ? 500 : timer));
      yield await getBluetoothState();
    }
  }

  /// enable bluetooth
  ///
  /// and can return the bluetooth action response [ActionResponse]
  /// bluetoothIsOn, bluetoothIsOff, bluetoothAlreadyOn, bluetoothAlreadyOff, responseError
  Future<ActionResponse> enableBluetooth() async {
    try {
      return await bluetoothManagerPath.enable();
    } catch (e) {
      rethrow;
    }
  }

  /// disable bluetooth
  ///
  /// and can return the bluetooth action response [ActionResponse]
  /// bluetoothIsOn, bluetoothIsOff, bluetoothAlreadyOn, bluetoothAlreadyOff, responseError
  Future<ActionResponse> disableBluetooth() async {
    try {
      return await bluetoothManagerPath.disable();
    } catch (e) {
      rethrow;
    }
  }
}
