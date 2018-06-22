//
//  RpcHttpClient.h
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef COCOAPODS
#import "AFNetworking.h"
#else
#import <AFNetworking/AFNetworking.h>
#endif

@interface RpcHttpClient : AFHTTPSessionManager

-  (instancetype) initWithApiKey:(NSString*) apiKey andSecretKey:(NSString*) secretKey;

@end
