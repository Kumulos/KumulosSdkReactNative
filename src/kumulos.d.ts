
export interface KumulosConfig {
    apiKey: string;
    secretKey: string;
}

export interface PushChannel {
    uuid: string;
    name?: string;
    subscribed: Boolean;
    meta?: any;
}

export interface ChannelSpec {
    uuid: string;
    subscribe: boolean;
    meta?: any;
    name?: string;
    showInPortal?: boolean;
}

export default class KumulosClient {
    // The Kumulos RPC session token
    sessionToken: string;

    // Initialize with given configuration
    constructor(config: KumulosConfig);

    // Gets the unique Kumulos installation identifier
    getInstallId(): Promise<string>;

    // Update the coordinates of this install in Kumulos
    // Accurate location updates are used by geofences
    sendLocationUpdate(latitude: number, longitude: number): Promise<Response>;

    // Call an RPC API method
    call(method: string, params?: {}): Promise<any>;

    // Store a push token for this installation
    pushStoreToken(token: string): Promise<Response>;

    // Remove the push token from Kumulos for this installation
    pushRemoveToken(): Promise<Response>;

    // Track the open of a push notification
    pushTrackOpen(notificationId: string): Promise<Response>;
}

export class PushSubscriptionManager {
    constructor(client: KumulosClient);
    /**
     * Subscribes to the channels given by unique ID
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
