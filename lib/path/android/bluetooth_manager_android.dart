import '../../models/bluetooth_models.dart';
import 'package:flutter/services.dart';

/// Android-specific implementation of the plugin.
///
/// Talks to the native side through the `bluetooth_manager` [MethodChannel]
/// and listens to adapter state changes through the
/// `bluetooth_manager/events` [EventChannel]. Raw string responses coming
/// from the native side are converted into the typed enums
/// [BluetoothState] / [ActionResponse]. Any unknown value is mapped to
/// [BluetoothState.uknow] / [ActionResponse.responseError] so the Dart layer
/// never throws a `TypeError`.
class BluetoothManagerAndroid {
  static const MethodChannel _channel = MethodChannel('bluetooth_manager');
  static const EventChannel _events = EventChannel('bluetooth_manager/events');

  /// Returns the current [BluetoothState] reported by the native Android
  /// plugin. Unknown values are mapped to [BluetoothState.uknow].
  Future<BluetoothState> getState() async {
    try {
      final result = await _channel.invokeMethod<String>('getBluetoothState');
      return enumFromString(BluetoothState.values, result) ??
          BluetoothState.uknow;
    } catch (_) {
      return BluetoothState.uknow;
    }
  }

  /// Calls `BluetoothAdapter.enable()` on the native side.
  ///
  /// Note: starting with Android 13 (API 33) this API is deprecated and no
  /// longer works for non-privileged apps — the plugin returns
  /// [ActionResponse.responseError] in that case.
  Future<ActionResponse> enable() async {
    try {
      final result = await _channel.invokeMethod<String>('enableBluetooth');
      return enumFromString(ActionResponse.values, result) ??
          ActionResponse.responseError;
    } catch (_) {
      return ActionResponse.responseError;
    }
  }

  /// Calls `BluetoothAdapter.disable()` on the native side.
  ///
  /// Same Android 13+ caveat as [enable] applies.
  Future<ActionResponse> disable() async {
    try {
      final result = await _channel.invokeMethod<String>('disableBluetooth');
      return enumFromString(ActionResponse.values, result) ??
          ActionResponse.responseError;
    } catch (_) {
      return ActionResponse.responseError;
    }
  }

  /// Emits the current [BluetoothState] every time the adapter changes state.
  ///
  /// Backed by a `BroadcastReceiver` listening to
  /// `BluetoothAdapter.ACTION_STATE_CHANGED` on the native side, so the
  /// stream only emits when the state actually changes (plus one initial
  /// emission on subscription).
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
