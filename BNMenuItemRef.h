//
//  BNMenuItemRef.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/26/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BNMenuItemRef : NSObject<NSCopying> {
	NSMenuItem *menuItem;
}

@property (retain, readwrite) NSMenuItem *menuItem;

- (id)initWithMenuItem:(NSMenuItem *)theItem;
+ (BNMenuItemRef *)menuItemRef;
+ (BNMenuItemRef *)menuItemRefForMenuItem:(NSMenuItem *)theItem;

@end
