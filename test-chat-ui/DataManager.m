//
//  DataManager.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "DataManager.h"

#import "MessageBase.h"
#import "TextMessage.h"
#import "ImageMessage.h"
#import "LocationMessage.h"

@import CoreData;

@interface DataManager ()

@property (nonatomic, strong) NSManagedObjectModel* model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

@property (nonatomic, strong) NSManagedObjectContext *mainContext;

@end

@implementation DataManager

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static DataManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)addTextMessage:(NSString *)text fromMe: (BOOL) fromMe withCompletion:(DataManagerCompletionBlock)completion {
    [self save:^(NSManagedObjectContext *context) {
        
        TextMessage *message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(TextMessage.class) inManagedObjectContext:context];
        message.dateCreated = [NSDate date];
        message.fromMe = @(fromMe);
        message.value = text;
        
    } withCompletion:completion];
}

- (void) addImageMessage: (NSString *) fileName width: (CGFloat) width height: (CGFloat) height fromMe: (BOOL) fromMe withCompletion: (DataManagerCompletionBlock) completion {
    [self save:^(NSManagedObjectContext *context) {
        
        ImageMessage *message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(ImageMessage.class) inManagedObjectContext:context];
        message.dateCreated = [NSDate date];
        message.fromMe = @(fromMe);
        message.fileName = fileName;
        message.width = @(width);
        message.height = @(height);
        
    } withCompletion:completion];
}

- (void) addLocationMessage:(CLLocationCoordinate2D)location fromMe:(BOOL)fromMe withCompletion:(DataManagerCompletionBlock)completion {
    [self save:^(NSManagedObjectContext *context) {
        
        LocationMessage *message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(LocationMessage.class) inManagedObjectContext:context];
        message.dateCreated = [NSDate date];
        message.fromMe = @(fromMe);
        message.latitude = @(location.latitude);
        message.longitude = @(location.longitude);
        
    } withCompletion:completion];
}


- (NSFetchedResultsController *) fetchedResultsControllerForMessages {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(MessageBase.class)];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.mainContext sectionNameKeyPath:nil cacheName:nil];
    return controller;
}

#pragma mark - saving

- (void) save: (void (^)(NSManagedObjectContext *context)) block withCompletion: (DataManagerCompletionBlock) completion {
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectContext *parentContext = self.mainContext;
    privateContext.parentContext = parentContext;
    
    [privateContext performBlock:^{
        if (block) {
            block(privateContext);
        }
        
        NSError *error = nil;
        if ([privateContext save:&error]) {
            [parentContext performBlock:^{
                NSError *error = nil;
                if ([parentContext save:&error]) {
                    if (completion) {
                        completion(YES, nil);
                    }
                } else {
                    if (completion) {
                        completion(NO, error);
                    }
                }
            }];
        } else {
            [parentContext performBlock:^{
                if (completion) {
                    completion(NO, error);
                }
            }];
        }
        
    }];
    
}


#pragma mark - setup

- (void) start {
    self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    
    NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"messages.sqlite"];
    
    NSAssert(storeURL != nil, @"no valid store url provided");
    
    NSError *error = nil;
    if ([self.coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.mainContext.persistentStoreCoordinator  = self.coordinator;
    } else {
        NSAssert(false, @"coodinator couldn't add store: %@, %@", error, storeURL);
    }
    
}

@end
