//
//  MapImageRenderingQueue.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "MapImageRenderingCache.h"

@interface MapImageRenderingCache ()

@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation MapImageRenderingCache

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static MapImageRenderingCache *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[MapImageRenderingCache alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.imageCache = [[NSCache alloc] init];
        self.imageCache.countLimit = 10;
    }
    return self;
}

- (UIImage *) imageForCoodinate: (CLLocationCoordinate2D) coordinate {
    return [self.imageCache objectForKey:[self keyFromCooridate:coordinate]];
}

- (void) setImage: (UIImage *) image forCoordinate: (CLLocationCoordinate2D) coordinate {
    [self.imageCache setObject:image forKey:[self keyFromCooridate:coordinate]];
}


- (NSString *) keyFromCooridate: (CLLocationCoordinate2D) coordinate {
    return [NSString stringWithFormat:@"%f-%f", coordinate.latitude, coordinate.longitude];
}

@end
