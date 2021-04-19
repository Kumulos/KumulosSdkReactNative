
package com.kumulos.reactnative;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.location.Location;
import android.net.Uri;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.modules.systeminfo.ReactNativeVersion;

import com.kumulos.android.DeferredDeepLinkHandlerInterface;
import com.kumulos.android.DeferredDeepLinkHelper.DeepLinkResolution;
import com.kumulos.android.DeferredDeepLinkHelper.DeepLink;
import com.kumulos.android.InAppDeepLinkHandlerInterface;
import com.kumulos.android.InAppInboxItem;
import com.kumulos.android.Installation;
import com.kumulos.android.Kumulos;
import com.kumulos.android.KumulosConfig;
import com.kumulos.android.KumulosInApp;
import com.kumulos.android.PushMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import androidx.annotation.Nullable;

public class KumulosReactNative extends ReactContextBaseJavaModule {

    static ReactContext sharedReactContext;
    private static WritableMap cachedPushOpen;

    private static final int SDK_TYPE = 9;
    private static final String SDK_VERSION = "5.4.1";
    private static final int RUNTIME_TYPE = 7;
    private static final int PUSH_TOKEN_TYPE = 2;
    private static final String EVENT_TYPE_PUSH_DEVICE_REGISTERED = "k.push.deviceRegistered";

    private final ReactApplicationContext reactContext;

    private static boolean jsListenersRegistered = false;
    private static WritableMap deepLinkCachedData = null;

    public static void initialize(Application application, KumulosConfig.Builder config) {
        KumulosInApp.setDeepLinkHandler(new InAppDeepLinkHandler());
        Kumulos.setPushActionHandler(new PushReceiver.PushActionHandler());

        JSONObject sdkInfo = new JSONObject();
        JSONObject runtimeInfo = new JSONObject();

        try {
            sdkInfo.put("id", SDK_TYPE);
            sdkInfo.put("version", SDK_VERSION);

            runtimeInfo.put("id", RUNTIME_TYPE);
            runtimeInfo.put("version", ReactNativeVersion.VERSION.get("major")
                    + "." + ReactNativeVersion.VERSION.get("minor")
                    + "." + ReactNativeVersion.VERSION.get("patch"));

        } catch (JSONException e) {
            e.printStackTrace();
        }

        config.setSdkInfo(sdkInfo);
        config.setRuntimeInfo(runtimeInfo);
        config.enableDeepLinking(new DeepLinkHandler());

        Kumulos.initialize(application, config.build());
    }

    public KumulosReactNative(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        sharedReactContext = reactContext;
    }

    @Override
    public String getName() {
        return "kumulos";
    }

    @ReactMethod
    public void getInstallId(Promise promise) {
        String installId = Installation.id(reactContext);
        promise.resolve(installId);
    }

    @ReactMethod
    public void getCurrentUserIdentifier(Promise promise) {
        String userId = Kumulos.getCurrentUserIdentifier(reactContext);
        promise.resolve(userId);
    }

    @ReactMethod
    public void clearUserAssociation() {
        Kumulos.clearUserAssociation(reactContext);
    }

    @ReactMethod
    public void trackEvent(String eventType, @Nullable ReadableMap properties, Boolean flushImmediately) {

        JSONObject props = null;

        if (null != properties) {
            props = new JSONObject(properties.toHashMap());
        }

        if (flushImmediately) {
            Kumulos.trackEventImmediately(reactContext, eventType, props);
        }
        else {
            Kumulos.trackEvent(reactContext, eventType, props);
        }
    }

    @ReactMethod
    public void sendLocationUpdate(Double lat, Double lng) {
        Location location = new Location("");
        location.setLatitude(lat);
        location.setLongitude(lng);

        Kumulos.sendLocationUpdate(reactContext, location);
    }

    @ReactMethod
    public void associateUserWithInstall(String userIdentifier, @Nullable ReadableMap attributes) {
        if (null != attributes) {
            JSONObject attrs = new JSONObject(attributes.toHashMap());
            Kumulos.associateUserWithInstall(reactContext, userIdentifier, attrs);
        }
        else {
            Kumulos.associateUserWithInstall(reactContext, userIdentifier);
        }
    }

    @ReactMethod
    public void pushStoreToken(String token) {
        JSONObject props = new JSONObject();

        try {
            props.put("token", token);
            props.put("type", PUSH_TOKEN_TYPE);
        } catch (JSONException e) {
            e.printStackTrace();
            return;
        }

        Kumulos.trackEventImmediately(reactContext, EVENT_TYPE_PUSH_DEVICE_REGISTERED, props);
    }

    @ReactMethod
    public void pushRequestDeviceToken() {
        Kumulos.pushRegister(reactContext);
    }

    @ReactMethod
    public void pushUnregister() {
        Kumulos.pushUnregister(reactContext);
    }

    @ReactMethod
    public void inAppUpdateConsentForUser(boolean consented) {
        KumulosInApp.updateConsentForUser(consented);
    }

    @ReactMethod
    public void inAppGetInboxItems(Promise promise) {
        SimpleDateFormat formatter;
        formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US);
        formatter.setTimeZone(TimeZone.getTimeZone("UTC"));

        List<InAppInboxItem> inboxItems = KumulosInApp.getInboxItems(reactContext);
        WritableArray results = new WritableNativeArray();
        for (InAppInboxItem item : inboxItems) {
            WritableMap mapped = new WritableNativeMap();
            mapped.putInt("id", item.getId());
            mapped.putString("title", item.getTitle());
            mapped.putString("subtitle", item.getSubtitle());

            Date availableFrom = item.getAvailableFrom();
            Date availableTo = item.getAvailableTo();
            Date dismissedAt = item.getDismissedAt();

            if (null == availableFrom) {
                mapped.putNull("availableFrom");
            } else {
                mapped.putString("availableFrom", formatter.format(availableFrom));
            }

            if (null == availableTo) {
                mapped.putNull("availableTo");
            } else {
                mapped.putString("availableTo", formatter.format(availableTo));
            }

            if (null == dismissedAt) {
                mapped.putNull("dismissedAt");
            } else {
                mapped.putString("dismissedAt", formatter.format(dismissedAt));
            }

            results.pushMap(mapped);
        }

        promise.resolve(results);
    }

    @ReactMethod
    public void inAppPresentItemWithId(Integer partId, Promise promise) {
        List<InAppInboxItem> items = KumulosInApp.getInboxItems(reactContext);
        for (InAppInboxItem item : items) {
            if (partId == item.getId()) {
                KumulosInApp.InboxMessagePresentationResult result = KumulosInApp.presentInboxMessage(reactContext, item);

                switch (result) {
                    case PRESENTED:
                        promise.resolve(null);
                        break;
                    case FAILED:
                    case FAILED_EXPIRED:
                        promise.reject("0", "Failed to present message");
                        break;
                }
                return;
            }
        }

        promise.reject("0", "Message not found");
    }

    @ReactMethod
    public void deleteMessageFromInbox(Integer id, Promise promise) {
        List<InAppInboxItem> items = KumulosInApp.getInboxItems(reactContext);
        for (InAppInboxItem item : items) {
            if (id == item.getId()) {
                Boolean result = KumulosInApp.deleteMessageFromInbox(reactContext, item);
                if (result){
                    promise.resolve(null);
                }
                else{
                    promise.reject("Failed to delete message");
                }

                return;
            }
        }

        promise.reject("0", "Message not found");
    }

    private static class InAppDeepLinkHandler implements InAppDeepLinkHandlerInterface {
        @Override
        public void handle(Context context, JSONObject data) {
            if (null == sharedReactContext) {
                return;
            }

            KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("kumulos.inApp.deepLinkPressed", data.toString());
        }
    }

    @ReactMethod
    public void jsListenersRegistered() {
        if (KumulosReactNative.jsListenersRegistered ||
            (KumulosReactNative.deepLinkCachedData == null && KumulosReactNative.cachedPushOpen == null)){

            KumulosReactNative.jsListenersRegistered = true;
            return;
        }

        //By the time JS land sends registered event, we assume sharedReactContext and eventListener are initialized
        if (null == KumulosReactNative.sharedReactContext) {
            Log.e("KumulosReacNative", "sharedReactContext not initialized");
            KumulosReactNative.jsListenersRegistered = true;
            return;
        }

        if (KumulosReactNative.deepLinkCachedData != null){
            KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                                .emit("kumulos.links.deepLinkPressed", KumulosReactNative.deepLinkCachedData);
        }

        if (cachedPushOpen != null){
            KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("kumulos.push.opened", cachedPushOpen);
        }

        KumulosReactNative.jsListenersRegistered = true;
        KumulosReactNative.cachedPushOpen = null;
        KumulosReactNative.deepLinkCachedData = null;
    }

    static void emitOrCachePushOpen(PushMessage message, String actionId){
        if (!jsListenersRegistered || null == sharedReactContext) {
            KumulosReactNative.cachedPushOpen = pushToMap(message, actionId);
            return;
        }

        KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("kumulos.push.opened", pushToMap(message, actionId));
    }

    static void emitPushReceived(PushMessage message){
        if (null == KumulosReactNative.sharedReactContext) {
            return;
        }

        KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("kumulos.push.received", pushToMap(message, null));
    }

    private static WritableMap pushToMap(PushMessage push, String actionId) {
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

    private static class DeepLinkHandler implements DeferredDeepLinkHandlerInterface {

        @Override
        public void handle(Context context, DeepLinkResolution resolution, String link, @Nullable DeepLink data) {
            WritableMap params = new WritableNativeMap();
            params.putString("link", link);

            String mappedResolution = null;
            WritableMap linkData = null;
            switch (resolution) {
                case LINK_MATCHED:
                    mappedResolution = "LINK_MATCHED";
                    linkData = new WritableNativeMap();

                    linkData.putString("url", data.url);

                    WritableMap content = new WritableNativeMap();
                    content.putString("title", data.content.title);
                    content.putString("description", data.content.description);
                    linkData.putMap("content", content);

                    linkData.putString("data", data.data.toString());
                    break;
                case LINK_NOT_FOUND:
                    mappedResolution = "LINK_NOT_FOUND";
                    break;
                case LINK_EXPIRED:
                    mappedResolution = "LINK_EXPIRED";
                    break;
                case LINK_LIMIT_EXCEEDED:
                    mappedResolution = "LINK_LIMIT_EXCEEDED";
                    break;
                case LOOKUP_FAILED:
                default:
                    mappedResolution = "LOOKUP_FAILED";
                    break;
            }

            params.putString("resolution", mappedResolution);
            params.putMap("linkData", linkData);

            if (!KumulosReactNative.jsListenersRegistered || sharedReactContext == null){
                KumulosReactNative.deepLinkCachedData = params;
                return;
            }
            KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit("kumulos.links.deepLinkPressed", params);
        }
    }
}
