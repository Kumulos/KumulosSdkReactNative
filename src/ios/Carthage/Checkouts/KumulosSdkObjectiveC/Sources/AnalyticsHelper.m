//
//  AnalyticsHelper.m
//  KumulosSDK iOS
//

@import CoreData;
#import "AnalyticsHelper.h"
#import "Kumulos+Protected.h"
#import "KumulosEvents.h"

@interface AnalyticsHelper ()

@property (nonatomic) Kumulos* _Nonnull kumulos;
@property NSManagedObjectContext* analyticsContext;
@property (atomic) BOOL startNewSession;
@property (atomic) NSTimer* sessionIdleTimer;
@property (atomic) NSDate* becameInactiveAt;
@property (atomic) UIBackgroundTaskIdentifier bgTask;

@end

@implementation AnalyticsHelper

#pragma mark - Initialization

- (instancetype _Nullable) initWithKumulos:(Kumulos *)kumulos {
    if (self = [super init]) {
        self.kumulos = kumulos;
        self.startNewSession = YES;
        self.sessionIdleTimer = nil;
        self.bgTask = UIBackgroundTaskInvalid;
        
        [self initContext];
        [self registerListeners];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self syncEvents];
        });
    }
    
    return self;
}

- (void) initContext {
    NSURL* url = [[NSBundle bundleForClass:[self class]] URLForResource:@"KAnalyticsModel" withExtension:@"momd"];
    
    if (!url) {
        NSLog(@"Failed to find analytics models");
        return;
    }
    
    NSManagedObjectModel* objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    
    if (!objectModel) {
        NSLog(@"Failed to create object model");
        return;
    }
    
    NSPersistentStoreCoordinator* storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
    
    NSURL* docsUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL* storeUrl = [NSURL URLWithString:@"KAnalyticsDb.sqlite" relativeToURL:docsUrl];
    
    NSError* err = nil;
    [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&err];
    
    if (err) {
        NSLog(@"Failed to set up persistent store: %@", err);
        return;
    }
    
    self.analyticsContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    self.analyticsContext.persistentStoreCoordinator = storeCoordinator;
}

- (void) registerListeners {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameInactive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

# pragma mark - Event tracking

- (void) trackEvent:(NSString *)eventType withProperties:(NSDictionary *)properties {
    [self trackEvent:eventType atTime:[NSDate date] withProperties:properties];
}

- (void) trackEvent:(NSString *)eventType withProperties:(NSDictionary *)properties flushingImmediately:(BOOL)flushImmediately {
    [self trackEvent:eventType atTime:[NSDate date] withProperties:properties asynchronously:YES flushingImmediately:flushImmediately];
}

- (void) trackEvent:(NSString *)eventType atTime:(NSDate *)happenedAt withProperties:(NSDictionary *)properties {
    [self trackEvent:eventType atTime:happenedAt withProperties:properties asynchronously:YES];
}

- (void) trackEvent:(NSString *)eventType atTime:(NSDate *)happenedAt withProperties:(NSDictionary *)properties asynchronously:(BOOL)asynchronously {
    [self trackEvent:eventType atTime:happenedAt withProperties:properties asynchronously:YES flushingImmediately:NO];
}

- (void) trackEvent:(NSString *)eventType atTime:(NSDate *)happenedAt withProperties:(NSDictionary *)properties asynchronously:(BOOL)asynchronously flushingImmediately:(BOOL)flushImmediately {
    if ([eventType isEqualToString:@""] || (properties && ![NSJSONSerialization isValidJSONObject:properties])) {
        NSLog(@"Ignoring invalid event with empty type or non-serializable properties");
        return;
    }
    
    void (^workItem)(void) = ^{
        NSManagedObjectContext* context = self.analyticsContext;
        
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
        
        if (!entity) {
            return;
        }
        
        NSManagedObject* event = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        
        if (!event) {
            return;
        }
        
        NSError* err = nil;
        
        NSNumber* happenedAtMillis = [NSNumber numberWithDouble:[happenedAt timeIntervalSince1970] * 1000];
        NSString* uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
        NSData* propsJson = nil;
        
        if (properties) {
            propsJson = [NSJSONSerialization dataWithJSONObject:properties options:0 error:&err];
            
            if (err) {
                NSLog(@"Failed to encode properties, properties will be nil");
                propsJson = nil;
                err = nil;
            }
        }
        
        [event setValue:uuid forKey:@"uuid"];
        [event setValue:happenedAtMillis forKey:@"happenedAt"];
        [event setValue:eventType forKey:@"eventType"];
        [event setValue:propsJson forKey:@"properties"];
        
        [context save:&err];
        
        if (err) {
            NSLog(@"Failed to record event: %@", err);
            return;
        }
        
        if (flushImmediately) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self syncEvents];
            });
        }
    };
    
    if (asynchronously) {
        [self.analyticsContext performBlock:workItem];
    }
    else {
        [self.analyticsContext performBlockAndWait:workItem];
    }
}

- (void) syncEvents {
    NSArray* results = [self fetchEventsBatch];
    
    if (results.count) {
        [self syncEventsBatch:results];
    }
    else if (self.bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

- (void) syncEventsBatch:(NSArray<NSManagedObject*>*) events {
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:events.count];
    
    for (NSManagedObject* event in events) {
        NSError* err = nil;
        NSData* props = [event valueForKey:@"properties"];
        id propsObject = nil;
        if (props) {
            propsObject = [NSJSONSerialization JSONObjectWithData:props options:0 error:&err];
            if (err) {
                NSLog(@"Failed to decode event properties: %@", err);
            }
        }
        
        [data addObject:@{
                          @"type": [event valueForKey:@"eventType"],
                          @"uuid": [event valueForKey:@"uuid"],
                          @"timestamp": [event valueForKey:@"happenedAt"],
                          @"data": (propsObject) ? propsObject : [NSNull null]
                          }];
    }
    
    NSString* path = [NSString stringWithFormat:@"/v1/app-installs/%@/events", [Kumulos installId]];
    [self.kumulos.eventsHttpClient POST:path parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError* err = [self pruneEventsBatch:events];
        
        if (err) {
            NSLog(@"Failed to prune events: %@", err);
            return;
        }
        
        [self syncEvents];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // Failed so assume will be retried some other time
        if (self.bgTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        }
    }];
}

- (NSError*) pruneEventsBatch:(NSArray<NSManagedObject*>*) events {
    NSError* err = nil;

    for (NSManagedObject* event in events) {
        [self.analyticsContext deleteObject:event];
    }
    
    [self.analyticsContext save:&err];
    
    return err;
}

- (NSArray<NSManagedObject*>* _Nonnull) fetchEventsBatch {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.returnsObjectsAsFaults = NO;
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"happenedAt" ascending:YES] ];
    request.fetchLimit = 100;
    request.includesPendingChanges = NO;
    
    NSError* err = nil;
    
    NSArray<NSManagedObject*>* results = [self.analyticsContext executeFetchRequest:request error:&err];
    
    if (err) {
        NSLog(@"Failed to fetch events batch: %@", err);
        results = @[];
    }
    
    return results;
}

#pragma mark - App lifecycle delegates

- (void) appBecameActive {
    if (self.startNewSession) {
        [self trackEvent:KumulosEventForeground withProperties:nil];
        self.startNewSession = NO;
        return;
    }
    
    if (self.sessionIdleTimer) {
        [self.sessionIdleTimer invalidate];
        self.sessionIdleTimer = nil;
    }
    
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

- (void) appBecameInactive {
    self.becameInactiveAt = [NSDate date];
    
    NSUInteger timeout = self.kumulos.config.sessionIdleTimeoutSeconds;
    self.sessionIdleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(sessionDidEnd) userInfo:nil repeats:NO];
}

- (void) appBecameBackground {
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"sync" expirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void) appWillTerminate {
    if (self.sessionIdleTimer) {
        [self.sessionIdleTimer invalidate];
        [self sessionDidEnd];
    }
}

- (void) sessionDidEnd {
    self.startNewSession = YES;
    self.sessionIdleTimer = nil;

    [self trackEvent:KumulosEventBackground atTime:self.becameInactiveAt withProperties:nil asynchronously:NO];
    self.becameInactiveAt = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self syncEvents];
    });
}

@end
