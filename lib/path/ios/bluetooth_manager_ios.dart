import 'package:bluetooth_manager/models/bluetooth_models.dart';
import 'package:flutter/services.dart';

/// iOS-specific implementation of the plugin.
///
/// Because iOS does not expose a public API to toggle Bluetooth, this class
/// can only read the current state (through `CoreBluetooth` on the native
/// side) and ask the system to open settings. Deep links to the Bluetooth pane
/// are attempted on the native side but are often ignored by iOS; the plugin
/// then falls back to your app’s page in the Settings app.
///
/// State changes are delivered through the `bluetooth_manager/events`
/// [EventChannel], which is backed by `CBCentralManagerDelegate` on the
/// native side.
class BluetoothManagerIOS {
  static const MethodChannel _channel = MethodChannel('bluetooth_manager');
  static const EventChannel _events = EventChannel('bluetooth_manager/events');

  /// Opens settings so the user can enable or disable Bluetooth.
  ///
  /// Uses a native method that tries Bluetooth-specific URLs first, then
  /// falls back to [UIApplication.openSettingsURLString] when the system
  /// rejects those (common on current iOS). Throws if nothing could be opened.
  Future<void> openBluetoothSettings() async {
    try {
      await _channel.invokeMethod<void>('openBluetoothSettings');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Could not open Bluetooth settings');
    }
  }

  /// Returns the current [BluetoothState] reported by the native iOS plugin.
  ///
  /// The native side only ever returns `"on"`, `"off"` or `"uknow"` (values
  /// such as `resetting`, `unauthorized` and `unsupported` are coalesced to
  /// `"uknow"`). Any unexpected value is also mapped to
  /// [BluetoothState.uknow].
  Future<BluetoothState> getState() async {
    try {
      final result = await _channel.invokeMethod<String>('getBluetoothState');
      return enumFromString(BluetoothState.values, result) ??
          BluetoothState.uknow;
    } catch (_) {
      return BluetoothState.uknow;
    }
  }

  /// Emits the current [BluetoothState] every time the adapter state
  /// changes.
  ///
  /// Backed by `CBCentralManagerDelegate.centralManagerDidUpdateState` on
  /// the native side, so the stream only emits when the state actually
  /// changes (plus one initial emission on subscription once the central
  /// manager has resolved its state).
  ///
  /// The [timer] parameter is kept for backwards compatibility and is
  /// ignored — the stream is event-driven, not polled.
  Stream<BluetoothState> getStateStream({int timer = 1000}) {
    return _events.receiveBroadcastStream().map((event) {
      return enumFromString(BluetoothState.values, event as String?) ??
          BluetoothState.uknow;
    });
  }
}
