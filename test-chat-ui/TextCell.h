//
//  TextCell.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextMessage;

@interface TextCell : UITableViewCell

- (void) configureWithMessage: (TextMessage *) message;

@end
