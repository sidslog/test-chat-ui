//
//  BotService.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "BotService.h"

#import "DataManager.h"

@implementation BotService

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static BotService *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BotService alloc] init];
    });
    return instance;
}

- (void) scheduleTextMessage: (NSString *) text {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DataManager sharedInstance] addTextMessage:text fromMe:NO withCompletion:nil];
    });
}

- (void) scheduleImageMessage: (NSString *) fileName width: (CGFloat) width height: (CGFloat) height  {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DataManager sharedInstance] addImageMessage:fileName width:width height:height fromMe:NO withCompletion:nil];
    });
}

- (void) scheduleLocationMessage: (CLLocationCoordinate2D) coordinate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DataManager sharedInstance] addLocationMessage:coordinate fromMe:NO withCompletion:nil];
    });
}


@end
