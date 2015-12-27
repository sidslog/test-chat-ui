//
//  MapImageRenderer.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import CoreLocation;

@class MapImageRenderer;

typedef void(^MapImageRendererCompletionBlock)(CLLocationCoordinate2D coordinate, UIImage *image, NSError *error);

@interface MapImageRenderer : NSObject

- (instancetype) initInView: (UIView *) view;
- (NSOperation *) renderCoordinate: (CLLocationCoordinate2D) coordinate withCompletion: (MapImageRendererCompletionBlock) completion;

@end
