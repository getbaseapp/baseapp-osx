//
//  BNAccount.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/14/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BNAccount : NSObject<NSCoding, NSCopying> {
	NSString *user;
	NSString *password;
	NSURL *URL;
	NSString *URLPrefix;
	BOOL free;
}

@property (retain, readwrite) NSString *user;
@property (retain, readwrite) NSString *password;
@property (retain, readwrite) NSURL *URL;
@property (assign, readwrite, getter=isFree) BOOL free;

- (id)initWithUser:(NSString *)aUser password:(NSString *)aPassword URL:(NSURL *)aURL;
+ (BNAccount *)accountWithUser:(NSString *)aUser password:(NSString *)aPassword URL:(NSURL *)aURL;
- (BOOL)isComplete;

@end
