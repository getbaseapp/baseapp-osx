//
//  NSDictionary+NPAdditions.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/26/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDictionary (NPAdditions)
- (BOOL)containsKey:(id)theKey;
- (BOOL)containsValue:(id)theValue;
- (id)firstKeyForValue:(id)theValue;
- (NSArray *)keysForValue:(id)theValue;
@end
