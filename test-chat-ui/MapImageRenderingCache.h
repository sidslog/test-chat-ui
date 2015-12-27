//
//  MapImageRenderingCache.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
@import UIKit;

@interface MapImageRenderingCache : NSObject

+ (instancetype) sharedInstance;

- (UIImage *) imageForCoodinate: (CLLocationCoordinate2D) coordinate;
- (void) setImage: (UIImage *) image forCoordinate: (CLLocationCoordinate2D) coordinate;

@end
