//
//  MapImageRenderingOperation.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/27/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapImageRenderer.h"

@class MKMapView;

@interface MapImageRenderingOperation : NSOperation

- (instancetype)initWithContainerView: (UIView *) containerView coordinate: (CLLocationCoordinate2D) coordinate completion: (MapImageRendererCompletionBlock) completion;

@end
