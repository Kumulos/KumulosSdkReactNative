package com.kumulos.reactnative;

import android.content.Context;
import android.net.Uri;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.kumulos.android.PushBroadcastReceiver;
import com.kumulos.android.PushMessage;

import org.json.JSONObject;

public class PushReceiver extends PushBroadcastReceiver {

    @Override
    protected void onPushReceived(Context context, PushMessage pushMessage) {
        super.onPushReceived(context, pushMessage);

        if (null == KumulosReactNative.sharedReactContext) {
            return;
        }

        KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("kumulos.push.received", pushToMap(pushMessage));
    }

    @Override
    protected void onPushOpened(Context context, PushMessage pushMessage) {
        super.onPushOpened(context, pushMessage);

        JSONObject deepLink = pushMessage.getData().optJSONObject("k.deepLink");
        if (null != deepLink) {
            return;
        }

        if (null == KumulosReactNative.sharedReactContext) {
            KumulosReactNative.coldStartPush = pushMessage;
            return;
        }

        KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("kumulos.push.opened", pushToMap(pushMessage));
    }

    static WritableMap pushToMap(PushMessage push) {
        WritableMap map = new WritableNativeMap();
        Uri url = push.getUrl();

        String pictureUrl = pushMessage.getPictureUrl();
        if (pictureUrl != null){
            message.put("pictureUrl", pictureUrl);
        }

        map.putInt("id", push.getId());
        map.putString("title", push.getTitle());
        map.putString("message", push.getMessage());
        map.putString("dataJson", push.getData().toString());
        map.putString("url", url != null ? url.toString() : null);
        map.putString("actionId", push.)

        return map;
    }
}
