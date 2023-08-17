import '../../models/bluetooth_models.dart';
import 'package:flutter/services.dart';

class BluetoothManagerAndroid {
  static const MethodChannel _channel = MethodChannel('bluetooth_manager');

  Future<BluetoothState> getState() async {
    try {
      return enumFromString(BluetoothState.values,
          await _channel.invokeMethod('getBluetoothState'));
    } catch (e) {
      rethrow;
    }
  }

  Future<ActionResponse> enable() async {
    try {
      return enumFromString(ActionResponse.values,
          await _channel.invokeMethod('enableBluetooth'));
    } catch (e) {
      rethrow;
    }
  }

  Future<ActionResponse> disable() async {
    try {
      return enumFromString(ActionResponse.values,
          await _channel.invokeMethod('disableBluetooth'));
    } catch (e) {
      rethrow;
    }
  }
}
