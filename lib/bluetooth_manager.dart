import 'dart:async';

import 'models/bluetooth_models.dart';
import 'path/conf.dart';

/// Main entry point of the plugin.
///
/// Create a single instance of [BluetoothManager] and use it to:
///
/// * read the current adapter state with [getBluetoothState];
/// * observe state changes over time with [getBluetoothStateStream];
/// * turn the adapter on/off with [enableBluetooth] / [disableBluetooth]
///   (on iOS these methods open the system Bluetooth settings screen
///   because the OS does not allow toggling programmatically).
///
/// Example:
///
/// ```dart
/// final bluetoothManager = BluetoothManager();
/// final state = await bluetoothManager.getBluetoothState();
/// ```
class BluetoothManager {
  /// Internal platform router that delegates the calls to the Android, iOS or
  /// macOS implementation.
  final bluetoothManagerPath = BluetoothManagerPath();

  /// Returns the current [BluetoothState] of the device.
  ///
  /// Possible values: [BluetoothState.on], [BluetoothState.off] or
  /// [BluetoothState.uknow] (sic) when the state cannot be determined.
  ///
  /// Throws if the underlying platform channel fails or if the platform is
  /// not supported (only Android, iOS and macOS are supported).
  Future<BluetoothState> getBluetoothState() async {
    try {
      return await bluetoothManagerPath.getState();
    } catch (e) {
      rethrow;
    }
  }

  /// Emits the current [BluetoothState] every time the adapter state
  /// changes.
  ///
  /// The stream is event-driven: on **Android** it is backed by a
  /// `BroadcastReceiver` listening to `BluetoothAdapter.ACTION_STATE_CHANGED`,
  /// and on **iOS** / **macOS** by `CBCentralManagerDelegate.centralManagerDidUpdateState`.
  /// When the subscription is created, the current state is emitted
  /// immediately (on iOS as soon as Core Bluetooth resolves it).
  ///
  /// The [timer] parameter is kept for backwards compatibility with the
  /// previous polling-based implementation and is ignored.
  ///
  /// The returned stream never completes on its own — remember to cancel
  /// the subscription when you no longer need it:
  ///
  /// ```dart
  /// final sub = bluetoothManager.getBluetoothStateStream().listen((state) {
  ///   // handle state...
  /// });
  ///
  /// // later
  /// await sub.cancel();
  /// ```
  Stream<BluetoothState> getBluetoothStateStream({int timer = 1000}) {
    return bluetoothManagerPath.getStateStream(timer: timer);
  }

  /// Attempts to enable the Bluetooth adapter.
  ///
  /// * On **Android** it calls `BluetoothAdapter.enable()` and returns an
  ///   [ActionResponse] describing the outcome:
  ///   [ActionResponse.bluetoothIsOn] when the adapter was turned on by this
  ///   call, [ActionResponse.bluetoothAlreadyOn] when it was already on, or
  ///   [ActionResponse.responseError] on failure (including Android 13+,
  ///   where the API is deprecated and no longer works for regular apps).
  /// * On **iOS** / **macOS** it opens the system Bluetooth settings screen and returns
  ///   [ActionResponse.openedIOSSettings] (the OS does not expose a
  ///   programmatic toggle).
  Future<ActionResponse> enableBluetooth() async {
    try {
      return await bluetoothManagerPath.enable();
    } catch (e) {
      rethrow;
    }
  }

  /// Attempts to disable the Bluetooth adapter.
  ///
  /// * On **Android** it calls `BluetoothAdapter.disable()` and returns an
  ///   [ActionResponse]: [ActionResponse.bluetoothIsOff] when the adapter was
  ///   turned off by this call, [ActionResponse.bluetoothAlreadyOff] when it
  ///   was already off, or [ActionResponse.responseError] on failure (also
  ///   on Android 13+, where the API is deprecated).
  /// * On **iOS** / **macOS** it opens the system Bluetooth settings screen and returns
  ///   [ActionResponse.openedIOSSettings].
  Future<ActionResponse> disableBluetooth() async {
    try {
      return await bluetoothManagerPath.disable();
    } catch (e) {
      rethrow;
    }
  }
}
