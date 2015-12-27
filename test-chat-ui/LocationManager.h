//
//  LocationManager.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface LocationManager : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D currentCoordinate;

+ (instancetype) sharedInstance;
- (void)start;

@end
