package com.kumulos.reactnative;

import android.content.Context;
import android.net.Uri;
import android.content.Intent;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.kumulos.android.PushBroadcastReceiver;
import com.kumulos.android.PushMessage;
import com.kumulos.android.PushActionHandlerInterface;

import org.json.JSONObject;

public class PushReceiver extends PushBroadcastReceiver {

    @Override
    protected void onPushReceived(Context context, PushMessage pushMessage) {
        super.onPushReceived(context, pushMessage);

        if (null == KumulosReactNative.sharedReactContext) {
            return;
        }

        KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit("kumulos.push.received", pushToMap(pushMessage, null));
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
            .emit("kumulos.push.opened", pushToMap(pushMessage, null));
    }

    static WritableMap pushToMap(PushMessage push, String actionId) {
        WritableMap map = new WritableNativeMap();
        Uri url = push.getUrl();

        if (null != actionId) {
            map.putString("actionId", actionId);
        }

        map.putInt("id", push.getId());
        map.putString("title", push.getTitle());
        map.putString("message", push.getMessage());
        map.putString("dataJson", push.getData().toString());
        map.putString("url", url != null ? url.toString() : null);

        return map;
    }

    static class PushActionHandler implements PushActionHandlerInterface {
        @Override
        public void handle(Context context, PushMessage pushMessage, String actionId) {
            if (null == KumulosReactNative.sharedReactContext) {
                KumulosReactNative.coldStartPush = pushMessage;
                KumulosReactNative.coldStartActionId = actionId;
                return;
            }

            KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("kumulos.push.opened", pushToMap(pushMessage, actionId));

            Intent it = new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
            context.sendBroadcast(it);
        }
    }
}
