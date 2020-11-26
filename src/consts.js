export const BUILD_BASE_URL = 'https://api.kumulos.com';
export const PUSH_BASE_URL = 'https://push.kumulos.com';
export const CRM_BASE_URL = 'https://crm.kumulos.com';

export const CrashReportFormat = 'raven';

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
