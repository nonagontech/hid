package com.example.hid_android;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbEndpoint;
import android.hardware.usb.UsbInterface;
import android.hardware.usb.UsbManager;
import android.hardware.usb.UsbRequest;
import android.util.Log;

import android.app.Service;


import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;

import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;

import java.util.Timer;
import java.util.TimerTask;
import android.os.Binder;
import android.os.IBinder;
import android.widget.Toast;
import android.os.Handler;
import android.os.Looper;



/** HidAndroidPlugin */
public class HidAndroidPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context context;
  private Activity activity;

  private static final String TAG = "ReactNative";
  private static final String ACTION_USB_PERMISSION = "me.andyshea.scanner.USB_PERMISSION";
  private static final char[] HEX_ARRAY = "0123456789ABCDEF".toCharArray();
  private static final int READ_INTERVAL = 50;

  private final static char[] mChars = "0123456789ABCDEF".toCharArray();
  private final static String mHexStr = "0123456789ABCDEF";


  private Object locker = new Object();
  private UsbManager manager;
  private UsbDevice device;
  private UsbEndpoint endpointIn;
  private UsbEndpoint endpointOut;
  private UsbDeviceConnection connection;
  // private Promise connectionPromise;
  private UsbInterface interface1, interface2;
  private UsbEndpoint epBulkOut, epIntEndpointOut, epIntEndpointIn, epBulkIn, epControl;

  private static int TIMEOUT = 3000;
  private boolean isMeasureing = false;
  private int connectCount = 0;
  private Timer timer;
  private TimerTask task;
  private Handler uiThreadHandler = new Handler(Looper.getMainLooper());


  // 事件派发对象
  private  EventChannel.EventSink eventSink = null;
  // 事件派发流
  private  EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler(){
  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
  }
  @Override
  public void onCancel(Object arguments) {
    eventSink = null;
  }
};







@Override
public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

  channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "hid_android");
  channel.setMethodCallHandler(this);
  context = flutterPluginBinding.getApplicationContext();
  // EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "hid_android1");

  // eventChannel.setStreamHandler(streamHandler); 


}
@Override
public void onDetachedFromActivity() {

}

@Override
public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

}

@Override
public void onAttachedToActivity(ActivityPluginBinding binding) {
  // activity = binding.activity;
}
@Override
public void onDetachedFromActivityForConfigChanges() {

}


@Override
public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
  if (call.method.equals("getPlatformVersion")) {

    result.success("Android " + android.os.Build.VERSION.RELEASE);
  } else if (call.method.equals("initialize")) {
    System.out.println("initialize");
    initialize();
  } else {
    result.notImplemented();
  }
}

@Override
public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  channel.setMethodCallHandler(null);
}
  // @Override
  // public void onListen(Object arguments, EventChannel.EventSink events) {
  //   System.out.println("eventSink---onListen");
  //   // eventChannel 建立连接
  //   eventSink = events;
  // }

  // @Override
  // public void onCancel(Object arguments) {
  //   System.out.println("eventSink---onCancel");
  //     eventSink = null;
  // }

  public void initialize() {

  registReceiver();
  connect(1155, 22352);
}
void registReceiver() {
    IntentFilter filter = new IntentFilter();
  // 设备插入
  filter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
  // 设备拔出
  filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
  context.registerReceiver(deveiceReceiver, filter);
}
  BroadcastReceiver deveiceReceiver = new BroadcastReceiver() {

  @Override
  public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();

    if (action.equals(UsbManager.ACTION_USB_DEVICE_ATTACHED)) {

      connect(1155, 22352);
    } else if (action.equals(UsbManager.ACTION_USB_DEVICE_DETACHED)) {

       channel.invokeMethod("onUsbStatus", false);

      if (timer != null) {
        timer.cancel();
        timer = null;

      }
      if (task != null) {
        task.cancel();
      }

      device = null;
    }
  }
};
  public void connect(int vendorId, int productId) {
  System.out.println("connectFun");
  // connectionPromise = promise;
  manager = (UsbManager)  context.getSystemService(context.USB_SERVICE);
  try {
    HashMap < String, UsbDevice > deviceList = manager.getDeviceList();
    Iterator < UsbDevice > deviceIterator = deviceList.values().iterator();

    while (deviceIterator.hasNext()) {
        UsbDevice device = deviceIterator.next();
      if (device.getVendorId() == 1155 && device.getProductId() == 22352) {
        System.out.println("哈哈哈");
        this.device = device;
      }
    }
    // System.out.println("device");
    // System.out.println(device);
    if (device == null) {
       channel.invokeMethod("onUsbStatus", false);

      rejectConnectionPromise(
        "E100",
        String.format(Locale.US, "No USB device found matching vendor ID %d and product ID %d", vendorId,
          productId));
    } else {
       channel.invokeMethod("onUsbStatus", true);
      System.out.println("哈哈哈Checking USB permission...");
        PendingIntent usbPermissionIntent = PendingIntent.getBroadcast(context, 0,
        new Intent(ACTION_USB_PERMISSION), 0);
        IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);

      context.registerReceiver(mUsbPermissionActionReceiver, filter);

      if (manager.hasPermission(this.device)) {
        // afterGetPermission(this.device);
      } else {
        // this line will let android popup window, ask user whether to
        // allow this app to have permission to operate this usb device
        manager.requestPermission(device, usbPermissionIntent);
        // System.out.println(manager.hasPermission(this.device));
      }
      manager.requestPermission(device, usbPermissionIntent);
      // context.registerReceiver(usbReceiver, filter);
    }
  } catch (NullPointerException npe) {
    rejectConnectionPromise("E110", "No USB devices found");
  }
}
  private void rejectConnectionPromise(String code, String message) {
  Log.e(TAG, message);

}
  private final BroadcastReceiver mUsbPermissionActionReceiver = new BroadcastReceiver() {
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
    if (ACTION_USB_PERMISSION.equals(action)) {
      synchronized(this) {
          UsbDevice usbDevice = (UsbDevice) intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
        if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
          if (null != usbDevice) {

            afterGetPermission(usbDevice);
          }
        } else {
          Toast.makeText(context, String.valueOf("Permission denied for device"),
            Toast.LENGTH_SHORT).show();
        }
      }
    }
  }
};
  public void afterGetPermission(UsbDevice usbDevice) {

  getDeviceInterface();
  if (interface1 != null) {
    assignEndpoint();
  }

  getUsbConnection();

  communicate();
}
  public void assignEndpoint() {
  for (int i = 0; i < interface1.getEndpointCount(); i++) {
      UsbEndpoint ep = interface1.getEndpoint(i);
    Log.e(TAG, "---------------");
    // Log.e(TAG, (String) ep.getType());
    // Log.e(TAG, (String) ep.getDirection());
    // look for bulk endpoint
    if (ep.getType() == UsbConstants.USB_ENDPOINT_XFER_BULK) {
      if (ep.getDirection() == UsbConstants.USB_DIR_OUT) {
        epBulkOut = ep;
        Log.e(TAG, "111Find the BulkEndpointOut," + "index:" + i + "," + "使用端点号："
          + epBulkOut.getEndpointNumber());
      } else {
        epBulkIn = ep;
        Log.e(TAG, "111Find the BulkEndpointIn:" + "index:" + i + "," + "使用端点号："
          + epBulkIn.getEndpointNumber());
      }
    }
    // look for contorl endpoint
    if (ep.getType() == UsbConstants.USB_ENDPOINT_XFER_CONTROL) {
      epControl = ep;
      Log.e(TAG, "222find the ControlEndPoint:" + "index:" + i + "," + epControl.getEndpointNumber());
    }
    // look for interrupte endpoint
    if (ep.getType() == UsbConstants.USB_ENDPOINT_XFER_INT) {
      if (ep.getDirection() == UsbConstants.USB_DIR_OUT) {
        epIntEndpointOut = ep;
        Log.e(TAG, "333find the InterruptEndpointOut:" + "index:" + i + ","
          + epIntEndpointOut.getEndpointNumber());
      }
      if (ep.getDirection() == UsbConstants.USB_DIR_IN) {
        epIntEndpointIn = ep;
        Log.e(TAG, "333find the InterruptEndpointIn:" + "index:" + i + ","
          + epIntEndpointIn.getEndpointNumber());
      }
    }
  }
  if (epBulkOut == null && epBulkIn == null && epControl == null && epIntEndpointOut == null
    && epIntEndpointIn == null) {
    throw new IllegalArgumentException("not endpoint is founded!");
  }
}
  public void getUsbConnection() {
  Log.e(TAG, "openDevice1");
  if (interface1 != null) {
    Log.e(TAG, "openDevice2");
      UsbDeviceConnection conn = null;
    // 在open前判断是否有连接权限；对于连接权限可以静态分配，也可以动态分配权限
    if (manager.hasPermission(this.device)) {
      Log.e(TAG, "openDevice31");
      conn = manager.openDevice(this.device);
    }
    Log.e(TAG, "openDevice32");

    if (conn == null) {
      return;
    }
    Log.e(TAG, "openDevice4");

    if (conn.claimInterface(interface1, true)) {
      connection = conn;
      if (connection != null) // 到此你的android设备已经连上zigbee设备
        Log.e(TAG, "open设备成功！");



      // final String mySerial = connection.getSerial();
      // Log.e(TAG, "设备serial number：" + mySerial);
    } else {
      Log.e(TAG, "无法打开连接通道。");
      conn.close();
    }
  }
}

  public void getDeviceInterface() {
  if (this.device != null) {
    Log.e(TAG, "interfaceCounts : " + this.device.getInterfaceCount());
    for (int i = 0; i < this.device.getInterfaceCount(); i++) {
        UsbInterface intf = this.device.getInterface(i);

      if (i == 0) {
        interface1 = intf;
        // 保存设备接口
        // Log.e(TAG, "成功获得设备接口1:" + intf.getId());
      }
      if (i == 1) {
        interface2 = intf;
        Log.e(TAG, "成功获得设备接口2:" + intf.getId());
        System.out.println("成功获得设备接口1");
      }
    }
  } else {
    Log.e(TAG, "设备为空！");
  }
}
  public static byte[] hexStr2Bytes(String src) {
  /* ������ֵ���й淶������ */
  src = src.trim().replace(" ", "").toUpperCase(Locale.US);
		// ����ֵ��ʼ��
		int m = 0, n = 0;
		int iLen = src.length() / 2; // ���㳤��
  byte[] ret = new byte[iLen]; // ����洢�ռ�

  for (int i = 0; i < iLen; i++) {
    m = i * 2 + 1;
    n = m + 1;
    ret[i] = (byte)(Integer.decode("0x" + src.substring(i * 2, m) + src.substring(m, n)) & 0xFF);
  }
  return ret;
}
  public void communicate() {
    String string = "FE 0D 01 04 01 00 00 00 00 00 00 00 00 00 00 C1";
  byte[] bytes = hexStr2Bytes(string);

  connection.bulkTransfer(epIntEndpointOut, bytes, bytes.length, TIMEOUT);

  if (task != null) {
    task.cancel();
  }
  task = new TimerTask() {

    @Override
    public void run() {

      byte[] byte2 = new byte[16];
        // 发送与接收字节数与设备outputreport有关 // 读取数据1 两种方法读取数据 int ret =
        int response = connection.bulkTransfer(epIntEndpointIn, byte2, byte2.length,
        TIMEOUT);

        // System.out.println(response);
        String datastr = bytesToHexString(byte2);
        // System.out.println(datastr);

        String mess = byte2HexStr(byte2, byte2.length);
      // System.out.println(mess);
      // sendEventToStream(mess);
      // channel.invokeMethod("onUsbData", mess);
      handler.post(
        new Runnable() {
            @Override
        public void run() {
        // eventSink.success(data);
        channel.invokeMethod("onUsbData", mess);
      }
          }
        );

    // reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("usbData", mess);
  }
};

timer = new Timer();
timer.schedule(task, 0, 20);
  }
     //推送消息给Event数据流，flutter层负责监听数据流
     private Handler handler = new Handler(Looper.getMainLooper());
  public void sendEventToStream(String data) {
  handler.post(
    new Runnable() {
        @Override
    public void run() {
    // eventSink.success(data);
    channel.invokeMethod("onUsbData", data);
  }
      });
if (eventSink != null) {
  // eventSink.success(data);
  // Handler(Looper.getMainLooper()).post((){
  //   eventSink.success(data);
  // })

} 
  }
//   sendEventToStream(data: String) {
//     Handler(Looper.getMainLooper()).post {
//         eventSink?.success(data)
//     }
// }
  public static String bytesToHexString(byte[] data) {
    StringBuffer sb = new StringBuffer(data.length);
  for (int i = 0; i < data.length; i++) {
      String str = Integer.toHexString(0xFF & data[i]);
    if (str.length() < 2)
      sb.append(0);
    sb.append(str.toUpperCase());
  }
  return sb.toString();
}

  public static String byte2HexStr(byte[] b, int iLen) {
    StringBuilder sb = new StringBuilder();
  for (int n = 0; n < iLen; n++) {
    sb.append(mChars[(b[n] & 0xFF) >> 4]);
    sb.append(mChars[b[n] & 0x0F]);
    sb.append(' ');
  }
  return sb.toString().trim().toUpperCase(Locale.US);
}

  private void sleep(int milliseconds) {
  try {
    Thread.sleep(milliseconds);
  } catch (InterruptedException ie) {
    ie.printStackTrace();
  }
}



}
