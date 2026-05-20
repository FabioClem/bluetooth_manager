import Cocoa
import CoreBluetooth
import FlutterMacOS

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
      binaryMessenger: registrar.messenger
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger
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

  /// Opens the macOS Bluetooth pane in System Settings (or System Preferences on
  /// older releases). Programmatic toggling is not supported by the OS.
  private func openBluetoothSettings(result: @escaping FlutterResult) {
    let candidates = [
      "x-apple.systempreferences:com.apple.Bluetooth-Settings.extension",
      "x-apple.systempreferences:com.apple.preference.Bluetooth",
    ]

    for urlString in candidates {
      guard let url = URL(string: urlString) else { continue }
      if NSWorkspace.shared.open(url) {
        result(nil)
        return
      }
    }

    result(
      FlutterError(
        code: "open_settings_failed",
        message: "Could not open Bluetooth settings",
        details: nil))
  }
}
