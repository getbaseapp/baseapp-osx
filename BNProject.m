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
@end

@implementation BNProject
@synthesize name, companyName, latestStatuses, URL;

- (id)init {
	return [self initWithName:@"" companyName:@"" URL:nil];
}

- (id)initWithName:(NSString *)aName companyName:(NSString *)compName URL:(NSURL *)theURL {
	if (self = [super init]) {
		[self setName:aName];
		[self setCompanyName:compName];
		[self setURL:theURL];
	}
	return self;
}

+ (BNProject *)projectWithName:(NSString *)aName companyName:(NSString *)compName URL:(NSURL *)theURL {
	return [[[[self class] alloc] initWithName:aName companyName:compName URL:theURL] autorelease];
}

- (BOOL)isEqual:(BNProject *)otherProject {
	return [[self name] isEqual:[otherProject name]] && [[self companyName] isEqual:[otherProject companyName]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ (%@)", [self name], [self companyName]];
}

#pragma mark NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
	BNProject *otherProject = [[[self class] allocWithZone:zone] initWithName:[self name] companyName:[self companyName] URL:[self URL]];
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
