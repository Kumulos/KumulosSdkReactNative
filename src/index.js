import { BeaconType, KumulosEvent, PUSH_BASE_URL, RuntimeInfo, SdkInfo } from './consts';
import { empty, makeAuthedJsonCall, nullOrUndefined } from './utils';

import KumulosClient from './client';
import { NativeModules } from 'react-native';
import { PushSubscriptionManager } from './push-channels';

let initialized = false;
let clientInstance = null;

export default class Kumulos {

    static initialize(config) {
        if (initialized) {
            console.error('Kumulos.initialize has already been called, aborting...');
            return;
        }

        if (empty(config.apiKey) || empty(config.secretKey)) {
            throw 'API key and secret key are required options!';
        }

        const enableCrashReporting = nullOrUndefined(config.enableCrashReporting)
            ? 0
            : Number(config.enableCrashReporting);

        const nativeConfig = {
            apiKey: config.apiKey,
            secretKey: config.secretKey,
            enableCrashReporting,
            sdkInfo: SdkInfo,
            runtimeInfo: RuntimeInfo
        };

        NativeModules.kumulos.initBaseSdk(nativeConfig);

        Kumulos.trackEvent(KumulosEvent.AppForegrounded);

        clientInstance = new KumulosClient(config);

        initialized = true;
    }

    static getInstallId() {
        return clientInstance.getInstallId();
    }

    static call(method, params = {}) {
        return clientInstance.call(method, params);
    }

    static getPushSubscriptionManager() {
        return new PushSubscriptionManager(clientInstance);
    }

    static async pushRemoveToken() {
        let installId = null;
        try {
            installId = await this.getInstallId();
        }
        catch (e) {
            console.error('couldnt get installId');
            return;
        }

        const url = `${PUSH_BASE_URL}/v1/app-installs/${installId}/push-token`;

        return makeAuthedJsonCall(this, 'DELETE', url);
    }

    static pushStoreToken(token) {
        NativeModules.kumulos.pushStoreToken(token);
    }

    static pushTrackOpen(notificationId) {
        Kumulos.trackEvent(KumulosEvent.PushTrackOpen, {
            id: notificationId
        });
    }

    static trackEvent(eventType, properties = null) {
        NativeModules.kumulos.trackEvent(eventType, properties, false);
    }

    static trackEventImmediately(eventType, properties = null) {
        NativeModules.kumulos.trackEvent(eventType, properties, true);
    }

    static sendLocationUpdate(lat, lng) {
        NativeModules.kumulos.sendLocationUpdate(lat, lng);
    }

    static associateUserWithInstall(userIdentifier, attributes = null) {
        NativeModules.kumulos.associateUserWithInstall(userIdentifier, attributes);
    }

    static trackEddystoneBeaconProximity(namespaceHex, instanceHex, distanceMetres = null) {
        let payload = {
            type: BeaconType.Eddystone,
            namespaceHex,
            instanceHex
        };

        if (!nullOrUndefined(distanceMetres)) {
            payload.distanceMetres = distanceMetres;
        }

        Kumulos.trackEventImmediately(KumulosEvent.EngageBeaconEnteredProximity, payload);
    }

    static trackiBeaconProximity(uuid, major, minor, proximity = null) {
        let payload = {
            type: BeaconType.iBeacon,
            uuid,
            major,
            minor
        };

        if (!nullOrUndefined(proximity)) {
            payload.proximity = proximity;
        }

        Kumulos.trackEventImmediately(KumulosEvent.EngageBeaconEnteredProximity, payload);
    }

}
