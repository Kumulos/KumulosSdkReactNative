//
//  AuthedJsonHttpClient.m
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import "AuthedJsonHttpClient.h"

@implementation AuthedJsonHttpClient

- (instancetype) initWithBaseUrl:(NSString *)baseUrl apiKey:(NSString *)apiKey andSecretKey:(NSString *)secretKey {
    if (self = [super initWithBaseURL:[NSURL URLWithString:baseUrl]]) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:apiKey password:secretKey];
    }
    
    return self;
}

@end
