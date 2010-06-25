//
//  NSTimer+NPBlocks.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/24/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NSTimer+NPBlocks.h"

@interface NSTimer (NPBlocksPrivate)
- (void)_npTimerBlocksCallback:(NSTimer *)theTimer;
@end

@implementation NSTimer (NPBlocks)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)())theBlock repeats:(BOOL)repeats {
	return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(_npTimerBlocksCallback:) userInfo:[[theBlock copy] autorelease] repeats:repeats];
}

+ (void)_npTimerBlocksCallback:(NSTimer *)theTimer {
	void (^my_block)(void);
	my_block = [theTimer userInfo];
	if (my_block != nil)
		my_block();
}

@end
