import * as DeviceInfo from 'react-native-device-info';

import {
    OsType,
    OsTypeMap,
    RuntimeType,
    STATS_BASE_URL,
    SdkType,
    TargetType
} from './consts';

import { Platform } from 'react-native';
import { makeAuthedJsonCall } from './utils';

const ReactPackage = require('react-native/package.json');
const KumulosPackage = require('../package.json');

export async function sendStatsData(client) {
    let installId = null;
    try {
        installId = await client.getInstallId();
    }
    catch (e) {
        // Something wrong with storage
        console.error('couldnt get installId');
        return;
    }

    const osVersion = DeviceInfo.getSystemVersion();
    const osId = OsTypeMap[DeviceInfo.getSystemName()] || OsType.UNKNOWN;
    const target = __DEV__ ? TargetType.DEBUG : TargetType.RELEASE;
    const isEmulator = DeviceInfo.isEmulator();
    const tz = DeviceInfo.getTimezone();
    const appVersion = DeviceInfo.getVersion();
    const reactVersion = ReactPackage.version;
    const bundleId = DeviceInfo.getBundleId();
    const locale = DeviceInfo.getDeviceLocale();

    let buildModel = '';
    switch (Platform.OS) {
        case 'ios':
            buildModel = DeviceInfo.getDeviceId();
            break;
        case 'android':
            buildModel = DeviceInfo.getModel();
            break;
    }

    const deviceData = {
        app: {
            version: appVersion,
            target: target,
            bundle: bundleId
        },
        sdk: {
            id: SdkType.REACT_NATIVE,
            version: KumulosPackage.version
        },
        runtime: {
            id: RuntimeType.REACT_NATIVE,
            version: reactVersion
        },
        os: {
            id: osId,
            version: osVersion
        },
        device: {
            name: buildModel,
            tz: tz,
            isSimulator: isEmulator,
            locale: locale
        }
    };

    const url = `${STATS_BASE_URL}/v1/app-installs/${installId}`;

    makeAuthedJsonCall(client, 'PUT', url, deviceData);
}
