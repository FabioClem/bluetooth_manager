package com.fahen.bluetooth_manager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.util.Log;

/**
 * Flutter plugin that reads and (on supported Android versions) toggles the
 * Bluetooth adapter, and emits state changes through an EventChannel.
 */
public class BluetoothManagerPlugin
    implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

  private static final String TAG = "BluetoothManagerPlugin";
  private static final String METHOD_CHANNEL = "bluetooth_manager";
  private static final String EVENT_CHANNEL = "bluetooth_manager/events";

  private static final String STATE_ON = "on";
  private static final String STATE_OFF = "off";
  private static final String STATE_UNKNOWN = "uknow";

  private static final String RESP_ERROR = "responseError";
  private static final String RESP_ON = "bluetoothIsOn";
  private static final String RESP_OFF = "bluetoothIsOff";
  private static final String RESP_ALREADY_ON = "bluetoothAlreadyOn";
  private static final String RESP_ALREADY_OFF = "bluetoothAlreadyOff";

  private MethodChannel methodChannel;
  private EventChannel eventChannel;
  private Context applicationContext;

  private EventChannel.EventSink eventSink;
  private BroadcastReceiver stateReceiver;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    applicationContext = binding.getApplicationContext();

    methodChannel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANNEL);
    methodChannel.setMethodCallHandler(this);

    eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_CHANNEL);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (methodChannel != null) {
      methodChannel.setMethodCallHandler(null);
      methodChannel = null;
    }
    if (eventChannel != null) {
      eventChannel.setStreamHandler(null);
      eventChannel = null;
    }
    unregisterStateReceiver();
    applicationContext = null;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getBluetoothState":
        result.success(getBluetoothState());
        break;
      case "enableBluetooth":
        result.success(enableBluetooth());
        break;
      case "disableBluetooth":
        result.success(disableBluetooth());
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
    events.success(getBluetoothState());
    registerStateReceiver();
  }

  @Override
  public void onCancel(Object arguments) {
    unregisterStateReceiver();
    eventSink = null;
  }

  private void registerStateReceiver() {
    if (applicationContext == null || stateReceiver != null) {
      return;
    }
    stateReceiver = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        if (!BluetoothAdapter.ACTION_STATE_CHANGED.equals(intent.getAction())) {
          return;
        }
        int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR);
        if (eventSink == null) return;
        switch (state) {
          case BluetoothAdapter.STATE_ON:
            eventSink.success(STATE_ON);
            break;
          case BluetoothAdapter.STATE_OFF:
            eventSink.success(STATE_OFF);
            break;
          default:
            break;
        }
      }
    };
    IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
    applicationContext.registerReceiver(stateReceiver, filter);
  }

  private void unregisterStateReceiver() {
    if (applicationContext != null && stateReceiver != null) {
      try {
        applicationContext.unregisterReceiver(stateReceiver);
      } catch (IllegalArgumentException ignored) {
      }
    }
    stateReceiver = null;
  }

  private String getBluetoothState() {
    try {
      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
        return STATE_UNKNOWN;
      }
      BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
      if (adapter == null) {
        return STATE_UNKNOWN;
      }
      return adapter.isEnabled() ? STATE_ON : STATE_OFF;
    } catch (Exception e) {
      Log.w(TAG, "getBluetoothState failed", e);
      return STATE_UNKNOWN;
    }
  }

  private String enableBluetooth() {
    try {
      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
        return RESP_ERROR;
      }
      // BluetoothAdapter.enable() is deprecated and is a no-op for non-privileged
      // apps on Android 13+ (API 33). Ask the user to toggle it from settings.
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        Log.w(TAG, "enableBluetooth() is not available on Android 13+ for regular apps");
        return RESP_ERROR;
      }
      BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
      if (adapter == null) {
        return RESP_ERROR;
      }
      if (adapter.isEnabled()) {
        return RESP_ALREADY_ON;
      }
      return adapter.enable() ? RESP_ON : RESP_ERROR;
    } catch (SecurityException e) {
      Log.w(TAG, "enableBluetooth failed: missing BLUETOOTH_CONNECT permission", e);
      return RESP_ERROR;
    } catch (Exception e) {
      Log.w(TAG, "enableBluetooth failed", e);
      return RESP_ERROR;
    }
  }

  private String disableBluetooth() {
    try {
      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
        return RESP_ERROR;
      }
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        Log.w(TAG, "disableBluetooth() is not available on Android 13+ for regular apps");
        return RESP_ERROR;
      }
      BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
      if (adapter == null) {
        return RESP_ERROR;
      }
      if (!adapter.isEnabled()) {
        return RESP_ALREADY_OFF;
      }
      return adapter.disable() ? RESP_OFF : RESP_ERROR;
    } catch (SecurityException e) {
      Log.w(TAG, "disableBluetooth failed: missing BLUETOOTH_CONNECT permission", e);
      return RESP_ERROR;
    } catch (Exception e) {
      Log.w(TAG, "disableBluetooth failed", e);
      return RESP_ERROR;
    }
  }
}
