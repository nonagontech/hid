package com.rniox;

public class ActionConstants {

	// ---------------蓝牙服务广播
	public final static String ACTION_GATT_CONNECTED = "com.xy.oximeter.service.ACTION_GATT_CONNECTED";
	public final static String ACTION_GATT_CONNECTING = "com.xy.oximeter.service.ACTION_GATT_CONNECTING";
	public final static String ACTION_GATT_DISCONNECTED = "com.xy.oximeter.service.ACTION_GATT_DISCONNECTED";
	public final static String ACTION_GETSERVICE_FAILD = "com.xy.oximeter.service.ACTION_GETSERVICE_FAILD";
	public final static String ACTION_GATT_SERVICES_DISCOVERED = "com.xy.oximeter.service.ACTION_GATT_SERVICES_DISCOVERED";
	public final static String ACTION_DATA_AVAILABLE = "com.xy.oximeter.service.ACTION_DATA_AVAILABLE";
	public final static String ACTION_RSSI = "com.xy.oximeter.service.RSSI";

	public final static String DATA_KEY_EXTRA_DATA = "data.key.EXTRA_DATA";
	public final static String DATA_KEY_CHARACTERISTIC_UUID = "data.key.characteristic.UUID";
	// ---------------蓝牙服务广播

	// ---------------OTG数据广播

	public static final String ACTION_OTG_NONSUPPORT = "com.xy.oximeter.service.ACTION_OTG_NONSUPPORT";

	public static final String ACTION_OTG_NO_DEVICE = "com.xy.oximeter.service.ACTION_OTG_NO_DEVICE";

	public static final String ACTION_OTG_DATA = "com.xy.oximeter.service.ACTION_OTG_DATA";

	public static final String ACTION_OTG_UNAVAILABLE = "com.xy.oximeter.service.ACTION_OTG_AVAILABLE";

	public static final String ACTION_OTG_DISCONNECT = "com.xy.oximeter.service.ACTION_OTG_DISCONNECT";

	public static final String ACTION_OTG_CONNECT = "com.xy.oximeter.service.ACTION_OTG_CONNECT";
}
