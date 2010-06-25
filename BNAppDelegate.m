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
	[theDefaults setObject:@"npaulson" forKey:@"user"];
	[theDefaults setObject:@"nqhp2p" forKey:@"password"];
	[theDefaults setObject:@"http://bylinebreak.basecamphq.com/" forKey:@"url"];
	[theDefaults setObject:@"Morse" forKey:@"SelectedSongNotificationName"];
	[theDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"GrowlNotificationsEnabled"];
	[theDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"SoundNotificationsEnabled"];
	[theDefaults setObject:[NSNumber numberWithLongLong:60] forKey:@"RefreshInterval"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:theDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[BNStatusItemController sharedController];
	[[BNActivityController sharedController] addAccount:[BNAccount accountWithUser:[[NSUserDefaults standardUserDefaults] stringForKey:@"user"] password:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"] URL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"url"]]]];
	
	[GrowlApplicationBridge setGrowlDelegate:[BNUserNotificationController sharedController]];
}

@end
