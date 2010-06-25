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
	BOOL free;
}

@property (retain, readonly) NSString *user;
@property (retain, readonly) NSString *password;
@property (retain, readonly) NSURL *URL;
@property (assign, readwrite, getter=isFree) BOOL free;

- (id)initWithUser:(NSString *)aUser password:(NSString *)aPassword URL:(NSURL *)aURL;
+ (BNAccount *)accountWithUser:(NSString *)aUser password:(NSString *)aPassword URL:(NSURL *)aURL;
- (BOOL)isComplete;

@end
