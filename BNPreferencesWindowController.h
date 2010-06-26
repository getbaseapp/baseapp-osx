//
//  BNPreferencesWindowController.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/24/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BNAccount;
@interface BNPreferencesWindowController : NSWindowController {
	NSArray *songNamesArray;
	NSArray *refreshStrings;

	IBOutlet NSButton *playSoundButton;
}

@property (retain, readonly) NSArray *songNamesArray;
@property (retain, readonly) NSArray *refreshStrings;

- (IBAction)soundPopUpTriggered:(id)sender;

@end
