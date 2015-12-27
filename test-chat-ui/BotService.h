//
//  BotService.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;
@import CoreLocation;

@interface BotService : NSObject

+ (instancetype) sharedInstance;

- (void) scheduleTextMessage: (NSString *) text;
- (void) scheduleImageMessage: (NSString *) fileName width: (CGFloat) width height: (CGFloat) height;
- (void) scheduleLocationMessage: (CLLocationCoordinate2D) coordinate;

@end
