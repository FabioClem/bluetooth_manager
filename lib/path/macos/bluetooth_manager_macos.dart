import 'package:bluetooth_manager/models/bluetooth_models.dart';
import 'package:flutter/services.dart';

/// macOS-specific implementation of the plugin.
///
/// macOS does not expose a public API to toggle Bluetooth. This class reads
/// the adapter state through `CoreBluetooth` on the native side and can open
/// the Bluetooth pane in System Settings.
///
/// State changes are delivered through the `bluetooth_manager/events`
/// [EventChannel], backed by `CBCentralManagerDelegate` on the native side.
class BluetoothManagerMacOS {
  static const MethodChannel _channel = MethodChannel('bluetooth_manager');
  static const EventChannel _events = EventChannel('bluetooth_manager/events');

  /// Opens System Settings so the user can enable or disable Bluetooth.
  Future<void> openBluetoothSettings() async {
    try {
      await _channel.invokeMethod<void>('openBluetoothSettings');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Could not open Bluetooth settings');
    }
  }

  /// Returns the current [BluetoothState] reported by the native macOS plugin.
  Future<BluetoothState> getState() async {
    try {
      final result = await _channel.invokeMethod<String>('getBluetoothState');
      return enumFromString(BluetoothState.values, result) ??
          BluetoothState.uknow;
    } catch (_) {
      return BluetoothState.uknow;
    }
  }

  /// Emits the current [BluetoothState] every time the adapter state changes.
  ///
  /// The [timer] parameter is kept for backwards compatibility and is ignored.
  Stream<BluetoothState> getStateStream({int timer = 1000}) {
    return _events.receiveBroadcastStream().map((event) {
      return enumFromString(BluetoothState.values, event as String?) ??
          BluetoothState.uknow;
    });
  }
}
