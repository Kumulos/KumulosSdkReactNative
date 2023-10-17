import { BeaconType, KumulosEvent } from './consts';
import {
    DeviceEventEmitter,
    NativeEventEmitter,
    NativeModules,
    Platform
} from 'react-native';
import { empty, nullOrUndefined } from './utils';

import KumulosClient from './client';
import { PushSubscriptionManager } from './push-channels';

let initialized = false;
let clientInstance = null;

const kumulosEmitter = new NativeEventEmitter(NativeModules.kumulos);

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

        if (config.deepLinkHandler) {
            Platform.select({
                ios: () => {
                    kumulosEmitter.addListener(
                        'kumulos.links.deepLinkPressed',
                        event => {
                            config.deepLinkHandler(event.resolution, event.link, event.linkData);
                        }
                    );
                },
                android: () => {
                    DeviceEventEmitter.addListener(
                        'kumulos.links.deepLinkPressed',
                        event => {
                            if (event.linkData !== null){
                                event.linkData.data = JSON.parse(event.linkData.data);
                            }
                            config.deepLinkHandler(event.resolution, event.link, event.linkData);
                        }
                    );
                }
            })();
        }

        if (Platform.OS === 'android'){
            NativeModules.kumulos.jsListenersRegistered();
        }

        if (empty(config.apiKey) || empty(config.secretKey)) {
            throw 'API key and secret key are required options!';
        }

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

    static pushRequestDeviceToken() {
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
    static _androidInboxEventSubscription = null;
    static _iosInboxEventSubscription = null;

    static updateConsentForUser(consented) {
        NativeModules.kumulos.inAppUpdateConsentForUser(consented);
    }

    static async getInboxItems() {
        return NativeModules.kumulos.inAppGetInboxItems()
            .then((items) => {
                const parsedItems = items.map((item) => {
                    if (item.dataJson){
                        item.data = JSON.parse(item.dataJson);
                        delete item.dataJson;
                    }
                    return item;
                });

                return parsedItems;
            });
    }

    static async presentInboxMessage(inboxItem) {
        return NativeModules.kumulos.inAppPresentItemWithId(inboxItem.id);
    }

    static async deleteMessageFromInbox(inboxItem) {
        return NativeModules.kumulos.deleteMessageFromInbox(inboxItem.id);
    }

    static async markAsRead(inboxItem) {
        return NativeModules.kumulos.markAsRead(inboxItem.id);
    }

    static async markAllInboxItemsAsRead() {
        return NativeModules.kumulos.markAllInboxItemsAsRead();
    }

    static async getInboxSummary() {
        return NativeModules.kumulos.getInboxSummary();
    }

    static setOnInboxUpdatedHandler(handler) {
        if (handler === null){
            if (KumulosInApp._androidInboxEventSubscription !== null){
                KumulosInApp._androidInboxEventSubscription.remove();
                KumulosInApp._androidInboxEventSubscription = null;
            }

            if (KumulosInApp._iosInboxEventSubscription !== null){
                KumulosInApp._iosInboxEventSubscription.remove();
                KumulosInApp._iosInboxEventSubscription = null;
            }
            return;
        }

        Platform.select({
            ios: () => {
                KumulosInApp._iosInboxEventSubscription = kumulosEmitter.addListener(
                    'kumulos.inApp.inbox.updated',
                    handler
                );
            },
            android: () => {
                KumulosInApp._androidInboxEventSubscription = DeviceEventEmitter.addListener(
                    'kumulos.inApp.inbox.updated',
                    handler
                );
            }
        })();
    }
}

export class DeepLinkResolution {
    static LookupFailed = "LOOKUP_FAILED";
    static LinkNotFound = "LINK_NOT_FOUND";
    static LinkExpired = "LINK_EXPIRED";
    static LinkLimitExceeded = "LINK_LIMIT_EXCEEDED";
    static LinkMatched = "LINK_MATCHED";
}