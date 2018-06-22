//
//  RpcHttpClient.m
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import "RpcHttpClient.h"

static NSString * const KSApiBaseUrl = @"https://api.kumulos.com";

@implementation RpcHttpClient

- (instancetype) initWithApiKey:(NSString*) apiKey andSecretKey:(NSString*)secretKey {
    if (self = [super initWithBaseURL:[NSURL URLWithString:KSApiBaseUrl]]) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFPropertyListResponseSerializer serializer];
        
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:apiKey password:secretKey];
        
        NSSet* acceptableContentTypes = [NSSet setWithArray:@[@"application/xml"]];
        [self.responseSerializer setAcceptableContentTypes:acceptableContentTypes];
    }
    return self;
}

@end
