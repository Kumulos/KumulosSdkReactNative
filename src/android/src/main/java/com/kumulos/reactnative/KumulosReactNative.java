
package com.kumulos.reactnative;

import android.app.Application;
import android.content.Context;
import android.location.Location;
import android.net.Uri;
import android.util.Log;
import android.util.Pair;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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
import com.kumulos.android.DeferredDeepLinkHelper.DeepLink;
import com.kumulos.android.DeferredDeepLinkHelper.DeepLinkResolution;
import com.kumulos.android.InAppDeepLinkHandlerInterface;
import com.kumulos.android.InAppInboxItem;
import com.kumulos.android.InAppInboxSummary;
import com.kumulos.android.Installation;
import com.kumulos.android.Kumulos;
import com.kumulos.android.KumulosConfig;
import com.kumulos.android.KumulosInApp;
import com.kumulos.android.PushMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import java.util.concurrent.atomic.AtomicBoolean;

public class KumulosReactNative extends ReactContextBaseJavaModule {

    @Nullable
    static ReactContext sharedReactContext;

    private static final int SDK_TYPE = 9;
    private static final String SDK_VERSION = "6.2.0";
    private static final int RUNTIME_TYPE = 7;
    private static final int PUSH_TOKEN_TYPE = 2;
    private static final String EVENT_TYPE_PUSH_DEVICE_REGISTERED = "k.push.deviceRegistered";

    private static final AtomicBoolean jsListenersRegistered = new AtomicBoolean(false);
    private static final List<Pair<String,Object>> jsEmitQueue = new ArrayList<>(1);

    private static final AtomicBoolean initialized = new AtomicBoolean(false);

    public KumulosReactNative(ReactApplicationContext reactContext) {
        super(reactContext);
        sharedReactContext = reactContext;
    }

    @Override
    public void initialize() {
        super.initialize();
        initialized.set(true);
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        initialized.set(false);
    }

    public static void initialize(Application application, KumulosConfig.Builder config) {
        KumulosInApp.setDeepLinkHandler(new InAppDeepLinkHandler());
        KumulosInApp.setOnInboxUpdated(new InboxUpdatedHandler());
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

    @Override
    @NonNull
    public String getName() {
        return "kumulos";
    }

    @ReactMethod
    public void getInstallId(Promise promise) {
        String installId = Installation.id(getReactApplicationContext());
        promise.resolve(installId);
    }

    @ReactMethod
    public void getCurrentUserIdentifier(Promise promise) {
        String userId = Kumulos.getCurrentUserIdentifier(getReactApplicationContext());
        promise.resolve(userId);
    }

    @ReactMethod
    public void clearUserAssociation() {
        Kumulos.clearUserAssociation(getReactApplicationContext());
    }

    @ReactMethod
    public void trackEvent(String eventType, @Nullable ReadableMap properties, Boolean flushImmediately) {

        JSONObject props = null;

        if (null != properties) {
            props = new JSONObject(properties.toHashMap());
        }

        if (flushImmediately) {
            Kumulos.trackEventImmediately(getReactApplicationContext(), eventType, props);
        }
        else {
            Kumulos.trackEvent(getReactApplicationContext(), eventType, props);
        }
    }

    @ReactMethod
    public void sendLocationUpdate(Double lat, Double lng) {
        Location location = new Location("");
        location.setLatitude(lat);
        location.setLongitude(lng);

        Kumulos.sendLocationUpdate(getReactApplicationContext(), location);
    }

    @ReactMethod
    public void associateUserWithInstall(String userIdentifier, @Nullable ReadableMap attributes) {
        if (null != attributes) {
            JSONObject attrs = new JSONObject(attributes.toHashMap());
            Kumulos.associateUserWithInstall(getReactApplicationContext(), userIdentifier, attrs);
        }
        else {
            Kumulos.associateUserWithInstall(getReactApplicationContext(), userIdentifier);
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

        Kumulos.trackEventImmediately(getReactApplicationContext(), EVENT_TYPE_PUSH_DEVICE_REGISTERED, props);
    }

    @ReactMethod
    public void pushRequestDeviceToken() {
        Kumulos.pushRegister(getReactApplicationContext());
    }

    @ReactMethod
    public void pushUnregister() {
        Kumulos.pushUnregister(getReactApplicationContext());
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

        List<InAppInboxItem> inboxItems = KumulosInApp.getInboxItems(getReactApplicationContext());
        WritableArray results = new WritableNativeArray();
        for (InAppInboxItem item : inboxItems) {
            WritableMap mapped = new WritableNativeMap();
            mapped.putInt("id", item.getId());
            mapped.putString("title", item.getTitle());
            mapped.putString("subtitle", item.getSubtitle());
            mapped.putBoolean("isRead", item.isRead());
            mapped.putString("sentAt", formatter.format(item.getSentAt()));

            Date availableFrom = item.getAvailableFrom();
            Date availableTo = item.getAvailableTo();
            Date dismissedAt = item.getDismissedAt();
            JSONObject data = item.getData();
            URL imageUrl = item.getImageUrl();

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

            if (data == null){
                mapped.putNull("data");
            }
            else{
                mapped.putString("dataJson", data.toString());
            }

            if (imageUrl == null){
                mapped.putNull("imageUrl");
            }
            else{
                mapped.putString("imageUrl", imageUrl.toString());
            }

            results.pushMap(mapped);
        }

        promise.resolve(results);
    }

    @ReactMethod
    public void inAppPresentItemWithId(Integer partId, Promise promise) {
        ReactApplicationContext ctx = getReactApplicationContext();

        List<InAppInboxItem> items = KumulosInApp.getInboxItems(ctx);
        for (InAppInboxItem item : items) {
            if (partId == item.getId()) {
                KumulosInApp.InboxMessagePresentationResult result = KumulosInApp.presentInboxMessage(ctx, item);

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
        ReactApplicationContext ctx = getReactApplicationContext();

        List<InAppInboxItem> items = KumulosInApp.getInboxItems(ctx);
        for (InAppInboxItem item : items) {
            if (id == item.getId()) {
                boolean result = KumulosInApp.deleteMessageFromInbox(ctx, item);
                if (result){
                    promise.resolve(null);
                }
                else{
                    promise.reject("0", "Failed to delete message");
                }

                return;
            }
        }

        promise.reject("0", "Message not found");
    }

    @ReactMethod
    public void markAsRead(Integer id, Promise promise) {
        ReactApplicationContext ctx = getReactApplicationContext();

        List<InAppInboxItem> items = KumulosInApp.getInboxItems(ctx);
        for (InAppInboxItem item : items) {
            if (id == item.getId()) {
                boolean result = KumulosInApp.markAsRead(ctx, item);
                if (result){
                    promise.resolve(null);
                }
                else{
                    promise.reject("0", "Failed to mark message as read");
                }

                return;
            }
        }

        promise.reject("0", "Message not found");
    }

    @ReactMethod
    public void markAllInboxItemsAsRead(Promise promise) {
        boolean result = KumulosInApp.markAllInboxItemsAsRead(getReactApplicationContext());
        if (result){
            promise.resolve(null);
        }
        else{
            promise.reject("0", "Failed to mark all messages as read");
        }
    }

    @ReactMethod
    public void getInboxSummary(Promise promise) {
        KumulosInApp.getInboxSummaryAsync(getReactApplicationContext(), (InAppInboxSummary summary) -> {
            if (summary == null){
                promise.reject("0", "Could not get inbox summary");

                return;
            }

            WritableMap mapped = new WritableNativeMap();
            mapped.putInt("totalCount", summary.getTotalCount());
            mapped.putInt("unreadCount", summary.getUnreadCount());

            promise.resolve(mapped);
        });
    }

    private static class InboxUpdatedHandler implements KumulosInApp.InAppInboxUpdatedHandler {
        @Override
        public void run() {
            maybeEmit("kumulos.inApp.inbox.updated", null);
        }
    }

    private static class InAppDeepLinkHandler implements InAppDeepLinkHandlerInterface {
        @Override
        public void handle(Context context, JSONObject data) {
            maybeEmit("kumulos.inApp.deepLinkPressed", data.toString());
        }
    }

    @ReactMethod
    public void jsListenersRegistered() {
        if (KumulosReactNative.jsListenersRegistered.get()) {
            return;
        }

        //By the time JS land sends registered event, we assume sharedReactContext and eventListener are initialized
        if (null == KumulosReactNative.sharedReactContext || initialized.get() == false) {
            Log.e("KumulosReacNative", "sharedReactContext not initialized");
            KumulosReactNative.jsListenersRegistered.set(true);
            return;
        }

        synchronized (jsEmitQueue) {
            for (Pair<String, Object> e : jsEmitQueue) {
                emit(e.first, e.second);
            }
            jsEmitQueue.clear();
        }

        KumulosReactNative.jsListenersRegistered.set(true);
    }

    static void emitOrCachePushOpen(PushMessage message, String actionId){
        jsQueuedEmit("kumulos.push.opened", pushToMap(message, actionId));
    }

    static void emitPushReceived(PushMessage message){
        maybeEmit("kumulos.push.received", pushToMap(message, null));
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

                    assert data != null;
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

            jsQueuedEmit("kumulos.links.deepLinkPressed", params);
        }
    }

    private static void maybeEmit(@NonNull String eventType, @Nullable Object data) {
        if (initialized.get() == false || sharedReactContext == null) {
            return;
        }

        emit(eventType, data);
    }

    private static void emit(@NonNull String eventType, @Nullable Object data) {
        assert KumulosReactNative.sharedReactContext != null;
        KumulosReactNative.sharedReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventType, data);
    }

    private static void jsQueuedEmit(@NonNull String eventType, @Nullable Object data) {
        if (jsListenersRegistered.get() == false || null == sharedReactContext || initialized.get() == false) {
            synchronized (jsEmitQueue) {
                jsEmitQueue.add(new Pair<>(eventType, data));
            }
            return;
        }

        emit(eventType, data);
    }
}