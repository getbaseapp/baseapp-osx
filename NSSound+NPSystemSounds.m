//
//  NSSound+NPSystemSounds.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/25/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NSSound+NPSystemSounds.h"

static NSArray *NPSoundList = nil;

@implementation NSSound (NPSystemSounds)

+ (NSArray *)availableSystemSounds {
	if (NPSoundList == nil) {
		NSString *soundsPath = @"/System/Library/Sounds";
		NSArray *soundFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:soundsPath error:nil];
		NSMutableArray *retArray = [NSMutableArray array];
		for (NSString *aFile in soundFiles) {
			[retArray addObject:[aFile stringByDeletingPathExtension]];
			
			NPSoundList = [retArray retain];
		}
	}
	return NPSoundList;
}

@end
