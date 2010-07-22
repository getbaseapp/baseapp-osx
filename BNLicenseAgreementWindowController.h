//
//  BNLicenseAgreementWindowController.h
//  Flare
//
//  Created by Nick Paulson on 7/22/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BNLicenseAgreementWindowController : NSWindowController {
	IBOutlet NSTextView *textView;
}

- (IBAction)agreeButtonPressed:(id)sender;
- (IBAction)disagreeButtonPressed:(id)sender;

@end
