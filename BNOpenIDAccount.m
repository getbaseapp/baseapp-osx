//
//  BNOpenIDAccount.m
//  Flare
//
//  Created by Nick Paulson on 7/13/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNOpenIDAccount.h"


@implementation BNOpenIDAccount

- (id)initWithAPIToken:(NSString *)theToken URL:(NSURL *)theURL {
	if (self = [super initWithUser:theToken password:@"X" URL:theURL]) {
		
	}
	return self;
}

+ (BNOpenIDAccount *)openIDAccountWithAPIToken:(NSString *)theToken URL:(NSURL *)theURL {
	return [[[[self class] alloc] initWithAPIToken:theToken URL:theURL] autorelease];
}

- (void)setAPIToken:(NSString *)theToken {
	[self willChangeValueForKey:@"APIToken"];
	[self setUser:theToken];
	[self setPassword:@"X"];
	[self didChangeValueForKey:@"APIToken"];
}

- (NSString *)APIToken {
	return [[[self user] retain] autorelease];
}

- (NSString *)password {
	return [[@"X" retain] autorelease];
}

@end
