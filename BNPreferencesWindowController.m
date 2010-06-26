//
//  BNPreferencesWindowController.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/24/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNPreferencesWindowController.h"
#import "NSSound+NPSystemSounds.h"
#import "BNAccount.h"
#import "BNActivityController.h"
#import "BNMenuController.h"
#import "NSDictionary+NPAdditions.h"
#import <Sparkle/Sparkle.h>

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

- (void)awakeFromNib {
	if ([[SUUpdater sharedUpdater] lastUpdateCheckDate] == nil) {
		[[SUUpdater sharedUpdater] addObserver:self forKeyPath:@"lastUpdateCheckDate" options:NSKeyValueObservingOptionPrior context:nil];
	} else {
		NSRect newFrame = self.window.frame;
		newFrame.size.height += 25;
		newFrame.origin.y -= 25;
		[self.window setFrame:newFrame display:YES];
	}
}	

- (IBAction)soundPopUpTriggered:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:NSOnState forKey:@"SoundNotificationsEnabled"];
	[[NSSound soundNamed:[sender titleOfSelectedItem]] play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([change containsKey:NSKeyValueChangeNotificationIsPriorKey]) {
		NSDate *oldDate = [object valueForKeyPath:keyPath];
		if (oldDate == nil) {
			NSRect newFrame = self.window.frame;
			newFrame.size.height += 25;
			newFrame.origin.y -= 25;
			[self.window setFrame:newFrame display:YES animate:YES];
			[[SUUpdater sharedUpdater] removeObserver:self forKeyPath:@"lastUpdateCheckDate"];
		}
	}
}

- (void)dealloc {
	self.songNamesArray = nil;
	self.refreshStrings = nil;
	[[SUUpdater sharedUpdater] removeObserver:self forKeyPath:@"lastUpdateCheckDate"];
	[super dealloc];
}

@end
