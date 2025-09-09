import 'package:bluetooth_manager/models/bluetooth_models.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Gerenciador de Bluetooth para iOS usando MethodChannel.
class BluetoothManagerIOS {
  static const MethodChannel _channel = MethodChannel('bluetooth_manager');

  /// Opens the Bluetooth settings screen on iOS so the user can manually enable/disable Bluetooth.
  Future<void> openBluetoothSettings() async {
    const urlString = 'App-Prefs:root=Bluetooth';
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw Exception('Could not open Bluetooth settings');
    }
  }

  /// Obtém o estado atual do Bluetooth no iOS.
  Future<BluetoothState> getState() async {
    try {
      final result = await _channel.invokeMethod('getBluetoothState');
      if (result == null) {
        throw Exception('Bluetooth state retornou null');
      }
      return enumFromString(BluetoothState.values, result);
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
