//
//  UIImage+OrientationFix.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/27/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "UIImage+OrientationFix.h"

@implementation UIImage(OrientationFix)

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
