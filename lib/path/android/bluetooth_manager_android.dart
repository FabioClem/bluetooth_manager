import '../../models/bluetooth_models.dart';
import 'package:flutter/services.dart';

/// Gerenciador de Bluetooth para Android usando MethodChannel.
class BluetoothManagerAndroid {
  static const MethodChannel _channel = MethodChannel('bluetooth_manager');

  /// Obtém o estado atual do Bluetooth.
  Future<BluetoothState> getState() async {
    try {
      final result = await _channel.invokeMethod('getBluetoothState');
      if (result == null) {
        throw Exception('Bluetooth state retornou null');
      }
      return enumFromString(BluetoothState.values, result);
    } catch (e) {
      // Retorne um estado desconhecido ou rethrow, conforme necessidade
      rethrow;
    }
  }

  /// Habilita o Bluetooth.
  Future<ActionResponse> enable() async {
    try {
      final result = await _channel.invokeMethod('enableBluetooth');
      if (result == null) {
        throw Exception('enableBluetooth retornou null');
      }
      return enumFromString(ActionResponse.values, result);
    } catch (e) {
      rethrow;
    }
  }

  /// Desabilita o Bluetooth.
  Future<ActionResponse> disable() async {
    try {
      final result = await _channel.invokeMethod('disableBluetooth');
      if (result == null) {
        throw Exception('disableBluetooth retornou null');
      }
      return enumFromString(ActionResponse.values, result);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream do estado do Bluetooth, atualiza a cada [timer] ms.
  Stream<BluetoothState> getStateStream({int timer = 1000}) async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: timer < 500 ? 500 : timer));
      yield await getState();
    }
  }
}
