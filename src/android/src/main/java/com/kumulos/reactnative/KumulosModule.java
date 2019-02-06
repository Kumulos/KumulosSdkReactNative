
package com.kumulos.reactnative;

import android.app.Activity;
import android.app.Application;
import android.location.Location;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.kumulos.android.Installation;
import com.kumulos.android.Kumulos;
import com.kumulos.android.KumulosConfig;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

public class KumulosModule extends ReactContextBaseJavaModule {

    private static final int PUSH_TOKEN_TYPE = 2;
    private static final String EVENT_TYPE_PUSH_DEVICE_REGISTERED = "k.push.deviceRegistered";

    private final ReactApplicationContext reactContext;

    public KumulosModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "kumulos";
    }

    @ReactMethod
    public void initBaseSdk(ReadableMap config) {
        String apiKey = config.getString("apiKey");
        String secretKey = config.getString("secretKey");

        boolean enableCrashReporting = (1 == config.getInt("enableCrashReporting"));


        KumulosConfig.Builder configBuilder = new KumulosConfig.Builder(apiKey, secretKey);

        if (enableCrashReporting) {
            configBuilder.enableCrashReporting();
        }

        Application application;
        Activity activity = reactContext.getCurrentActivity();

        if (null != activity) {
            application = activity.getApplication();
        } else {
            application = (Application) reactContext.getApplicationContext();
        }

        HashMap<String,Object> sdkInfo = config.getMap("sdkInfo").toHashMap();
        configBuilder.setRuntimeInfo(new JSONObject(sdkInfo));

        HashMap<String,Object> runtimeInfo = config.getMap("runtimeInfo").toHashMap();
        configBuilder.setRuntimeInfo(new JSONObject(runtimeInfo));

        Kumulos.initialize(application, configBuilder.build());
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

}
