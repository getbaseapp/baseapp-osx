//
//  BNPreferencesWindowController.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/24/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BNActivityController.h"

@class BNAccount;
@interface BNPreferencesWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, BNAccountCheckingDelegate> {
	NSArray *songNamesArray;
	NSArray *refreshStrings;

	IBOutlet NSButton *playSoundButton;
	
	IBOutlet NSTableView *accountTableView;
	IBOutlet NSWindow *addAccountSheet;
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *urlPrefixField;
	IBOutlet NSProgressIndicator *loginSpinner;
	IBOutlet NSTextField *accountInfoLabel;
}

@property (retain, readonly) NSArray *songNamesArray;
@property (retain, readonly) NSArray *refreshStrings;

- (IBAction)soundPopUpTriggered:(id)sender;
- (IBAction)addAccountPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)plusButtonPressed:(id)sender;
- (IBAction)minusButtonPressed:(id)sender;

@end
