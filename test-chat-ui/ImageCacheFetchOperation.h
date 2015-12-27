//
//  ImageCacheFetchOperation.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/28/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;
#import "ImageCache.h"

@interface ImageCacheFetchOperation : NSOperation


- (instancetype) initWithFileName: (NSString *) fileName inDirectory: (NSURL *) cacheDirectoryURL size: (CGSize) size completion: (ImageCacheLoadCompletionBlock) completion;

@end
