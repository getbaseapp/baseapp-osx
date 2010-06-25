//
//  NSObject+NPMainThreadBlocks.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/15/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (NPMainThreadBlocks)
- (void)performBlockOnMainThread:(void (^)())theBlock waitUntilDone:(BOOL)wait;
- (void)performBlockOnMainThread:(void (^)())theBlock waitUntilDone:(BOOL)wait modes:(NSArray *)modes;
@end
