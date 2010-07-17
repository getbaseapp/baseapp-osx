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
#import "BNOpenIDAccount.h"

@implementation BNAppDelegate

+ (void)initialize {
	NSMutableDictionary *theDefaults = [NSMutableDictionary dictionary];
	[theDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"GrowlNotificationsEnabled"];
	[theDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"SoundNotificationsEnabled"];
	[theDefaults setObject:[NSNumber numberWithLongLong:300] forKey:@"RefreshInterval"];
	[theDefaults setObject:@"Purr" forKey:@"SelectedSongNotificationName"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:theDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[BNStatusItemController sharedController];
	[BNActivityController sharedController];
	[GrowlApplicationBridge setGrowlDelegate:[BNUserNotificationController sharedController]];
	//[[BNActivityController sharedController] addAccount:[BNOpenIDAccount openIDAccountWithAPIToken:@"309eb835f5def0f316563e881e093371ba90208e" URL:[NSURL URLWithString:@"http://mbe.basecamphq.com"]]];
}

@end
