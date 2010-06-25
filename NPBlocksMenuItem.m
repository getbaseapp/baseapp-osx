//
//  NPBlocksMenuItem.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NPBlocksMenuItem.h"

@interface NPBlocksMenuItem ()
- (void)_actionTriggered:(NSMenuItem *)theItem;
@end

@implementation NPBlocksMenuItem
@synthesize block;

- (id)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode {
	return [self initWithTitle:aString block:nil keyEquivalent:charCode];
}

- (id)initWithTitle:(NSString *)aString block:(void (^)(NSMenuItem *item))aBlock keyEquivalent:(NSString *)charCode {
	if (self = [super initWithTitle:aString action:@selector(_actionTriggered:) keyEquivalent:charCode]) {
		[self setTarget:self];
		[self setBlock:aBlock];
	}
	return self;
}

- (void)_actionTriggered:(NSMenuItem *)theItem {
	if (theItem == self && [self block] != nil)
			[self block](theItem);
}

@end
