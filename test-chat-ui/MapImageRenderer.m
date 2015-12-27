//
//  MapImageRenderer.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "MapImageRenderer.h"
#import "MapImageRenderingCache.h"
#import "MapImageRenderingOperation.h"
@import MapKit;

@interface MapImageRenderer () <MKMapViewDelegate>

@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation MapImageRenderer

- (instancetype) initInView: (UIView *) view {
    if (self = [super init]) {
        self.view = view;
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (NSOperation *) renderCoordinate: (CLLocationCoordinate2D) coordinate withCompletion: (MapImageRendererCompletionBlock) completion {
    
    UIImage *image = [[MapImageRenderingCache sharedInstance] imageForCoodinate:coordinate];
    if (image) {
        if (completion) {
            completion(coordinate, image, nil);
        }
        return nil;
    }

    NSOperation *operation = [[MapImageRenderingOperation alloc] initWithContainerView:self.view coordinate:coordinate completion:completion];
    [self.operationQueue addOperation:operation];
    return operation;
    
}

@end
