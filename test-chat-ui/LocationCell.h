//
//  LocationCell.h
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationMessage;
@class MapImageRenderer;

@interface LocationCell : UITableViewCell

- (void) configureWithMessage: (LocationMessage *) message mapRenderer: (MapImageRenderer *) renderer;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (nonatomic, strong) NSOperation *mapRenderingOperation;

@end
