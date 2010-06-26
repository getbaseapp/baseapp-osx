//
//  BNPreferencesWindowController.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/24/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BNAccount;
@interface BNPreferencesWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate> {
	NSArray *songNamesArray;
	NSArray *refreshStrings;

	IBOutlet NSButton *playSoundButton;
	
	IBOutlet NSTableView *accountTableView;
	IBOutlet NSWindow *addAccountSheet;
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *urlPrefixField;
}

@property (retain, readonly) NSArray *songNamesArray;
@property (retain, readonly) NSArray *refreshStrings;

- (IBAction)soundPopUpTriggered:(id)sender;
- (IBAction)addAccountPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)plusButtonPressed:(id)sender;
- (IBAction)minusButtonPressed:(id)sender;

@end
