import 'dart:async';

import 'package:flutter/services.dart';

import 'models/bluetooth_models.dart';

class BluetoothManager {
  static const MethodChannel _channel = MethodChannel('bluetooth_manager');

  /// get bluetooth state with response [BluetoothState]
  ///
  /// Response on, off, uknow
  static Future<BluetoothState?> get getBluetoothState async {
    final BluetoothState state;
    try {
      state = enumFromString(BluetoothState.values,
          await _channel.invokeMethod('getBluetoothState'));
    } catch (e) {
      rethrow;
    }
    return state;
  }

  /// enable bluetooth
  ///
  /// and can return the bluetooth action response [ActionResponse]
  /// bluetoothIsOn, bluetoothIsOff, bluetoothAlreadyOn, bluetoothAlreadyOff, responseError
  static Future<ActionResponse?> enableBluetooth() async {
    final ActionResponse actionResponse;
    try {
      actionResponse = enumFromString(ActionResponse.values,
          await _channel.invokeMethod('enableBluetooth'));
    } catch (e) {
      rethrow;
    }
    return actionResponse;
  }

  /// disable bluetooth
  ///
  /// and can return the bluetooth action response [ActionResponse]
  /// bluetoothIsOn, bluetoothIsOff, bluetoothAlreadyOn, bluetoothAlreadyOff, responseError
  static Future<ActionResponse?> disableBluetooth() async {
    final ActionResponse actionResponse;
    try {
      actionResponse = enumFromString(ActionResponse.values,
          await _channel.invokeMethod('disableBluetooth'));
    } catch (e) {
      rethrow;
    }
    return actionResponse;
  }
}
