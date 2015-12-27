//
//  MapImageRenderer.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "MapImageRenderer.h"
#import "MapImageRenderingCache.h"
@import MapKit;

static BOOL kMapViewDidEndRendering = NO;

static CGSize const kMapImageRendererSize = {200, 200};

@interface MapImageRenderingOperation : NSOperation

- (instancetype)initWithMapView: (MKMapView *) mapView coordinate: (CLLocationCoordinate2D) coordinate completion: (MapImageRendererCompletionBlock) completion;

@end

@interface MapImageRenderingOperation () <MKMapViewDelegate>

@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) MapImageRendererCompletionBlock completion;

@property (atomic, assign) BOOL done;
@property (nonatomic, strong) NSError *renderError;

@end

@implementation MapImageRenderingOperation

- (instancetype)initWithMapView: (MKMapView *) mapView coordinate: (CLLocationCoordinate2D) coordinate completion: (MapImageRendererCompletionBlock) completion {
    if (self = [super init]) {
        self.mapView = mapView;
        self.coordinate = coordinate;
        self.completion = completion;
        self.done = NO;
    }
    return self;
}

- (void)main {
    [NSThread sleepForTimeInterval:0.3];

    if (self.isCancelled) {
        NSLog(@"cancelld map 1");
        return;
    }
    
    __block foundInCache = NO;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
       
        UIImage *image = [[MapImageRenderingCache sharedInstance] imageForCoodinate:self.coordinate];
        if (image) {
            if (self.completion) {
                self.completion(self.coordinate, image, nil);
            }
            foundInCache = YES;
        } else {
            self.mapView.delegate = self;
            self.mapView.region = MKCoordinateRegionMakeWithDistance(self.coordinate, 500, 500);
        }
    });
    
    if (foundInCache) {
        return;
    }
    
    if (self.isCancelled) {
        NSLog(@"cancelld map 2");
        return;
    }

    while (!self.isCancelled && !self.done) {
        [[NSRunLoop currentRunLoop] run];
    }
    
    if (self.isCancelled) {
        NSLog(@"cancelld map 3");
        return;
    }
    
    if (!self.renderError) {
//        dispatch_sync(dispatch_get_main_queue(), ^{
            [self renderMapLayer];
//        });
        
    } else {
        CLLocationCoordinate2D coordinate = self.coordinate;
        MapImageRendererCompletionBlock completion = self.completion;
        NSError *error = self.renderError;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(coordinate, nil, error);
            });
        }
    }
    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        self.mapView.region = MKCoordinateRegionMakeWithDistance(self.coordinate, 1000, 1000);
//    });

}

- (void) renderMapLayer {
    
//    size_t width = self.mapView.bounds.size.width;
//    size_t height = self.mapView.bounds.size.height;
//    
//    unsigned char *imageBuffer = (unsigned char *)malloc(width*height*4);
//    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
//    
//    CGContextRef imageContext =
//    CGBitmapContextCreate(imageBuffer, width, height, 8, width*4, colourSpace,
//                          kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
//    
//    CGColorSpaceRelease(colourSpace);
//    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [self.mapView.layer renderInContext:imageContext];
//    });
//    
//    CGImageRef outputImage = CGBitmapContextCreateImage(imageContext);
//    
//    UIImage *image = [UIImage imageWithCGImage:outputImage];
//    
//    CGImageRelease(outputImage);
//    CGContextRelease(imageContext);
//    free(imageBuffer);
//
    
    
    
    float scale = [UIScreen mainScreen].scale;
    CGSize resize = CGSizeMake(self.mapView.bounds.size.width * scale, self.mapView.bounds.size.height * scale);
    UIGraphicsBeginImageContextWithOptions(resize, YES, 0);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.isCancelled) {
        NSLog(@"cancelld map 5");
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.mapView.layer renderInContext:context];
        if (self.isCancelled) {
            NSLog(@"cancelld map 6");
            return;
        }
    });
    if (self.isCancelled) {
        NSLog(@"cancelld map 4");
        UIGraphicsEndImageContext();
        return;
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CLLocationCoordinate2D coordinate = self.coordinate;

    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [[MapImageRenderingCache sharedInstance] setImage:image forCoordinate:coordinate];
    });
    
    MapImageRendererCompletionBlock completion = self.completion;
    if (self.isCancelled) {
        NSLog(@"cancelld map 4");
        return;
    }

    dispatch_sync(dispatch_get_main_queue(), ^{
        if (completion) {
            completion(coordinate, image, nil);
        }
    });
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    NSLog(@"will start region change");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"did finish region change");
    if (kMapViewDidEndRendering) {
        self.done = YES;
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    NSLog(@"will start loading");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    NSLog(@"did finish loading");
}

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView {
    NSLog(@"will start rendering");
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    self.done = YES;
    kMapViewDidEndRendering = YES;
    NSLog(@"did end rendering");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    self.renderError = error;
    self.done = YES;
}


@end

@interface MapImageRenderer () <MKMapViewDelegate>

@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation MapImageRenderer

- (instancetype) initInView: (UIView *) view {
    if (self = [super init]) {
        self.view = view;
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, kMapImageRendererSize.width, kMapImageRendererSize.height)];
        [self.view.superview insertSubview:mapView atIndex:0];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.mapView = mapView;
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

    NSOperation *operation = [[MapImageRenderingOperation alloc] initWithMapView:self.mapView coordinate:coordinate completion:completion];
    [self.operationQueue addOperation:operation];
    return operation;
    
}

//- (void) cancel {
//    [self.mapView removeFromSuperview];
//    self.mapView.delegate = nil;
//    self.mapView = nil;
//}

//- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
//    float scale = [UIScreen mainScreen].scale;
//    CGSize resize = CGSizeMake(self.mapView.bounds.size.width * scale, self.mapView.bounds.size.height * scale);
//    UIGraphicsBeginImageContextWithOptions(resize, YES, 0);
//    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
//    [self.mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
////    [[MapImageRenderingCache sharedInstance] setImage:image forCoordinate:self.coordinate];
//    if (self.completion) {
//        self.completion(self, image, nil);
//    }
//    [self.mapView removeFromSuperview];
//    self.mapView.delegate = nil;
//    self.mapView = nil;
//}
//
//- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
//    [self.mapView removeFromSuperview];
//    if (self.completion) {
//        self.completion(self, nil, error);
//    }
//}

@end
