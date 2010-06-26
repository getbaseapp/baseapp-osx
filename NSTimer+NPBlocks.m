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

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))theBlock repeats:(BOOL)repeats {
	return [self timerWithTimeInterval:seconds target:self selector:@selector(npTimerBlocksCallback:) userInfo:[[theBlock copy] autorelease] repeats:repeats];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))theBlock repeats:(BOOL)repeats {
	return [self scheduledTimerWithTimeInterval:seconds target:self selector:@selector(npTimerBlocksCallback:) userInfo:[[theBlock copy] autorelease] repeats:repeats];
}

+ (void)npTimerBlocksCallback:(NSTimer *)theTimer {
	void (^my_block)(NSTimer *timer);
	my_block = [theTimer userInfo];
	if (my_block != nil)
		my_block(theTimer);
}


@end