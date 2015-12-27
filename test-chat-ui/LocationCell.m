//
//  LocationCell.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "LocationCell.h"
#import "LocationMessage.h"
#import "MapImageRenderer.h"

@interface LocationCell ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageTrailing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageLeading;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation LocationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbnailView.image = nil;
}

- (void) configureWithMessage: (LocationMessage *) message mapRenderer: (MapImageRenderer *) renderer {
    if (message.fromMe.boolValue) {
        self.imageTrailing.active = NO;
        self.imageLeading.active = YES;
    } else {
        self.imageLeading.active = NO;
        self.imageTrailing.active = YES;
    }
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(message.latitude.floatValue, message.longitude.floatValue);
    self.coordinate = coordinate;
    __weak typeof(self) weakSelf = self;
    
    self.thumbnailView.hidden = YES;
    
    self.mapRenderingOperation = [renderer renderCoordinate:self.coordinate withCompletion:^(CLLocationCoordinate2D coordinate, UIImage *image, NSError *error) {
        if (coordinate.latitude == weakSelf.coordinate.latitude && coordinate.longitude == weakSelf.coordinate.longitude) {
            weakSelf.thumbnailView.image = image;
            weakSelf.thumbnailView.hidden = NO;
            weakSelf.mapRenderingOperation = nil;
        }
    }];
    
    if (self.thumbnailView.hidden == YES) {
        [self.activityIndicator startAnimating];
    }
}

@end
