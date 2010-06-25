//
//  BNPreferencesWindowController.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/24/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNPreferencesWindowController.h"
#import "NSSound+NPSystemSounds.h"

@interface BNPreferencesWindowController ()
@property (retain, readwrite) NSArray *songNamesArray;
@property (retain, readwrite) NSArray *refreshStrings;
@end

@implementation BNPreferencesWindowController
@synthesize songNamesArray, refreshStrings;

- (id)initWithWindowNibName:(NSString *)windowNibName {
	if (self = [super initWithWindowNibName:windowNibName]) {
		self.songNamesArray = [[NSSound availableSystemSounds] retain];
		self.refreshStrings = [NSArray arrayWithObjects:@"1 minute", @"5 minutes", @"15 minutes", @"30 minutes", nil];
		
	}
	return self;
}

- (IBAction)soundPopUpTriggered:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:NSOnState forKey:@"SoundNotificationsEnabled"];
	[[NSSound soundNamed:[sender titleOfSelectedItem]] play];
}

- (void)dealloc {
	self.songNamesArray = nil;
	self.refreshStrings = nil;
	[super dealloc];
}

@end
