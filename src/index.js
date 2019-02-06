import {
    BeaconType,
    CrashReportFormat,
    KumulosEvent,
    PUSH_BASE_URL,
    RuntimeInfo,
    SdkInfo
} from './consts';
import { empty, makeAuthedJsonCall, nullOrUndefined } from './utils';

import KumulosClient from './client';
import { NativeModules } from 'react-native';
import { PushSubscriptionManager } from './push-channels';
import Raven from 'raven-js';
import RavenReactNativePlugin from 'raven-js/plugins/react-native';

let initialized = false;
let clientInstance = null;
let currentConfig = null;

let ravenInstance = null;
let exceptionsDuringInit = [];

function logException(e, uncaught, context = undefined) {
    if (!initialized || !currentConfig.enableCrashReporting) {
        console.log(
            'Crash reporting has not been enabled, ignoring exception:'
        );
        console.error(e);
        return;
    }

    if (!ravenInstance) {
        exceptionsDuringInit.push([e, uncaught, context]);
        return;
    }

    ravenInstance.captureException(e, {
        uncaught,
        extra: context
    });
}

export default class Kumulos {
    static initialize(config) {
        if (initialized) {
            console.error(
                'Kumulos.initialize has already been called, aborting...'
            );
            return;
        }

        if (empty(config.apiKey) || empty(config.secretKey)) {
            throw 'API key and secret key are required options!';
        }

        const enableCrashReporting = nullOrUndefined(
            config.enableCrashReporting
        )
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
        currentConfig = config;

        if (enableCrashReporting) {
            RavenReactNativePlugin(Raven);

            const transport = report => {
                Kumulos.trackEvent(KumulosEvent.CrashLoggedException, {
                    format: CrashReportFormat,
                    report: report.data
                });

                report.onSuccess();
            };

            let ravenOpts = {
                transport
            };

            if (config.sourceMapTag) {
                ravenOpts.release = config.sourceMapTag;
            }

            ravenInstance = Raven.config(
                'https://nokey@crash.kumulos.com/raven',
                ravenOpts
            );

            ravenInstance.install();

            exceptionsDuringInit.forEach(args =>
                logException.apply(this, args)
            );
            exceptionsDuringInit = [];
        }

        initialized = true;
    }

    static getInstallId() {
        return clientInstance.getInstallId();
    }

    static logException(e, context = {}) {
        logException(e, false, context);
    }

    static logUncaughtException(e) {
        logException(e, true);
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
        } catch (e) {
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
        NativeModules.kumulos.associateUserWithInstall(
            userIdentifier,
            attributes
        );
    }

    static clearUserAssociation() {
        NativeModules.kumulos.clearUserAssociation();
    }

    static async getCurrentUserIdentifier() {
        return await NativeModules.kumulos.getCurrentUserIdentifier();
    }

    static trackEddystoneBeaconProximity(beacon) {
        let payload = {
            type: BeaconType.Eddystone,
            namespace: beacon.namespaceHex,
            instance: beacon.instanceHex
        };

        if (!nullOrUndefined(beacon.distanceMetres)) {
            payload.distanceMetres = beacon.distanceMetres;
        }

        Kumulos.trackEventImmediately(
            KumulosEvent.EngageBeaconEnteredProximity,
            payload
        );
    }

    static trackiBeaconProximity(beacon) {
        let payload = {
            type: BeaconType.iBeacon,
            uuid: beacon.uuid,
            major: beacon.major,
            minor: beacon.minor
        };

        if (!nullOrUndefined(beacon.proximity)) {
            payload.proximity = beacon.proximity;
        }

        Kumulos.trackEventImmediately(
            KumulosEvent.EngageBeaconEnteredProximity,
            payload
        );
    }
}
