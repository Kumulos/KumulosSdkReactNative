//
//  KSessionTokenManager.m
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import "KSessionTokenManager.h"

@interface KSessionTokenManager ()
@property (atomic, strong) NSMutableDictionary *sessionTokenMap;
@end

@implementation KSessionTokenManager

#pragma mark - Singleton
+ (instancetype)sharedManager {
    static KSessionTokenManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Initialization
- (instancetype)init {
    if (self = [super init]) {
        _sessionTokenMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Session Token Methods
- (NSString*)sessionTokenForKey:(NSString*)key{
    @synchronized (self) {
        if (self.sessionTokenMap[key]) {
            return self.sessionTokenMap[key];
        }
        
        self.sessionTokenMap[key] = [self generateNewSessionToken];
        return self.sessionTokenMap[key];
    }
}

- (void)setSessionToken:(NSString*)sessionToken forKey:(NSString*)key{
    self.sessionTokenMap[key] = sessionToken;
}

- (void)removeSessionTokenForKey:(NSString*)key{
    [self.sessionTokenMap removeObjectForKey:key];
}

- (void)removeAllSessionTokens{
    [self.sessionTokenMap removeAllObjects];
}

#pragma mark - Helpers
- (NSString*)generateNewSessionToken{
    return [[NSUUID UUID] UUIDString];
}
@end
