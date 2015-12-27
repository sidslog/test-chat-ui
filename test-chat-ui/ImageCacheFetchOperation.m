//
//  ImageCacheFetchOperation.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/28/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "ImageCacheFetchOperation.h"
@import UIKit;

#import "UIImage+Resizing.h"

@interface ImageCacheFetchOperation ()

@property (nonatomic, copy) ImageCacheLoadCompletionBlock completion;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSURL *cacheDirectoryURL;

@end

@implementation ImageCacheFetchOperation

- (instancetype) initWithFileName: (NSString *) fileName inDirectory: (NSURL *) cacheDirectoryURL size: (CGSize) size completion: (ImageCacheLoadCompletionBlock) completion {
    if (self = [super init]) {
        self.fileName = fileName;
        self.cacheDirectoryURL = cacheDirectoryURL;
        self.size = size;
        self.completion = completion;
    }
    return self;
}


- (void)main {
    
    ImageCacheLoadCompletionBlock completion = self.completion;

    if (!completion || self.isCancelled) {
        return;
    }
    
    NSError *error = nil;
    NSURL *imageURL = [self.cacheDirectoryURL URLByAppendingPathComponent:self.fileName];
    NSData *imageData = [NSData dataWithContentsOfFile:imageURL.path options:0 error:&error];
    
    NSString *fileName = self.fileName;
    if (imageData) {
        __block UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        if (self.isCancelled) {
            image = nil;
            return;
        }
        image = [UIImage decodedImageWithImage:image];
        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(image, fileName, nil);
        });
        image = nil;
    } else {
        if (self.completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, error);
            });
        }
    }
}

@end


