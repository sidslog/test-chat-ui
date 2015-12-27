//
//  ImageCache.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "ImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIImage+Resizing.h"

@interface ImageCache ()

@property (nonatomic, strong) NSURL *cacheDirectoryURL;
@property (nonatomic, strong) NSCache *cachedImages;

@end

@implementation ImageCache

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static ImageCache *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ImageCache alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cachedImages = [[NSCache alloc] init];
        self.cachedImages.countLimit = 20;
        
        NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
        self.cacheDirectoryURL = [documentsURL URLByAppendingPathComponent:@"ImageCache"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if (![fileManager fileExistsAtPath:self.cacheDirectoryURL.path isDirectory:&isDirectory]) {
            NSError *error = nil;
            BOOL result = [fileManager createDirectoryAtURL:self.cacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
            NSAssert(result, @"couldn't create image cache directory: %@", error);
        } else {
            if (!isDirectory) {
                NSAssert(NO, @"image cache is not a directory: %@", self.cacheDirectoryURL);
            }
        }
        
    }
    return self;
}

- (void) saveImage: (UIImage *) image withCompletion: (ImageCacheSaveCompletionBlock) completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *fileName = [ImageCache sha256String:imageData];
        NSURL *imageURL = [self.cacheDirectoryURL URLByAppendingPathComponent:fileName];
        NSError *error = nil;
        if ([imageData writeToURL:imageURL options:NSDataWritingAtomic error:&error]) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(fileName, nil);
                });
            }
        } else {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
        }
    });
}

- (void) loadImage: (NSString *) fileName ofSize: (CGSize) size withCompletion: (ImageCacheLoadCompletionBlock) completion {
    
    NSString *cacheKey = [self cacheKey:fileName size:size];
    if ([self.cachedImages objectForKey:cacheKey]) {
        if (completion) {
            completion([self.cachedImages objectForKey:cacheKey], fileName, nil);
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSURL *imageURL = [self.cacheDirectoryURL URLByAppendingPathComponent:fileName];
        NSData *imageData = [NSData dataWithContentsOfFile:imageURL.path options:0 error:&error];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            image = [image scaleToFillSize:size];
            [self.cachedImages setObject:image forKey:cacheKey];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image, fileName, nil);
                });
            }
        } else {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil, error);
                });
            }
        }
    });
}

- (NSString *) cacheKey: (NSString *) fileName size: (CGSize) size {
    return [NSString stringWithFormat:@"%@-%f-%f", fileName, size.width, size.height];
}

+ (NSString *)sha256String:(NSData *)data {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    if ( CC_SHA1([data bytes], (int)[data length], hash) ) {
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", hash[i]];
        }
        return output;
    }
    return nil;
}

@end