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

typedef void(^MapImageRendererCompletionBlock)(MapImageRenderer *renderer, UIImage *image, NSError *error);

@interface MapImageRenderer : NSObject

- (instancetype) initInView: (UIView *) view;
- (void) renderCoordinate: (CLLocationCoordinate2D) coordinate withCompletion: (MapImageRendererCompletionBlock) completion;
- (void) cancel;

@end
