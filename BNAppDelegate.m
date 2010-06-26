//
//  BNAppDelegate.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNAppDelegate.h"
#import "BNStatusItemController.h"
#import "BNMenuController.h"
#import "BNStatus.h"
#import "BNProject.h"
#import "BNAccount.h"
#import "BNActivityController.h"
#import <Growl/Growl.h>
#import "BNUserNotificationController.h"

@implementation BNAppDelegate

+ (void)initialize {
	NSMutableDictionary *theDefaults = [NSMutableDictionary dictionary];
	[theDefaults setObject:[NSNumber numberWithInteger:0] forKey:@"GrowlNotificationsEnabled"];
	[theDefaults setObject:[NSNumber numberWithInteger:0] forKey:@"SoundNotificationsEnabled"];
	[theDefaults setObject:[NSNumber numberWithLongLong:60] forKey:@"RefreshInterval"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:theDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[BNStatusItemController sharedController];
	[BNActivityController sharedController];
	[GrowlApplicationBridge setGrowlDelegate:[BNUserNotificationController sharedController]];
}

@end
