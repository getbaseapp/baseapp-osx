//
//  BNMenuItemRef.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/26/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNMenuItemRef.h"


@implementation BNMenuItemRef
@synthesize menuItem;

- (id)init {
	return [self initWithMenuItem:nil];
}

- (id)initWithMenuItem:(NSMenuItem *)theItem {
	if (self = [super init]) {
		self.menuItem = theItem;
	}
	return self;
}

+ (BNMenuItemRef *)menuItemRef {
	return [[[[self class] alloc] init] autorelease];
}

+ (BNMenuItemRef *)menuItemRefForMenuItem:(NSMenuItem *)theItem {
	return [[[[self class] alloc] initWithMenuItem:theItem] autorelease];
}

- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithMenuItem:self.menuItem];
}

@end
