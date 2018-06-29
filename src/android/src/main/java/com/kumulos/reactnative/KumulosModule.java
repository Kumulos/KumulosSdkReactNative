
package com.kumulos.reactnative;

import android.app.Activity;
import android.app.Application;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.kumulos.android.Kumulos;
import com.kumulos.android.KumulosConfig;

public class KumulosModule extends ReactContextBaseJavaModule {

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
    }
    else {
      application = (Application) reactContext.getApplicationContext();
    }

    Kumulos.initialize(application, configBuilder.build());
  }
}
