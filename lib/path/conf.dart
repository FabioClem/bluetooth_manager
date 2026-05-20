import 'dart:io';

import 'android/bluetooth_manager_android.dart';
import 'ios/bluetooth_manager_ios.dart';
import 'macos/bluetooth_manager_macos.dart';
import '../models/bluetooth_models.dart';

/// Platform router used internally by `BluetoothManager`.
///
/// It delegates each operation to the Android, iOS or macOS implementation
/// based on `Platform.isAndroid` / `Platform.isIOS` / `Platform.isMacOS`.
/// When running on any other platform every method throws a descriptive
/// `platform_not_supported` error.
class BluetoothManagerPath {
  /// Android implementation, used when `Platform.isAndroid` is `true`.
  final bmAndroid = BluetoothManagerAndroid();

  /// iOS implementation, used when `Platform.isIOS` is `true`.
  final bmIOS = BluetoothManagerIOS();

  /// macOS implementation, used when `Platform.isMacOS` is `true`.
  final bmMacOS = BluetoothManagerMacOS();

  /// Returns the current [BluetoothState] of the device.
  ///
  /// Throws if the host platform is not Android, iOS or macOS.
  Future<BluetoothState> getState() async {
    try {
      if (Platform.isAndroid) {
        return await bmAndroid.getState();
      } else if (Platform.isIOS) {
        return await bmIOS.getState();
      } else if (Platform.isMacOS) {
        return await bmMacOS.getState();
      } else {
        throw '[get_state] platform_not_supported - only Android, iOS and macOS are supported';
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Enables the Bluetooth adapter on Android or opens the Bluetooth settings
  /// screen on iOS / macOS.
  ///
  /// On iOS and macOS the returned value is always
  /// [ActionResponse.openedIOSSettings] because toggling the adapter
  /// programmatically is not allowed by the OS.
  Future<ActionResponse> enable() async {
    try {
      if (Platform.isAndroid) {
        return await bmAndroid.enable();
      } else if (Platform.isIOS) {
        await bmIOS.openBluetoothSettings();
        return ActionResponse.openedIOSSettings;
      } else if (Platform.isMacOS) {
        await bmMacOS.openBluetoothSettings();
        return ActionResponse.openedIOSSettings;
      } else {
        throw '[enable_bluetooth] platform_not_supported - only Android, iOS and macOS are supported';
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Disables the Bluetooth adapter on Android or opens the Bluetooth settings
  /// screen on iOS / macOS.
  ///
  /// On iOS and macOS the returned value is always
  /// [ActionResponse.openedIOSSettings].
  Future<ActionResponse> disable() async {
    try {
      if (Platform.isAndroid) {
        return await bmAndroid.disable();
      } else if (Platform.isIOS) {
        await bmIOS.openBluetoothSettings();
        return ActionResponse.openedIOSSettings;
      } else if (Platform.isMacOS) {
        await bmMacOS.openBluetoothSettings();
        return ActionResponse.openedIOSSettings;
      } else {
        throw '[disable_bluetooth] platform_not_supported - only Android, iOS and macOS are supported';
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Emits the current [BluetoothState] when the adapter state changes.
  ///
  /// See [BluetoothManagerAndroid.getStateStream],
  /// [BluetoothManagerIOS.getStateStream] and
  /// [BluetoothManagerMacOS.getStateStream] for details.
  Stream<BluetoothState> getStateStream({int timer = 1000}) async* {
    if (Platform.isAndroid) {
      yield* bmAndroid.getStateStream(timer: timer);
    } else if (Platform.isIOS) {
      yield* bmIOS.getStateStream(timer: timer);
    } else if (Platform.isMacOS) {
      yield* bmMacOS.getStateStream(timer: timer);
    } else {
      throw '[get_state_stream] platform_not_supported - only Android, iOS and macOS are supported';
    }
  }
}
