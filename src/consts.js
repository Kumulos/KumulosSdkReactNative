
const ReactPackage = require('react-native/package.json');
const KumulosPackage = require('../package.json');

export const BUILD_BASE_URL = 'https://api.kumulos.com';
export const PUSH_BASE_URL = 'https://push.kumulos.com';

export const CrashReportFormat = 'raven';

const RuntimeType = {
    REACT_NATIVE: 7
};

const SdkType = {
    REACT_NATIVE: 9
};

export const SdkInfo = {
    id: SdkType.REACT_NATIVE,
    version: KumulosPackage.version
};

export const RuntimeInfo = {
    id: RuntimeType.REACT_NATIVE,
    version: ReactPackage.version
};

export const KumulosEvent = {
    AppForegrounded: 'k.fg',
    PushTrackOpen: 'k.push.opened',
    EngageBeaconEnteredProximity: 'k.engage.beaconEnteredProximity',
    EngageLocationUpdated: 'k.engage.locationUpdated',
    CrashLoggedException: 'k.crash.loggedException'
};

export const BeaconType = {
    iBeacon: 1,
    Eddystone: 2
};

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
