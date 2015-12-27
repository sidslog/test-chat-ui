//
//  ImageCache.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef void(^ImageCacheSaveCompletionBlock)(NSString *fileName, NSError *error);
typedef void(^ImageCacheLoadCompletionBlock)(UIImage *image, NSString *fileName, NSError *error);

@interface ImageCache : NSObject

+ (instancetype) sharedInstance;
- (void) saveImage: (UIImage *) image withCompletion: (ImageCacheSaveCompletionBlock) completion;
- (void) loadImage: (NSString *) fileName ofSize: (CGSize) size withCompletion: (ImageCacheLoadCompletionBlock) completion;

@end
