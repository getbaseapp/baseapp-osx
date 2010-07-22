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
#import "BNLicenseAgreementWindowController.h"

@implementation BNAppDelegate

+ (void)initialize {
	NSMutableDictionary *theDefaults = [NSMutableDictionary dictionary];
	[theDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"GrowlNotificationsEnabled"];
	[theDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"SoundNotificationsEnabled"];
	[theDefaults setObject:[NSNumber numberWithLongLong:300] forKey:@"RefreshInterval"];
	[theDefaults setObject:@"Purr" forKey:@"SelectedSongNotificationName"];
	[theDefaults setObject:[NSNumber numberWithBool:NO]	forKey:@"AcceptedLicenseAgreement"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:theDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSDate *currDate = [NSDate date];
	if ([[currDate laterDate:[NSDate dateWithString:@"2010-08-30 00:00:00 +0000"]] isEqual:currDate]) {
		NSRunAlertPanel(@"Beta Expired", @"This beta version has expired.\nPlease see http://getflareapp.com/ for a new version.", @"OK", nil, nil);
		[NSApp terminate:self];
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AcceptedLicenseAgreement"] == NO) {
		BNLicenseAgreementWindowController *licWinController = [[BNLicenseAgreementWindowController alloc] initWithWindowNibName:@"BNLicenseAgreementWindowController"];
		[licWinController showWindow:self];
		//[licWinController release];
		[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"AcceptedLicenseAgreement" options:NSKeyValueObservingOptionNew context:nil];
	} else {
		[self doFlareSetup];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isEqual:[NSUserDefaults standardUserDefaults]]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AcceptedLicenseAgreement"] == YES) {
			[self doFlareSetup];
		}
	}
}

- (void)doFlareSetup {
	[BNStatusItemController sharedController];
	[BNActivityController sharedController];
	[GrowlApplicationBridge setGrowlDelegate:[BNUserNotificationController sharedController]];
}

@end
