//
//  BNProject.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BNAccount;
@interface BNProject : NSObject <NSCopying> {
	NSArray *latestStatuses;
	NSString *name;
	NSString *companyName;
	NSURL *URL;
	BNAccount *account;
}

@property (retain, readwrite) NSArray *latestStatuses;
@property (retain, readonly) NSString *name;
@property (retain, readonly) NSString *companyName;
@property (retain, readwrite) NSURL *URL;
@property (retain, readonly) BNAccount *account;

- (id)initWithName:(NSString *)aName companyName:(NSString *)compName URL:(NSURL *)theURL account:(BNAccount *)theAccount;
+ (BNProject *)projectWithName:(NSString *)aName companyName:(NSString *)compName URL:(NSURL *)theURL account:(BNAccount *)theAccount;

@end
