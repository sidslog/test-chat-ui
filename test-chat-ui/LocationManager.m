//
//  LocationManager.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation LocationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LocationManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[LocationManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _currentCoordinate = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (void)start {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [manager stopUpdatingLocation];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    _currentCoordinate = location.coordinate;
}

@end
