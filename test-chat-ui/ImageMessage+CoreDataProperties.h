//
//  ImageMessage+CoreDataProperties.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ImageMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *fileName;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) NSNumber *height;

@end

NS_ASSUME_NONNULL_END
