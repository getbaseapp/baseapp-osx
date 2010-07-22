//
//  NSObject+NPDelayedBlocks.m
//  Flare
//
//  Created by Nick Paulson on 7/22/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NSObject+NPDelayedBlocks.h"

@implementation NSObject (NPDelayedBlocks)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
	[[[block copy] autorelease] performSelector:@selector(_npPerformDelayedBlockCallback) withObject:nil afterDelay:delay];
}

- (void)_npPerformDelayedBlockCallback {
	void (^block)(void) = (id)self;
	block();
}

@end
