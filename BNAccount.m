//
//  BNAccount.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/14/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNAccount.h"
#import "EMKeychain.h"

static NSString *BNAccountsCodingKeyUser = @"BNAccountsCodingKeyUser";
static NSString *BNAccountsCodingKeyURL = @"BNAccountsCodingKeyURL";

@interface BNAccount ()
@property (retain, readwrite) NSString *user;
@property (retain, readwrite) NSString *password;
@property (retain, readwrite) NSURL *URL;
@end

@implementation BNAccount
@synthesize user, password, URL, free;

- (id)initWithUser:(NSString *)aUser password:(NSString *)aPassword URL:(NSURL *)aURL {
	if (self = [super init]) {
		[self setFree:YES];
		[self setUser:aUser];
		[self setPassword:aPassword];
		[self setURL:aURL];
	}
	return self;
}

+ (BNAccount *)accountWithUser:(NSString *)aUser password:(NSString *)aPassword URL:(NSURL *)aURL {
	return [[[[self class] alloc] initWithUser:aUser password:aPassword URL:aURL] autorelease];
}

- (BOOL)isComplete {
	return [self user] != nil && [self password] != nil && [self URL] != nil;
}

#pragma mark Accessors

- (void)setUser:(NSString *)newUser {
	if ([[self user] isEqual:newUser])
		return;
	[newUser retain];
	[user release];
	user = newUser;
	if ([self isComplete]) {
		[EMGenericKeychainItem setKeychainPassword:[self password] forUsername:[self user] service:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]]];
	}
}

- (void)setPassword:(NSString *)newPassword {
	if ([[self password] isEqual:newPassword])
		return;
	[newPassword retain];
	[password release];
	password = newPassword;
	if ([self isComplete]) {
		[EMGenericKeychainItem setKeychainPassword:[self password] forUsername:[self user] service:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]]];
	}
}

- (void)setURL:(NSURL *)newURL {
	if ([[self URL] isEqual:newURL])
		return;
	[newURL retain];
	[URL release];
	URL = newURL;
	if ([self isComplete]) {
		[EMGenericKeychainItem setKeychainPassword:[self password] forUsername:[self user] service:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]]];
	}
}

- (id)copyWithZone:(NSZone *)zone {
	return [self retain];
}

#pragma mark NSCoding Methods

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		[self setUser:[decoder decodeObjectForKey:BNAccountsCodingKeyUser]];
		[self setURL:[decoder decodeObjectForKey:BNAccountsCodingKeyURL]];
		[self setPassword:[EMGenericKeychainItem passwordForUsername:[self user] service:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]]]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:[self user] forKey:BNAccountsCodingKeyUser];
	[encoder encodeObject:[self URL] forKey:BNAccountsCodingKeyURL];
}

- (void)dealloc {
	[self setUser:nil];
	[self setPassword:nil];
	[self setURL:nil];
	[super dealloc];
}

@end