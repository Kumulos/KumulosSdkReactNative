import base64 from 'base-64';

// http://stackoverflow.com/a/8809472/543200
export function generateUUID() {
    var d = new Date().getTime();
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = (d + Math.random() * 16) % 16 | 0;
        d = Math.floor(d / 16);
        return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
    });
    return uuid;
}

export function getBasicAuthorizationHeader(client) {
    return `Basic ${base64.encode(`${client.config.apiKey}:${client.config.secretKey}`)}`;
}

export function makeAuthedJsonCall(client, method, url, data = null) {
    const headers = {
        'Authorization': getBasicAuthorizationHeader(client),
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    };

    let options = {
        method,
        headers
    };

    if (data) {
        options.body = JSON.stringify(data);
    }

    return fetch(url, options);
}
