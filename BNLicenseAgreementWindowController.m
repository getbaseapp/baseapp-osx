//
//  BNLicenseAgreementWindowController.m
//  Flare
//
//  Created by Nick Paulson on 7/22/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNLicenseAgreementWindowController.h"
#import "NSObject+NPDelayedBlocks.h"


@implementation BNLicenseAgreementWindowController

- (void)awakeFromNib {
	[textView readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"SLAFlareAppBeta" ofType:@"rtf"]];
}

- (IBAction)agreeButtonPressed:(id)sender {
	[self performBlock:^{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AcceptedLicenseAgreement"];
		[self release];
	} afterDelay:0.01];
	
	[self.window close];
}

- (IBAction)disagreeButtonPressed:(id)sender {
	[NSApp terminate:self];
}

@end
