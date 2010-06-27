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
#import "BNMenuController.h"
#import "NSDictionary+NPAdditions.h"
#import <Sparkle/Sparkle.h>
#import "BNURLPrefixValueTransformer.h"

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
	
}	

- (IBAction)soundPopUpTriggered:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:NSOnState forKey:@"SoundNotificationsEnabled"];
	[[NSSound soundNamed:[sender titleOfSelectedItem]] play];
}

- (IBAction)plusButtonPressed:(id)sender {
	[NSApp beginSheet:addAccountSheet modalForWindow:self.window modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)minusButtonPressed:(id)sender {
	if ([accountTableView selectedRow] >= 0) {
		BNAccount *theAccount = [[BNActivityController sharedController] accountAtIndex:[accountTableView selectedRow]];
		if (theAccount != nil) {
			[[BNMenuController sharedController] removeProjectsForAccount:theAccount];
			[[BNActivityController sharedController] removeAccount:theAccount];
			[accountTableView reloadData];
		}
	}
}

- (IBAction)addAccountPressed:(id)sender {
	if ([[userField stringValue] length] > 0 && [[passwordField stringValue] length] > 0 && [[urlPrefixField stringValue] length] > 0) {
		BNURLPrefixValueTransformer *transformer = [[BNURLPrefixValueTransformer alloc] init];
		BNAccount *theAccount = [BNAccount accountWithUser:[userField stringValue] password:[passwordField stringValue] URL:[transformer transformedValue:[urlPrefixField stringValue]]];
		[transformer release];
		if (![[BNActivityController sharedController] hasAccount:theAccount]) {
			[[BNActivityController sharedController] checkAccountCredentials:theAccount delegate:self];
			[loginSpinner setHidden:NO];
			[loginSpinner startAnimation:self];
			[accountInfoLabel setHidden:YES];
		} else {
			[accountInfoLabel setHidden:NO];
			[accountInfoLabel setStringValue:@"Account already added"];
			NSBeep();
		}
	}
}

- (void)checkedCredentialsForAccount:(BNAccount *)theAccount success:(BOOL)success {
	[loginSpinner setHidden:YES];
	[loginSpinner stopAnimation:self];
	if (success) {
		[[BNActivityController sharedController] addAccount:theAccount];
		[addAccountSheet orderOut:nil];
		[NSApp endSheet:addAccountSheet];
		[accountTableView reloadData];
		[userField setStringValue:@""];
		[passwordField setStringValue:@""];
		[urlPrefixField setStringValue:@""];
		[addAccountSheet makeFirstResponder:urlPrefixField];
	} else {
		[accountInfoLabel setStringValue:@"Login failed"];
		[accountInfoLabel setHidden:NO];
		NSBeep();
	}
}

- (IBAction)cancelButtonPressed:(id)sender {
	[addAccountSheet orderOut:nil];
	[NSApp endSheet:addAccountSheet];
}

#pragma mark NSTableView Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [[BNActivityController sharedController] accountCount];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	BNAccount *theAccount = [[BNActivityController sharedController] accountAtIndex:rowIndex];
	if ([[aTableColumn identifier] isEqualToString:@"accountUserColumn"])
		return theAccount.user;
	else if ([[aTableColumn identifier] isEqualToString:@"basecampURLColumn"])
		return [theAccount.URL absoluteString];
	return nil;
}

- (void)dealloc {
	self.songNamesArray = nil;
	self.refreshStrings = nil;
	[[SUUpdater sharedUpdater] removeObserver:self forKeyPath:@"lastUpdateCheckDate"];
	[super dealloc];
}

@end
