package com.kumulos.reactnative;

import android.content.Context;
import android.content.Intent;
import android.content.ComponentName;
import android.app.Activity;
import android.os.Build;
import android.app.TaskStackBuilder;

import com.kumulos.android.Kumulos;
import com.kumulos.android.PushBroadcastReceiver;
import com.kumulos.android.PushMessage;
import com.kumulos.android.PushActionHandlerInterface;

import org.json.JSONObject;

public class PushReceiver extends PushBroadcastReceiver {

    @Override
    protected void onPushReceived(Context context, PushMessage pushMessage) {
        super.onPushReceived(context, pushMessage);

        KumulosReactNative.emitPushReceived(pushMessage);
    }

    @Override
    protected void onPushOpened(Context context, PushMessage pushMessage) {
        try {
            Kumulos.pushTrackOpen(context, pushMessage.getId());
        } catch (Kumulos.UninitializedException e) {
            /* Noop */
        }

        Intent launchIntent = getPushOpenActivityIntent(context, pushMessage);
        if (null == launchIntent) {
            return;
        }

        ComponentName component = launchIntent.getComponent();
        if (null == component) {
            return;
        }

        Class<? extends Activity> cls = null;
        try {
            cls = Class.forName(component.getClassName()).asSubclass(Activity.class);
        } catch (ClassNotFoundException e) {
            /* Noop */
        }

        // Ensure we're trying to launch an Activity
        if (null == cls) {
            return;
        }

        if (null != pushMessage.getUrl()) {
            launchIntent = new Intent(Intent.ACTION_VIEW, pushMessage.getUrl());
        }

        launchIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        addDeepLinkExtras(pushMessage, launchIntent);

        Activity currentActivity = KumulosReactNative.getActivity();
        if (currentActivity != null){
            Intent existingIntent = currentActivity.getIntent();
            addDeepLinkExtras(pushMessage, existingIntent);
        }

        context.startActivity(launchIntent);

        JSONObject deepLink = pushMessage.getData().optJSONObject("k.deepLink");
        if (null != deepLink) {
            return;
        }

        KumulosReactNative.emitOrCachePushOpen(pushMessage, null);
    }

    static class PushActionHandler implements PushActionHandlerInterface {
        @Override
        public void handle(Context context, PushMessage pushMessage, String actionId) {
            Intent it = new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
            context.sendBroadcast(it);

            this.launchActivity(context, pushMessage);

            KumulosReactNative.emitOrCachePushOpen(pushMessage, actionId);
        }

        private void launchActivity(Context context, PushMessage pushMessage){
            PushReceiver pr = new PushReceiver();
            Intent launchIntent = pr.getPushOpenActivityIntent(context, pushMessage);

            if (null == launchIntent) {
                return;
            }
            ComponentName component = launchIntent.getComponent();
            if (null == component) {
                return;
            }
            Class<? extends Activity> cls = null;
            try {
                cls = (Class<? extends Activity>) Class.forName(component.getClassName());
            } catch (ClassNotFoundException e) {
                /* Noop */
            }

            if (null == cls) {
                return;
            }

            addDeepLinkExtras(pushMessage, launchIntent);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                TaskStackBuilder taskStackBuilder = TaskStackBuilder.create(context);
                taskStackBuilder.addParentStack(component);
                taskStackBuilder.addNextIntent(launchIntent);

                taskStackBuilder.startActivities();
                return;
            }

            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

            context.startActivity(launchIntent);
        }
    }
}
