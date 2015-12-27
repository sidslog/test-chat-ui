//
//  TextCell.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "TextCell.h"
#import "TextMessage.h"

@interface TextCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;

@end

@implementation TextCell

- (void)awakeFromNib {
    // Initialization code
}

- (void) configureWithMessage: (TextMessage *) message {
    self.leadingConstraint.constant = message.fromMe.boolValue ? 20 : 50;
    self.trailingConstraint.constant = message.fromMe.boolValue ? 50 : 20;
    self.label.textAlignment = message.fromMe.boolValue ? NSTextAlignmentLeft : NSTextAlignmentRight;
    self.label.text = message.value;
}

@end
