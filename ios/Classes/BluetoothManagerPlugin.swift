import Flutter
import CoreBluetooth

public class BluetoothManagerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, CBCentralManagerDelegate {
  private static let methodChannelName = "bluetooth_manager"
  private static let eventChannelName = "bluetooth_manager/events"
  private static let stateResolutionTimeout: TimeInterval = 3.0

  private var centralManager: CBCentralManager?
  private var pendingResults: [FlutterResult] = []
  private var eventSink: FlutterEventSink?
  private var hasEmittedInitialState = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = BluetoothManagerPlugin()

    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getBluetoothState":
      resolveState(result: result)
    case "openBluetoothSettings":
      openBluetoothSettings(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    hasEmittedInitialState = false
    ensureCentralManager()
    emitIfReady()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    hasEmittedInitialState = false
    return nil
  }

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    let state = mapBluetoothState(central.state)
    flushPendingResults(with: state)
    eventSink?(state)
    hasEmittedInitialState = true
  }

  private func resolveState(result: @escaping FlutterResult) {
    ensureCentralManager()

    guard let central = centralManager else {
      result("uknow")
      return
    }

    if central.state != .unknown {
      result(mapBluetoothState(central.state))
      return
    }

    pendingResults.append(result)
    DispatchQueue.main.asyncAfter(deadline: .now() + Self.stateResolutionTimeout) { [weak self] in
      self?.flushPendingResults(with: "uknow")
    }
  }

  private func ensureCentralManager() {
    if centralManager == nil {
      centralManager = CBCentralManager(delegate: self, queue: nil)
    }
  }

  private func emitIfReady() {
    guard let sink = eventSink, let central = centralManager else { return }
    if central.state != .unknown {
      sink(mapBluetoothState(central.state))
      hasEmittedInitialState = true
    }
  }

  private func flushPendingResults(with state: String) {
    guard !pendingResults.isEmpty else { return }
    let callbacks = pendingResults
    pendingResults.removeAll()
    for callback in callbacks {
      callback(state)
    }
  }

  private func mapBluetoothState(_ state: CBManagerState) -> String {
    switch state {
    case .poweredOn: return "on"
    case .poweredOff: return "off"
    default: return "uknow"
    }
  }

  /// Tries known settings URLs (often blocked on current iOS), then falls back
  /// to the app’s Settings page, which is the only reliably supported option.
  private func openBluetoothSettings(result: @escaping FlutterResult) {
    let candidates = [
      "App-Prefs:root=Bluetooth",
      "App-Prefs:root=General&path=Bluetooth",
      "prefs:root=Bluetooth",
    ]
    tryOpenSettingsURL(candidates: candidates, index: 0, result: result)
  }

  private func tryOpenSettingsURL(candidates: [String], index: Int, result: @escaping FlutterResult) {
    if index >= candidates.count {
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        result(
          FlutterError(
            code: "open_settings_failed",
            message: "Could not open Bluetooth settings",
            details: nil))
        return
      }
      UIApplication.shared.open(url, options: [:]) { success in
        if success {
          result(nil)
        } else {
          result(
            FlutterError(
              code: "open_settings_failed",
              message: "Could not open Bluetooth settings",
              details: nil))
        }
      }
      return
    }

    guard let url = URL(string: candidates[index]) else {
      tryOpenSettingsURL(candidates: candidates, index: index + 1, result: result)
      return
    }

    UIApplication.shared.open(url, options: [:]) { [weak self] success in
      if success {
        result(nil)
      } else {
        self?.tryOpenSettingsURL(candidates: candidates, index: index + 1, result: result)
      }
    }
  }
}
