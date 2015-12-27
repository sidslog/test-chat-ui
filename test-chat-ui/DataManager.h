//
//  DataManager.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
@import CoreGraphics;
@import CoreData;

typedef void(^DataManagerCompletionBlock)(BOOL result, NSError *error);


@interface DataManager : NSObject

+ (instancetype) sharedInstance;

- (void) start;

- (void) addTextMessage: (NSString *) text fromMe: (BOOL) fromMe withCompletion: (DataManagerCompletionBlock) completion;
- (void) addImageMessage: (NSString *) fileName width: (CGFloat) width height: (CGFloat) height fromMe: (BOOL) fromMe withCompletion: (DataManagerCompletionBlock) completion;
- (void) addLocationMessage: (CLLocationCoordinate2D) location fromMe: (BOOL) fromMe withCompletion: (DataManagerCompletionBlock) completion;

- (NSFetchedResultsController *) fetchedResultsControllerForMessages;

@end
