interface PushChannel {
    uuid: string;
    name?: string;
    subscribed: Boolean;
    meta?: any;
}

interface ChannelSpec {
    uuid: string;
    subscribe: boolean;
    meta?: any;
    name?: string;
    showInPortal?: boolean;
}

interface PushNotification {
    id: number;
    title: string | null;
    message: string | null;
    data: { [key: string]: any };
    url: string | null;
    actionId?: string;
}

enum DeepLinkResolution {
    LookupFailed = "LOOKUP_FAILED",
    LinkNotFound = "LINK_NOT_FOUND",
    LinkExpired = "LINK_EXPIRED",
    LinkLimitExceeded = "LINK_LIMIT_EXCEEDED",
    LinkMatched = "LINK_MATCHED"
}

interface PushChannelManager {
    /**
     * Subscribes to the channels given by unique ID
     *
     * Channels that don't exist will be created.
     */
    subscribe(uuids: string[]): Promise<Response>;
    /**
     * Unsubscribes from the channels given by unique ID
     */
    unsubscribe(uuids: string[]): Promise<Response>;
    /**
     * Sets the current installations channel subscriptions to those given by unique ID.
     *
     * Any other subscriptions will be removed.
     */
    setSubscriptions(uuids: string[]): Promise<Response>;
    /**
     * Clears all of the existing installation's channel subscriptions
     */
    clearSubscriptions(): Promise<Response>;
    /**
     * Lists the channels available to this installation along with subscription status
     */
    listChannels(): Promise<PushChannel[]>;
    /**
     * Creates a push channel and optionally subscribes the current installation.
     *
     * Name is optional, but required if showInPortal is true.
     */
    createChannel(channelSpec: ChannelSpec): Promise<PushChannel>;
}

interface KumulosConfig {
    apiKey: string;
    secretKey: string;
    /**
     * Turn crash reporting on (defaults to false)
     */
    enableCrashReporting?: boolean;
    /**
     * A version identifier for minified source maps you upload
     * used in JS error reporting source mapping
     */
    sourceMapTag?: string;
    /**
     * Called when a push notification is received and your app is in the foreground
     */
    pushReceivedHandler?: (notification: PushNotification) => void;
    /**
     * Called when a push notification has been tapped by the user. Use for deep linking.
     */
    pushOpenedHandler?: (notification: PushNotification) => void;
    /**
     * Called when a user taps a deep-link button from an in-app message. Handle the data payload as desired.
     */
    inAppDeepLinkHandler?: (data: { [key: string]: any }) => void;
     /**
     * Called when a user taps a deep-link which brings user to the app
     */
    deepLinkHandler?: (resolution: DeepLinkResolution, link: string, data: { [key: string]: any } | null) => void;
    /**
     * Called when inbox is updated. This includes message marked as read, message opened, deleted, added, evicted or other.
     */
    inboxUpdatedHandler?: () => void;
}

interface KumulosSdk {
    /**
     * Used to configure the Kumulos class. Only needs to be called once per process
     */
    initialize: (config: KumulosConfig) => void;

    /**
     * Get the Kumulos installation ID
     */
    getInstallId: () => Promise<string>;

    /**
     * Make an RPC call to a Backend API method
     */
    call: <T>(methodName: string, params?: {}) => Promise<T>;

    /**
     * Get the channel subscription manager
     */
    getPushSubscriptionManager: () => PushChannelManager;

    /**
     * Requests the native push token from the OS, asking the user for permission if needed.
     */
    pushRequestToken: () => void;

    /**
     * Unsubscribe from push by removing the token associated with this installation
     */
    pushRemoveToken: () => Promise<Response>;

    /**
     * Associates the given push token with this installation in Kumulos
     */
    pushStoreToken: (token: string) => void;

    /**
     * Tracks a conversion event for a given push notification ID
     */
    pushTrackOpen: (notificationId: string) => void;

    /**
     * Tracks a custom analytics event with Kumulos.
     *
     * Events are persisted locally and synced to the server in the background in batches.
     */
    trackEvent: (eventType: string, properties?: {}) => void;

    /**
     * Tracks a custom analytics event with Kumulos.
     *
     * After being recorded locally, all stored events will be flushed to the server.
     */
    trackEventImmediately: (eventType: string, properties?: {}) => void;

    /**
     * Logs an exception to the Kumulos Crash reporting service
     *
     * Use this method to record unexpected application state
     */
    logException: (e: any, context?: {}) => void;

    /**
     * Logs an uncaught exception to the Kumulos Crash reporting service
     *
     * Use this method to forward exceptions from other error handlers.
     */
    logUncaughtException: (e: any) => void;

    /**
     * Updates the location of the current installation in Kumulos
     * Accurate location information is used for geofencing
     */
    sendLocationUpdate: (location: { lat: number; lng: number }) => void;

    /**
     * Associates a user identifier with the current Kumulos installation record.
     *
     * If attributes are provided, will also set attributes for this user
     */
    associateUserWithInstall: (userIdentifier: string, attributes?: {}) => void;

    /**
     * Returns the identifier for the user currently associated with the Kumulos installation record.
     *
     * If no user is associated, it returns the Kumulos installation ID
     */
    getCurrentUserIdentifier: () => Promise<String>;

    /**
     * Clears any existing association between this install record and a user identifier.
     * See associateUserWithInstall and getCurrentUserIdentifier for further information.
     */
    clearUserAssociation: () => void;

    /**
     * Records a proximity event for an Eddystone beacon. Proximity events can be used in automation rules.
     */
    trackEddystoneBeaconProximity: (beacon: {
        namespaceHex: string;
        instanceHex: string;
        distanceMetres?: number;
    }) => void;

    /**
     * Records a proximity event for an iBeacon beacon. Proximity events can be used in automation rules.
     */
    trackiBeaconProximity: (beacon: {
        uuid: string;
        major: number;
        minor: number;
        proximity?: number;
    }) => void;
}

interface InAppInboxItem {
    title: string;
    subtitle: string;
    availableFrom: string | null;
    availableTo: string | null;
    dismissedAt: string | null;
    isRead: boolean;
}

interface IKumulosInApp {
    /**
     * Returns any locally persisted in-app inbox items that are currently available.
     * Most recently updated first.
     */
    getInboxItems: () => Promise<Array<InAppInboxItem>>;
    /**
     * Requests the display of the message associated with a given inbox item.
     * May fail if the item is no longer available or it was not found.
     */
    presentInboxMessage: (item: InAppInboxItem) => Promise<void>;
    /**
     * Allows opting the user in and out of in-app messaging when the strategy is
     * EXPLICIT_BY_USER. Throws a runtime exception if the strategy is AUTO_ENROLL
     * or in-app messaging is not configured.
     */
    updateConsentForUser: (consented: boolean) => void;

    /**
     * Requests the deletion of the message associated with a given inbox item.
     * May fail if the item is no longer available or it was not found.
     */
    deleteMessageFromInbox: (item: InAppInboxItem) => Promise<void>;

    /**
     * Marks given inbox item as read.
     * Promise is rejected if the item had been marked read before or if it is not found.
     */
    markAsRead: (item: InAppInboxItem) => Promise<void>;

    /**
     * Marks all inbox items as read.
     * Promise is rejected if operation fails.
     */
    markAllInboxItemsAsRead: () => Promise<void>;
}

declare const Kumulos: KumulosSdk;
export const KumulosInApp: IKumulosInApp;
export default Kumulos;
