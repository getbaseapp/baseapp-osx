//
//  BNAccount.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/14/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNAccount.h"
#import "EMKeychain.h"

static NSString * const BNAccountsCodingKeyUser = @"BNAccountsCodingKeyUser";
static NSString * const BNAccountsCodingKeyURL = @"BNAccountsCodingKeyURL";


@implementation BNAccount
@synthesize user, password, URL, free;

- (id)init {
	if (self = [self initWithUser:nil password:nil URL:nil]) {
		
	}
	return self;
}

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
	return [self user] != nil && [[self user] length] > 0 && [self password] != nil && [[self password] length] > 0 && [self URL] != nil && [[[self URL] absoluteString] length] > 0;
}

- (void)writeToKeychain {
	if ([self isComplete]) {
		[EMGenericKeychainItem setKeychainPassword:[self password] forUsername:[self user] service:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]]];
	}
}

- (void)removeFromKeychain {
	if ([self isComplete]) {
		EMGenericKeychainItem *theItem = [EMGenericKeychainItem genericKeychainItemForService:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]] withUsername:[self user]];
		if (theItem == nil)
			theItem = [EMGenericKeychainItem addGenericKeychainItemForService:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]] withUsername:[self user] password:[self password]];
		[theItem remove];
	}
}

- (void)setPasswordFromKeychain {
	self.password = [EMGenericKeychainItem passwordForUsername:[self user] service:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]]];
}

- (NSString *)description {
	return self.user;
}

- (BOOL)isEqual:(BNAccount *)object {
	if (![object isKindOfClass:[BNAccount class]])
		return NO;
	return [self.user isEqual:object.user] && [self.URL isEqual:object.URL] && [self.password isEqual:object.password];
}

#pragma mark Accessors

- (void)setUser:(NSString *)newUser {
	if (user == newUser)
		return;
	[self willChangeValueForKey:@"user"];
	[newUser retain];
	[user release];
	user = newUser;
	[self didChangeValueForKey:@"user"];
}

- (void)setPassword:(NSString *)newPassword {
	if (password == newPassword)
		return;
	[self willChangeValueForKey:@"password"];
	[newPassword retain];
	[password release];
	password = newPassword;
	[self didChangeValueForKey:@"password"];
}

- (void)setURL:(NSURL *)newURL {
	if (URL == newURL)
		return;
	[self willChangeValueForKey:@"URL"];
	[newURL retain];
	[URL release];
	URL = newURL;
	[self didChangeValueForKey:@"URL"];
}

- (id)copyWithZone:(NSZone *)zone {
	return [self retain];
}

#pragma mark NSCoding Methods

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		[self setUser:[decoder decodeObjectForKey:BNAccountsCodingKeyUser]];
		[self setURL:[decoder decodeObjectForKey:BNAccountsCodingKeyURL]];
		EMGenericKeychainItem *theItem = [EMGenericKeychainItem genericKeychainItemForService:[NSString stringWithFormat:@"Basecamp: %@", [[self URL] absoluteString]] withUsername:[self user]];
		if (theItem != nil)
			self.password = [theItem password];
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