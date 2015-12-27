//
//  MapImageRenderingOperation.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/27/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "MapImageRenderingOperation.h"
#import "MapImageRenderingCache.h"
#import <objc/runtime.h>
@import MapKit;

static CGSize const kMapImageRendererSize = {200, 200};

@interface MapImageRenderingOperation () <MKMapViewDelegate>

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) MapImageRendererCompletionBlock completion;

@property (atomic, assign) BOOL done;
@property (nonatomic, strong) NSError *renderError;

@end

@implementation MapImageRenderingOperation

- (instancetype)initWithContainerView: (UIView *) containerView coordinate: (CLLocationCoordinate2D) coordinate completion: (MapImageRendererCompletionBlock) completion {
    if (self = [super init]) {
        self.containerView = containerView;
        self.coordinate = coordinate;
        self.completion = completion;
        self.done = NO;
    }
    return self;
}

- (void)main {
    // дадим возможность пользователю отказаться, пролистнув ячейку
    [NSThread sleepForTimeInterval:0.3];
    
    if (!self.completion || self.isCancelled) {
        return;
    }
    
    // в кеше?
    UIImage *image = [[MapImageRenderingCache sharedInstance] imageForCoodinate:self.coordinate];
    if (image) {
        [self finishWithImage:image];
        return;
    }
    
    // добавим карту в иерархию вьюх
    dispatch_sync(dispatch_get_main_queue(), ^{
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, kMapImageRendererSize.width, kMapImageRendererSize.height)];
        [self.containerView insertSubview:mapView atIndex:0];
        self.mapView = mapView;
        self.mapView.delegate = self;
        self.mapView.region = MKCoordinateRegionMakeWithDistance(self.coordinate, 500, 500);
    });
    
    // ждем ответ от делегата
    while (!self.isCancelled && !self.done) {
        [[NSRunLoop currentRunLoop] run];
    }
    
    if (self.isCancelled) {
        [self clearMemory];
        return;
    }
    
    // в зависимости от ответа рисуем либо картинку, либо возвращаем ошибку
    if (!self.renderError) {
        [self renderMapLayer];
    } else {
        [self finishWithError];
    }
    
    // удалим self.mapView
    [self clearMemory];
}

- (void) renderMapLayer {
    float scale = [UIScreen mainScreen].scale;
    CGSize resize = CGSizeMake(self.mapView.bounds.size.width * scale, self.mapView.bounds.size.height * scale);
    UIGraphicsBeginImageContextWithOptions(resize, YES, 0);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.isCancelled) {
        return;
    }
    // todo: возможно ли это сделать асинхронно, проблема в self.mapView.layer?
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.mapView.layer renderInContext:context];
    });
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[MapImageRenderingCache sharedInstance] setImage:image forCoordinate:self.coordinate];
    [self finishWithImage:image];
}

#pragma mark - exit

- (void) finishWithImage: (UIImage *) image {
    CLLocationCoordinate2D coordinate = self.coordinate;
    MapImageRendererCompletionBlock completion = self.completion;
    if (self.isCancelled) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            completion(coordinate, image, nil);
        }
    });
}

- (void) finishWithError {
    CLLocationCoordinate2D coordinate = self.coordinate;
    MapImageRendererCompletionBlock completion = self.completion;
    NSError *error = self.renderError;
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(coordinate, nil, error);
        });
    }
}

#pragma mark - memory

- (void) clearMemory {
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.mapView.delegate = nil;
        [self.mapView removeFromSuperview];
    });
}

#pragma mark - mapview delegate

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    self.done = YES;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    self.renderError = error;
    self.done = YES;
}

@end
