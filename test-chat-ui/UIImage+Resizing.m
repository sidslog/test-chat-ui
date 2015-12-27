//
//  UIImage+Resizing.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/27/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "UIImage+Resizing.h"

static CGColorSpaceRef __rgbColorSpace = NULL;
#define kNyxNumberOfComponentsPerARBGPixel 4

CGColorSpaceRef NYXGetRGBColorSpace(void)
{
    if (!__rgbColorSpace)
    {
        __rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return __rgbColorSpace;
}

CGContextRef NYXCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow, BOOL withAlpha)
{
    /// Use the generic RGB color space
    /// We avoid the NULL check because CGColorSpaceRelease() NULL check the value anyway, and worst case scenario = fail to create context
    /// Create the bitmap context, we want pre-multiplied ARGB, 8-bits per component
    CGImageAlphaInfo alphaInfo = (withAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst);
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, bytesPerRow, NYXGetRGBColorSpace(), kCGBitmapByteOrderDefault | alphaInfo);
    
    return bmContext;
}

BOOL NYXImageHasAlpha(CGImageRef imageRef)
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
    
    return hasAlpha;
}

@implementation UIImage(Resizing)

-(UIImage*)scaleToFitSize:(CGSize)newSize
{
    /// Keep aspect ratio
    size_t destWidth, destHeight;
    if (self.size.width > self.size.height)
    {
        destWidth = (size_t)newSize.width;
        destHeight = (size_t)(self.size.height * newSize.width / self.size.width);
    }
    else
    {
        destHeight = (size_t)newSize.height;
        destWidth = (size_t)(self.size.width * newSize.height / self.size.height);
    }
    if (destWidth > newSize.width)
    {
        destWidth = (size_t)newSize.width;
        destHeight = (size_t)(self.size.height * newSize.width / self.size.width);
    }
    if (destHeight > newSize.height)
    {
        destHeight = (size_t)newSize.height;
        destWidth = (size_t)(self.size.width * newSize.height / self.size.height);
    }
    return [self scaleToFillSize:CGSizeMake(destWidth, destHeight)];
}


-(UIImage*)scaleToFillSize:(CGSize)newSize
{
    size_t destWidth = (size_t)(newSize.width * self.scale);
    size_t destHeight = (size_t)(newSize.height * self.scale);
    if (self.imageOrientation == UIImageOrientationLeft
        || self.imageOrientation == UIImageOrientationLeftMirrored
        || self.imageOrientation == UIImageOrientationRight
        || self.imageOrientation == UIImageOrientationRightMirrored)
    {
        size_t temp = destWidth;
        destWidth = destHeight;
        destHeight = temp;
    }
    
    /// Create an ARGB bitmap context
    CGContextRef bmContext = NYXCreateARGBBitmapContext(destWidth, destHeight, destWidth * kNyxNumberOfComponentsPerARBGPixel, NYXImageHasAlpha(self.CGImage));
    if (!bmContext)
        return nil;
    
    /// Image quality
    CGContextSetShouldAntialias(bmContext, true);
    CGContextSetAllowsAntialiasing(bmContext, true);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
    /// Draw the image in the bitmap context
    
    UIGraphicsPushContext(bmContext);
    CGContextDrawImage(bmContext, CGRectMake(0.0f, 0.0f, destWidth, destHeight), self.CGImage);
    UIGraphicsPopContext();
    
    /// Create an image object from the context
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage* scaled = [UIImage imageWithCGImage:scaledImageRef scale:self.scale orientation:self.imageOrientation];
    
    /// Cleanup
    CGImageRelease(scaledImageRef);
    CGContextRelease(bmContext);
    
    return scaled;
}

@end
