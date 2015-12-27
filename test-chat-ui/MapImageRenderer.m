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

static CGSize const kMapImageRendererSize = {200, 200};

@interface MapImageRenderer () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, copy) MapImageRendererCompletionBlock completion;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation MapImageRenderer

- (instancetype) initInView: (UIView *) view {
    if (self = [super init]) {
        self.view = view;
    }
    return self;
}

- (void) renderCoordinate: (CLLocationCoordinate2D) coordinate withCompletion: (MapImageRendererCompletionBlock) completion {
    
    UIImage *image = [[MapImageRenderingCache sharedInstance] imageForCoodinate:coordinate];
    if (image) {
        if (completion) {
            completion(self, image, nil);
        }
        return;
    }
    
    if (self.view && completion) {
        self.coordinate = coordinate;
        self.completion = completion;
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, kMapImageRendererSize.width, kMapImageRendererSize.height)];
        self.mapView.showsUserLocation = YES;
        self.mapView.delegate = self;
        self.mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
        [self.view.superview insertSubview:self.mapView atIndex:0];
    }
}

- (void) cancel {
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    float scale = [UIScreen mainScreen].scale;
    CGSize resize = CGSizeMake(self.mapView.bounds.size.width * scale, self.mapView.bounds.size.height * scale);
    UIGraphicsBeginImageContextWithOptions(resize, YES, 0);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    [self.mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [[MapImageRenderingCache sharedInstance] setImage:image forCoordinate:self.coordinate];
    if (self.completion) {
        self.completion(self, image, nil);
    }
    [self.mapView removeFromSuperview];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    [self.mapView removeFromSuperview];
    if (self.completion) {
        self.completion(self, nil, error);
    }
}



@end
