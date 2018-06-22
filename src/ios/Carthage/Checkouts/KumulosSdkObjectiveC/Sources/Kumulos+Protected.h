//
//  Kumulos+Protected.h
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#ifdef COCOAPODS
#import "AFNetworking.h"
#else
#import <AFNetworking/AFNetworking.h>
#endif

#import "Kumulos.h"
#import "RpcHttpClient.h"
#import "AuthedJsonHttpClient.h"

#if TARGET_OS_IOS
#import "AnalyticsHelper.h"
#endif

#define KUMULOS_INSTALL_ID_KEY @"KumulosUUID"

@interface Kumulos ()

@property (nonatomic) NSString* apiKey;
@property (nonatomic) NSString* secretKey;

@property (nonatomic) NSOperationQueue* operationQueue;

@property (nonatomic) RpcHttpClient* rpcHttpClient;
@property (nonatomic) AuthedJsonHttpClient* pushHttpClient;

#if TARGET_OS_IOS
@property (nonatomic) AnalyticsHelper* analyticsHelper;
@property (nonatomic) AuthedJsonHttpClient* eventsHttpClient;
#else
@property (nonatomic) AuthedJsonHttpClient* statsHttpClient;
#endif

@end
