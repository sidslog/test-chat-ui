//
//  ImageCell.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "ImageCell.h"
#import "ImageMessage.h"
#import "ImageCache.h"

static CGFloat const kMaxImageHeight = 150;

@interface ImageCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageTrailing;

@property (nonatomic, strong) NSString* fileName;


@end

@implementation ImageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void) configureWithMessage: (ImageMessage *) message {
    if (message.fromMe.boolValue) {
        self.imageTrailing.active = NO;
        self.imageLeading.active = YES;
    } else {
        self.imageLeading.active = NO;
        self.imageTrailing.active = YES;
    }
    
    CGSize size = [ImageCell imageSizeToPresent:message.width.floatValue height:message.height.floatValue];
    self.imageWidth.constant = size.width;
    self.imageHeight.constant = size.height;
    self.fileName = message.fileName;

    __weak typeof(self) weakSelf = self;
    self.thumbnailView.hidden = YES;
    self.imageFetchOperation = [[ImageCache sharedInstance] loadImage:message.fileName ofSize: size withCompletion:^(UIImage *image, NSString *fileName, NSError *error) {
        if ([[weakSelf fileName] isEqual:fileName]) {
            weakSelf.thumbnailView.hidden = NO;
            weakSelf.thumbnailView.image = image;
        }
    }];
}

+ (CGSize) imageSizeToPresent: (CGFloat) imageWidth height: (CGFloat) imageHeight {
    CGFloat maxImageWidth = [UIScreen mainScreen].bounds.size.width - 60;
    
    CGFloat widthDelta = imageWidth/maxImageWidth;
    CGFloat heightDelta = imageHeight/kMaxImageHeight;
    
    CGFloat maxDelta = MAX(widthDelta, heightDelta);

    CGFloat width = imageWidth / maxDelta;
    CGFloat height = imageHeight / maxDelta;
    
    return CGSizeMake(width, height);
}

@end
