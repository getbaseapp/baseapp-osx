//
//  NPBlocksMenuItem.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NPBlocksMenuItem : NSMenuItem {
	void (^block)(NSMenuItem *item);
}

@property (copy, readwrite) void (^block)(NSMenuItem *item);

- (id)initWithTitle:(NSString *)aString block:(void (^)(NSMenuItem *item))aBlock keyEquivalent:(NSString *)charCode;

@end
