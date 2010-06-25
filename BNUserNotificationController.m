//
//  BNUserNotificationController.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/25/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNUserNotificationController.h"
#import <Growl/Growl.h>
#import "BNStatus.h"
#import "BNMenuController.h"

@implementation BNUserNotificationController

- (id)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserverForName:BNNewStatusesAddedNotification object:nil queue:nil usingBlock:^(NSNotification *theNotification){
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlNotificationsEnabled"]) {
				[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"Project: %@", [[[theNotification userInfo] objectForKey:@"BNProjectKey"] name]] 
											description:[NSString stringWithFormat:@"%i new status%@ have been added", [[[theNotification userInfo] objectForKey:@"BNNewStatusCountKey"] integerValue], ([[[theNotification userInfo] objectForKey:@"BNNewStatusCountKey"] integerValue] == 1 ? @"" : @"es")] 
									   notificationName:@"BNHasUnreadStatusesGrowlNotification" iconData:nil priority:0 isSticky:NO clickContext:nil];
			}
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SoundNotificationsEnabled"]) {
				[[NSSound soundNamed:[[NSUserDefaults standardUserDefaults] stringForKey:@"SelectedSongNotificationName"]] play];
			}
		}];
	}
	return self;
}

#pragma mark Singleton Methods

static BNUserNotificationController *sharedInstance = nil;

+ (BNUserNotificationController *)sharedController {
	if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedController] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
	
}

- (id)autorelease {
    return self;
}

@end
