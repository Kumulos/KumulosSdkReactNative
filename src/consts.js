
export const BUILD_BASE_URL = 'https://api.kumulos.com';
export const STATS_BASE_URL = 'https://stats.kumulos.com';
export const PUSH_BASE_URL = 'https://push.kumulos.com';

export const TargetType = {
    DEBUG: 1,
    RELEASE: 2
};

export const RuntimeType = {
    REACT_NATIVE: 7
};

export const SdkType = {
    REACT_NATIVE: 9
};

export const OsType = {
    UNKNOWN: -1,
    IOS: 1,
    ANDROID: 3,
    WINDOWS: 5
};

export const OsTypeMap = {
    iOS: OsType.IOS,
    Android: OsType.ANDROID,
    Windows: OsType.WINDOWS
};

export const PushTokenType = {
    IOS: 1,
    ANDROID: 2
};
