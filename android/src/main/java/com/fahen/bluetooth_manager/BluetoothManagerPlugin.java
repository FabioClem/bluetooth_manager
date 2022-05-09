package com.fahen.bluetooth_manager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.bluetooth.BluetoothAdapter;
import android.os.Build;

/**
 * A simple plugin to manage Bluetooth, turning on and off ang geting Bluetooth state.
 */
public class BluetoothManagerPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  /**
   * init override
   * @param flutterPluginBinding
   */
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "bluetooth_manager");
    channel.setMethodCallHandler(this);
  }

  /**
   * init override
   * valid versions and methods
   * @param call
   * @param result
   */
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String callResult = "";
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("getBluetoothState")) {
      callResult = getBluetoothState();
    } else if (call.method.equals("enableBluetooth")) {
      callResult = enableBluetooth();
    } else if (call.method.equals("disableBluetooth")) {
      callResult = disableBluetooth();
    } else {
      result.notImplemented();
    }

    if (callResult == "version_error" || callResult == "responseError") {
      result.error("ERROR", "Android version lower than 4.4 (KitKat) is unsupported | .", callResult);
    } else {
      result.success(callResult);
    }
  }


  /**
   * get bluetooth state with response [BluetoothState] 
   * Response on, off, uknow
   * @return String = BluetoothState
   */
  private String getBluetoothState() {
    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (bluetoothAdapter.isEnabled()) {
          return "on";
        } else {
          return "off";
        }
      } else {
        return "version_error";
      }
    } catch (Exception e) {
      System.out.println(e);
      return "uknow";
    }
  }

  /**
   * enable bluetooth 
   * and can return the bluetooth action response [ActionResponse]
   * bluetoothIsOn, bluetoothIsOff, bluetoothAlreadyOn, bluetoothAlreadyOff, responseError
   * @return String = ActionResponse
   */
  private String enableBluetooth() {
    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (bluetoothAdapter.isEnabled()) {
          return "bluetoothAlreadyOn";
        } else {
          bluetoothAdapter.enable();
          return "bluetoothIsOn";
        }
      } else {
        return "version_error";
      }
    } catch (Exception e) {
      System.out.println(e);
      return "responseError";
    }
  }

  /**
   * disable bluetooth 
   * and can return the bluetooth action response [ActionResponse]
   * bluetoothIsOn, bluetoothIsOff, bluetoothAlreadyOn, bluetoothAlreadyOff, responseError
   * @return String = ActionResponse
   */
  private String disableBluetooth() {
    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (bluetoothAdapter.isEnabled()) {
          bluetoothAdapter.disable();
          return "bluetoothIsOff";
        } else {
          return "bluetoothAlreadyOff";
        }
      } else {
        return "version_error";
      }
    } catch (Exception e) {
      System.out.println(e);
      return "responseError";
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
