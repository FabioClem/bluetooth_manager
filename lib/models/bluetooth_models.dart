/// Represents the current state of the device's Bluetooth adapter.
enum BluetoothState {
  /// The Bluetooth adapter is turned on.
  on,

  /// The Bluetooth adapter is turned off.
  off,

  /// The state could not be determined (permission denied, unsupported
  /// hardware, transient native error, etc.).
  ///
  /// Note: this value is intentionally spelled `uknow` (without the "n") for
  /// backwards compatibility with older releases of the plugin.
  uknow,
}

/// Result of a call to `enableBluetooth` or `disableBluetooth`.
enum ActionResponse {
  /// Android: the adapter was turned on by this call.
  bluetoothIsOn,

  /// Android: the adapter was turned off by this call.
  bluetoothIsOff,

  /// Android: the adapter was already on.
  bluetoothAlreadyOn,

  /// Android: the adapter was already off.
  bluetoothAlreadyOff,

  /// The native side returned an error (unsupported SDK, missing permission,
  /// Android 13+ where the API is deprecated, etc.).
  responseError,

  /// iOS: the plugin opened the system Bluetooth settings screen so the user
  /// can toggle the adapter manually.
  openedIOSSettings,
}

/// Looks up an enum value by its string representation.
///
/// Given `values` (typically `SomeEnum.values`) and `comp` (for example the
/// string returned from a platform channel), returns the matching enum entry
/// or `null` when no entry matches or `comp` is `null`.
///
/// Example:
///
/// ```dart
/// final state = enumFromString(BluetoothState.values, 'on');
/// // state == BluetoothState.on
/// ```
T? enumFromString<T>(List<T> values, String? comp) {
  if (comp == null) return null;
  for (final value in values) {
    if (value.toString().split('.').last == comp) {
      return value;
    }
  }
  return null;
}
