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

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) MapImageRenderer *renderer;

@end

@implementation LocationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse {
    [self.renderer cancel];
    self.renderer = nil;
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
    
    self.renderer = renderer;
    [self.renderer renderCoordinate:self.coordinate withCompletion:^(MapImageRenderer *renderer, UIImage *image, NSError *error) {
        if (renderer == self.renderer) {
            weakSelf.thumbnailView.image = image;
            weakSelf.thumbnailView.hidden = NO;
        }
    }];
}

@end
