//
//  BNProject.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNProject.h"

@interface BNProject ()
@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSString *companyName;
@property (retain, readwrite) BNAccount *account;
@end

@implementation BNProject
@synthesize name, companyName, latestStatuses, URL, account;

- (id)init {
	return [self initWithName:@"" companyName:@"" URL:nil account:nil];
}

- (id)initWithName:(NSString *)aName companyName:(NSString *)compName URL:(NSURL *)theURL account:(BNAccount *)theAccount {
	if (self = [super init]) {
		[self setName:aName];
		[self setCompanyName:compName];
		[self setURL:theURL];
		[self setAccount:theAccount];
	}
	return self;
}

+ (BNProject *)projectWithName:(NSString *)aName companyName:(NSString *)compName URL:(NSURL *)theURL account:(BNAccount *)theAccount {
	return [[[[self class] alloc] initWithName:aName companyName:compName URL:theURL account:theAccount] autorelease];
}

- (BOOL)isEqual:(BNProject *)otherProject {
	return [[self name] isEqual:[otherProject name]] && [[self companyName] isEqual:[otherProject companyName]] && [[self account] isEqual:[otherProject account]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ (%@)", [self name], [self companyName]];
}

#pragma mark NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
	BNProject *otherProject = [[[self class] allocWithZone:zone] initWithName:[self name] companyName:[self companyName] URL:[self URL] account:[self account]];
	[otherProject setLatestStatuses:[self latestStatuses]];
	return otherProject;
}

- (void)dealloc {
	[self setName:nil];
	[self setCompanyName:nil];
	[self setLatestStatuses:nil];
	[self setURL:nil];
	[super dealloc];
}

@end
