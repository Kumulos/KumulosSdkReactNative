//
//  KumulosPushSubscriptionManager.m
//  KumulosSDK
//
//  Copyright © 2017 kumulos. All rights reserved.
//

#import "KumulosPushSubscriptionManager.h"
#import "Kumulos+Protected.h"

@interface KumulosPushSubscriptionManager ()

@property (nonatomic) Kumulos* kumulos;

@end

@implementation KSPushChannel

+ (instancetype _Nonnull) createFromObject:(id)object {
    KSPushChannel* channel = [[KSPushChannel alloc] init];
    
    channel->_uuid = object[@"uuid"];
    channel->_name = ([object[@"name"] isEqual:[NSNull null]]) ? nil : object[@"name"];
    channel->_meta = ([object[@"meta"] isEqual:[NSNull null]]) ? nil : object[@"meta"];
    channel->_isSubscribed = [object[@"subscribed"] boolValue];
    
    return channel;
}

@end

@implementation KumulosPushSubscriptionManager

- (instancetype _Nonnull) initWithKumulos:(Kumulos*) client {
    if (self = [super init]) {
        self.kumulos = client;
    }
    
    return self;
}

- (void) subscribeToChannels:(NSArray<NSString *> *)uuids {
    [self subscribeToChannels:uuids onComplete:nil];
}

- (void) subscribeToChannels:(NSArray<NSString *> *)uuids onComplete:(KSPushSubscriptionCompletionBlock)complete {
    NSDictionary* params = @{@"uuids": uuids};
    NSString* path = [NSString stringWithFormat:@"/v1/app-installs/%@/channels/subscriptions", [Kumulos installId]];
    
    [self.kumulos.pushHttpClient POST:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!complete) {
            return;
        }
        
        complete(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (complete) {
            complete(error);
        }
    }];
}

- (void) unsubscribeFromChannels:(NSArray<NSString *> *)uuids{
    [self unsubscribeFromChannels:uuids onComplete:nil];
}

- (void) unsubscribeFromChannels:(NSArray<NSString *> *)uuids onComplete:(KSPushSubscriptionCompletionBlock)complete {
    NSDictionary* params = @{@"uuids": uuids};
    NSString* path = [NSString stringWithFormat:@"/v1/app-installs/%@/channels/subscriptions", [Kumulos installId]];
    
    [self.kumulos.pushHttpClient DELETE:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!complete) {
            return;
        }
        
        complete(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (complete) {
            complete(error);
        }
    }];
}

- (void) setSubscriptions:(NSArray<NSString *> *)uuids {
    [self setSubscriptions:uuids onComplete:nil];
}

- (void) setSubscriptions:(NSArray<NSString *> *)uuids onComplete:(KSPushSubscriptionCompletionBlock)complete {
    NSDictionary* params = @{@"uuids": uuids};
    NSString* path = [NSString stringWithFormat:@"/v1/app-installs/%@/channels/subscriptions", [Kumulos installId]];
    
    [self.kumulos.pushHttpClient PUT:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!complete) {
            return;
        }
        
        complete(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (complete) {
            complete(error);
        }
    }];
}

- (void) clearSubscriptions {
    [self clearSubscriptions:nil];
}

- (void) clearSubscriptions:(KSPushSubscriptionCompletionBlock)complete {
    [self setSubscriptions:@[] onComplete:complete];
}

- (void) createChannelWithUuid:(NSString *)uuid shouldSubscribe:(BOOL)subscribe name:(NSString *)name showInPortal:(BOOL)shownInPortal andMeta:(NSDictionary *)meta onComplete:(KSPushChannelSuccessBlock)complete {
    
    if (shownInPortal && (name == nil || name.length == 0)) {
        complete([NSError
                  errorWithDomain:KSErrorDomain
                  code:KSErrorCodeValidationError
                  userInfo:@{@"error": @"Name is required to show a channel in the portal"}
                  ],
                 nil);
        return;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:5];
    
    params[@"uuid"] = uuid;
    params[@"showInPortal"] = @(shownInPortal);
    
    if (name && name.length > 0) {
        params[@"name"] = name;
    }
    
    if (subscribe) {
        params[@"installId"] = [Kumulos installId];
    }
    
    if (meta) {
        params[@"meta"] = meta;
    }
    
    NSString* path = @"/v1/channels";
    
    [self.kumulos.pushHttpClient POST:path parameters:params  progress:nil success:^(NSURLSessionDataTask* _Nonnull task, id _Nullable responseObject) {
        if (nil == responseObject) {
            complete([NSError
                      errorWithDomain:KSErrorDomain
                      code:KSErrorCodeUnknownError
                      userInfo:@{@"error": @"No channel returned for create request"}
                      ], nil);
        }
        
        KSPushChannel* channel = [KSPushChannel createFromObject:responseObject];
        complete(nil, channel);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        complete(error, nil);
    }];
}

- (void) listChannels:(KSPushChannelsSuccessBlock)complete {
    NSString* path = [NSString stringWithFormat:@"/v1/app-installs/%@/channels", [Kumulos installId]];
    
    [self.kumulos.pushHttpClient GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask* _Nonnull task, id _Nullable responseObject) {
        if (nil == responseObject) {
            complete([NSError
                      errorWithDomain:KSErrorDomain
                      code:KSErrorCodeUnknownError
                      userInfo:@{@"error": @"No channels returned for list request"}
                      ], nil);
        }
        
        NSArray* data = responseObject;
        NSMutableArray<KSPushChannel*>* channels = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [channels addObject:[KSPushChannel createFromObject:obj]];
        }];
        
        complete(nil, channels);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        complete(error, nil);
    }];
}

@end

