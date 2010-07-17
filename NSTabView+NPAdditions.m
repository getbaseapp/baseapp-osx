//
//  NSTabView+NPAdditions.m
//  Flare
//
//  Created by Nick Paulson on 7/13/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NSTabView+NPAdditions.h"


@implementation NSTabView (NPAdditions)

- (NSInteger)indexOfSelectedTabViewItem {
	return [self indexOfTabViewItem:[self selectedTabViewItem]];
}

@end
