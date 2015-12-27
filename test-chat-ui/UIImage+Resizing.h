//
//  UIImage+Resizing.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/27/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(Resizing)

-(UIImage*)scaleToFillSize:(CGSize)newSize;
-(UIImage*)scaleToFitSize:(CGSize)newSize;

@end
