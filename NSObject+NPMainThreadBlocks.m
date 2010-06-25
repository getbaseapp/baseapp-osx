//
//  NSObject+NPMainThreadBlocks.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/15/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NSObject+NPMainThreadBlocks.h"

@interface NSObject (NPMainThreadBlocksPrivate)
- (void)_npMainThreadBlockExecute:(void (^)())theBlock;
@end

@implementation NSObject (NPMainThreadBlocks)

- (void)performBlockOnMainThread:(void (^)())theBlock waitUntilDone:(BOOL)wait {
	[self performSelectorOnMainThread:@selector(_npMainThreadBlockExecute:) withObject:theBlock waitUntilDone:wait];
}

- (void)performBlockOnMainThread:(void (^)())theBlock waitUntilDone:(BOOL)wait modes:(NSArray *)modes {
	[self performSelectorOnMainThread:@selector(_npMainThreadBlockExecute:) withObject:theBlock waitUntilDone:wait modes:modes];
}

- (void)_npMainThreadBlockExecute:(void (^)())theBlock {
	theBlock();
}

@end
