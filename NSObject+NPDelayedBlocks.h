//
//  NSObject+NPDelayedBlocks.h
//  Flare
//
//  Created by Nick Paulson on 7/22/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (NPDelayedBlocks)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
