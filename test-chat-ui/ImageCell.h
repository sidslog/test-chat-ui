//
//  ImageCell.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageMessage;

@interface ImageCell : UITableViewCell

- (void) configureWithMessage: (ImageMessage *) message;

@property (nonatomic, weak) NSOperation *imageFetchOperation;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@end
