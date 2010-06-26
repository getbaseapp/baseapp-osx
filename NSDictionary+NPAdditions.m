//
//  NSDictionary+NPAdditions.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/26/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NSDictionary+NPAdditions.h"


@implementation NSDictionary (NPAdditions)

- (BOOL)containsKey:(id)theKey {
	for (id currKey in [self allKeys]) {
		if ([theKey isEqual:currKey])
			return YES;
	}
	return NO;
}

- (BOOL)containsValue:(id)theValue {
	for (id currValue in [self allValues]) {
		if ([theValue isEqual:currValue])
			return YES;
	}
	return NO;
}

- (id)firstKeyForValue:(id)theValue {
	NSArray *theKeys = [self keysForValue:theValue];
	return [theKeys count] > 0 ? [theKeys objectAtIndex:0] : nil;
}

- (NSArray *)keysForValue:(id)theValue {
	NSMutableArray *retArray = [NSMutableArray array];
	for (id currKey in [self allKeys]) {
		if ([[self objectForKey:currKey] isEqual:theValue])
			[retArray addObject:currKey];
	}
	return retArray;
}

@end
