enum BluetoothState {
  on,
  off,
  uknow,
}

enum ActionResponse {
  bluetoothIsOn,
  bluetoothIsOff,
  bluetoothAlreadyOn,
  bluetoothAlreadyOff,
  responseError,
}

dynamic enumFromString(List values, String comp) {
  dynamic enumValue;
  for (var item in values) {
    if (item.toString().toString().split('.').last == comp) {
      enumValue = item;
    }
  }
  return enumValue;
}
