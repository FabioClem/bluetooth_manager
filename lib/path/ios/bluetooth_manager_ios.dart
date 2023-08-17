import '../../models/bluetooth_models.dart';

class BluetoothManagerIOS {
  Future<BluetoothState> getState() async {
    try {
      throw 'iOS [getState] -> not_implemented';
    } catch (e) {
      rethrow;
    }
  }

  Stream<BluetoothState> getStateStream({int timer = 1000}) async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: timer < 500 ? 500 : timer));
      yield await getState();
    }
  }

  Future<ActionResponse> enable() async {
    try {
      throw 'iOS [enable_bluetooth] -> not_implemented';
    } catch (e) {
      rethrow;
    }
  }

  Future<ActionResponse> disable() async {
    try {
      throw 'iOS [disable_bluetooth] -> not_implemented';
    } catch (e) {
      rethrow;
    }
  }
}
