import { AsyncStorage, NativeModules, Platform } from 'react-native';
import { BUILD_BASE_URL, PUSH_BASE_URL, PushTokenType, STATS_BASE_URL } from './consts';
import { generateUUID, getBasicAuthorizationHeader, makeAuthedJsonCall } from './utils';

import { sendStatsData } from './stats';

export { PushSubscriptionManager } from './push-channels';

export const ResponseCode = {
    SUCCESS: 1,
    NOT_AUTHORIZED: 2,
    NO_SUCH_METHOD: 4,
    NO_SUCH_FORMAT: 8,
    ACCOUNT_SUSPENDED: 16,
    INVALID_REQUEST: 32,
    UNKNOWN_SERVER_ERROR: 64,
    DATABASE_ERROR: 128
};

export default class KumulosClient {

    constructor(config) {
        if (config.apiKey.trim() === '' || config.secretKey.trim() === '') {
            throw 'You need to provide apiKey and secretKey before you can use Kumulos';
        }

        this.sessionToken = generateUUID();
        this.config = config;

        sendStatsData(this);
    }

    async getInstallId() {
        let installId = await AsyncStorage.getItem('kumulos_installId');

        if (installId === null) {
            installId = generateUUID();
            await AsyncStorage.setItem('kumulos_installId', installId);
        }

        return installId;
    }

    async sendLocationUpdate(latitude, longitude) {
        const installId = await this.getInstallId();

        if (!installId) {
            console.error('Failed to get installId, aborting');
        }

        const url = `${STATS_BASE_URL}/v1/app-installs/${installId}/location`;

        return makeAuthedJsonCall(this, 'PUT', url, {
            lat: latitude,
            lng: longitude
        });
    }

    async call(method, params = {}) {
        let installId = null;
        try {
            installId = await this.getInstallId();
        }
        catch (e) {
            // Something wrong with storage
        }

        let data = new FormData();
        data.append('sessionToken', this.sessionToken);

        if (installId) {
            data.append('installId', installId);
        }

        Object.keys(params).forEach(key => {
            data.append('params[' + key + ']', params[key]);
        });

        const url = `${BUILD_BASE_URL}/b2.2/${this.config.apiKey}/${method}.json`;
        const options = {
            method: 'POST',
            headers: {
                Authorization: getBasicAuthorizationHeader(this)
            },
            body: data
        };

        const response = await fetch(url, options);
        const responseData = await response.json();

        if (responseData.sessionToken) {
            this.sessionToken = responseData.sessionToken;
        }

        switch (responseData.responseCode) {
            case ResponseCode.SUCCESS:
                return responseData.payload;
            default:
                return Promise.reject(responseData);
        }
    }

    // Store a push token for this installation
    async pushStoreToken(token) {
        let installId = null;
        try {
            installId = await this.getInstallId();
        }
        catch (e) {
            console.error('couldnt get installId');
            return;
        }
        
        let data = {
            token
        };

        if (Platform.OS === 'ios') {
            data.type = PushTokenType.IOS;
            data.iosTokenType = await NativeModules.kumulos.KSgetIosTokenType();
        }
        else if (Platform.OS === 'android') {
            data.type = PushTokenType.ANDROID;
        }

        const url = `${PUSH_BASE_URL}/v1/app-installs/${installId}/push-token`;

        return makeAuthedJsonCall(this, 'PUT',  url, data);
    }
            
    // Remove the push token from Kumulos for this installation
    async pushRemoveToken() {
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
            
    // Track the open of a push notification
    async pushTrackOpen(notificationId) {
        let installId = null;
        try {
            installId = await this.getInstallId();
        }
        catch (e) {
            console.error('couldnt get installId and track open');
            return;
        }

        const data = {
            id: notificationId
        };

        const url = `${PUSH_BASE_URL}/v1/app-installs/${installId}/opens`;

        return makeAuthedJsonCall(this, 'POST', url, data);
    }

}
