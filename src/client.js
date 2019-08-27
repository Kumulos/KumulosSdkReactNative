import { BUILD_BASE_URL, ResponseCode } from './consts';
import { generateUUID, getBasicAuthorizationHeader } from './utils';

import { NativeModules } from 'react-native';

export default class KumulosClient {
    constructor(config) {
        this.config = config;
        this.sessionToken = generateUUID();
    }

    async getInstallId() {
        return await NativeModules.kumulos.getInstallId();
    }

    async call(method, params = {}) {
        let installId = null;
        try {
            installId = await this.getInstallId();
        } catch (e) {
            // noop
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
}
