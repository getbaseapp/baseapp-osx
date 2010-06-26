//
//  NSMenu+NPAdditions.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/26/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NSMenu+NPAdditions.h"


@implementation NSMenu (NPAdditions)

- (BOOL)containsItem:(NSMenuItem *)theItem {
	return [[self itemArray] containsObject:theItem];
}

@end
