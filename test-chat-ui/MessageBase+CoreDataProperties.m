//
//  MessageBase+CoreDataProperties.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MessageBase+CoreDataProperties.h"

@implementation MessageBase (CoreDataProperties)

@dynamic type;
@dynamic dateCreated;
@dynamic fromMe;

@end
