
import CoreBluetooth

public class BluetoothManagerPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate {
  var centralManager: CBCentralManager?
  var bluetoothStateResult: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bluetooth_manager", binaryMessenger: registrar.messenger())
    let instance = BluetoothManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    instance.centralManager = CBCentralManager(delegate: instance, queue: nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getBluetoothState":
      // If state is available, return immediately
      if let state = centralManager?.state {
        result(mapBluetoothState(state))
      } else {
        // If not, save result and wait for delegate
        bluetoothStateResult = result
      }
    case "enableBluetooth":
      // Not supported on iOS
      result("not_supported")
    case "disableBluetooth":
      // Not supported on iOS
      result("not_supported")
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // CBCentralManagerDelegate
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if let result = bluetoothStateResult {
      result(mapBluetoothState(central.state))
      bluetoothStateResult = nil
    }
  }

  private func mapBluetoothState(_ state: CBManagerState) -> String {
    switch state {
    case .poweredOn: return "on"
    case .poweredOff: return "off"
    case .resetting: return "resetting"
    case .unauthorized: return "unauthorized"
    case .unsupported: return "unsupported"
    case .unknown: return "unknown"
    @unknown default: return "unknown"
    }
  }
}
