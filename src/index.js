import { BeaconType, CrashReportFormat, KumulosEvent } from './consts';
import {
    DeviceEventEmitter,
    NativeEventEmitter,
    NativeModules,
    Platform
} from 'react-native';
import { empty, nullOrUndefined } from './utils';

import KumulosClient from './client';
import { PushSubscriptionManager } from './push-channels';
import Raven from 'raven-js';
import RavenReactNativePlugin from 'raven-js/plugins/react-native';

let initialized = false;
let clientInstance = null;
let currentConfig = null;

let ravenInstance = null;
let exceptionsDuringInit = [];

const kumulosEmitter = new NativeEventEmitter(NativeModules.kumulos);

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

        if (config.pushOpenedHandler) {
            Platform.select({
                ios: () => {
                    kumulosEmitter.addListener(
                        'kumulos.push.opened',
                        config.pushOpenedHandler
                    );
                },
                android: () => {
                    DeviceEventEmitter.addListener(
                        'kumulos.push.opened',
                        push => {
                            push.data = JSON.parse(push.dataJson);
                            delete push.dataJson;
                            config.pushOpenedHandler(push);
                        }
                    );
                }
            })();
        }

        if (config.pushReceivedHandler) {
            Platform.select({
                ios: () => {
                    kumulosEmitter.addListener(
                        'kumulos.push.received',
                        config.pushReceivedHandler
                    );
                },
                android: () => {
                    DeviceEventEmitter.addListener(
                        'kumulos.push.received',
                        push => {
                            push.data = JSON.parse(push.dataJson);
                            delete push.dataJson;
                            config.pushReceivedHandler(push);
                        }
                    );
                }
            })();
        }

        if (config.inAppDeepLinkHandler) {
            Platform.select({
                ios: () => {
                    kumulosEmitter.addListener(
                        'kumulos.inApp.deepLinkPressed',
                        config.inAppDeepLinkHandler
                    );
                },
                android: () => {
                    DeviceEventEmitter.addListener(
                        'kumulos.inApp.deepLinkPressed',
                        dataJson => {
                            const data = JSON.parse(dataJson);
                            config.inAppDeepLinkHandler(data);
                        }
                    );
                }
            })();
        }

        if (empty(config.apiKey) || empty(config.secretKey)) {
            throw 'API key and secret key are required options!';
        }

        const enableCrashReporting = nullOrUndefined(
            config.enableCrashReporting
        )
            ? 0
            : Number(config.enableCrashReporting);

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

    static pushRequestToken() {
        NativeModules.kumulos.pushRequestDeviceToken();
    }

    static pushRemoveToken() {
        NativeModules.kumulos.pushUnregister();
    }

    static pushStoreToken(token) {
        NativeModules.kumulos.pushStoreToken(token);
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

export class KumulosInApp {
    static updateConsentForUser(consented) {
        NativeModules.kumulos.inAppUpdateConsentForUser(consented);
    }

    static async getInboxItems() {
        return NativeModules.kumulos.inAppGetInboxItems();
    }

    static async presentInboxMessage(inboxItem) {
        return NativeModules.kumulos.inAppPresentItemWithId(inboxItem.id);
    }

    static async deleteMessageFromInbox(inboxItem) {
        return NativeModules.kumulos.deleteMessageFromInbox(inboxItem.id);
    }
}
