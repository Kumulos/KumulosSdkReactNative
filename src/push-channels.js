import { CRM_BASE_URL, PUSH_BASE_URL } from './consts';

import { makeAuthedJsonCall } from './utils';

async function changeChannelSubscriptions(client, uuids, method, allowEmptyUuids) {
    if (uuids.constructor !== Array || (uuids.length === 0 && !allowEmptyUuids)) {
        return Promise.reject(new Error('Provide an array of channel uuids'));
    }

    let userIdentifier = null;
    try {
        userIdentifier = await client.getUserIdentifier();
    }
    catch (e) {
        return Promise.reject(new Error('could not get userIdentifier'));
    }

    const url = `${CRM_BASE_URL}/v1/users/${encodeURIComponent(userIdentifier)}/channels/subscriptions`;

    const data = {
        uuids: uuids
    };

    return makeAuthedJsonCall(client, method, url, data)
        .then((response) => {
            if (response.status === 404) {
                Promise.reject(new Error('some channels are not found: status: ' + response.status));
            }
            else if (!response.ok) {
                Promise.reject(new Error('failed to update channel subscription. status: ' + response.status));
            }

            return response;
        });
}

export class PushSubscriptionManager {

    constructor(client) {
        this.client = client;
    }

    async listChannels() {
        let userIdentifier = null;
        try {
            userIdentifier = await this.client.getUserIdentifier();
        }
        catch (e) {
            return Promise.reject(new Error('could not get userIdentifier'));
        }

        const url = `${CRM_BASE_URL}/v1/users/${encodeURIComponent(userIdentifier)}/channels`;

        return makeAuthedJsonCall(this.client, 'GET', url)
            .then((response) => {
                if (!response.ok) {
                    Promise.reject(new Error('failed to list channels. status: ' + response.status));
                }
                else {
                    return response.json();
                }
            });
    }

    unsubscribe(uuids) {
        return changeChannelSubscriptions(this.client, uuids, 'DELETE');
    }

    subscribe(uuids) {
        return changeChannelSubscriptions(this.client, uuids, 'POST');
    }

    setSubscriptions(uuids) {
        return changeChannelSubscriptions(this.client, uuids, 'PUT');
    }

    clearSubscriptions() {
        return changeChannelSubscriptions(this.client, [], 'PUT', true);
    }

    async createChannel(spec) {
        const {
            uuid, subscribe = false, name = null, showInPortal = false, meta = null
        } = spec;

        if (!uuid) {
            return Promise.reject(new Error('Channel uuid must be specified for channel creation'));
        }

        if (showInPortal && !name) {
            return Promise.reject(new Error('Channel name must be specified for channel creation if the channel should be displayed in the portal'));
        }

        const url = `${CRM_BASE_URL}/v1/channels`;

        let data = {
            uuid,
            name: (!name) ? null : name,
            showInPortal,
            meta
        };

        if (subscribe) {
            let userIdentifier = null;
            try {
                userIdentifier = await this.client.getUserIdentifier();
            }
            catch (e) {
                return Promise.reject(new Error('could not get userIdentifier'));
            }

            data.userIdentifier = userIdentifier;
        }

        return makeAuthedJsonCall(this.client, 'POST', url, data)
            .then((response) => {
                if (!response.ok) {
                    Promise.reject(new Error('failed to create channel. status: ' + response.status));
                }

                return response.json();
            });
    }

}
