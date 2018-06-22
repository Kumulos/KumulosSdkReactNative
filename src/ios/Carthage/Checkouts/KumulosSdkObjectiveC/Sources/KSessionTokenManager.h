//
//  KSessionTokenManager.h
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSessionTokenManager : NSObject

+ (instancetype)sharedManager;
- (NSString*)sessionTokenForKey:(NSString*)key;
- (void)setSessionToken:(NSString*)sessionToken forKey:(NSString*)key;
- (void)removeSessionTokenForKey:(NSString*)key;
- (void)removeAllSessionTokens;
@end
