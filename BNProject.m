//
//  BNProject.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNProject.h"

static NSString * const BNProjectNameKey = @"BNProjectNameKey";
static NSString * const BNProjectCompanyNameKey = @"BNProjectCompanyNameKey";
static NSString * const BNProjectURLKey = @"BNProjectURLKey";
static NSString * const BNProjectAccountKey = @"BNProjectAccountKey";
static NSString * const BNProjectLatestStatusesKey = @"BNProjectLatestStatusesKey";

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
	if (![otherProject isKindOfClass:[BNProject class]])
		return NO;
	return [[self name] isEqual:[otherProject name]] && [[self companyName] isEqual:[otherProject companyName]] && [[self account] isEqual:[otherProject account]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ (%@)", [self name], [self companyName]];
}

- (NSArray *)latestStatuses {
	return [[latestStatuses retain] autorelease];
}

#pragma mark NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
	BNProject *otherProject = [[[self class] allocWithZone:zone] initWithName:[self name] companyName:[self companyName] URL:[self URL] account:[self account]];
	[otherProject setLatestStatuses:[self latestStatuses]];
	return otherProject;
}

#pragma mark NSCoding Methods

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		if ([decoder allowsKeyedCoding]) {
			self.name = [decoder decodeObjectForKey:BNProjectNameKey];
			self.companyName = [decoder decodeObjectForKey:BNProjectCompanyNameKey];
			self.URL = [decoder decodeObjectForKey:BNProjectURLKey];
			self.account = [decoder decodeObjectForKey:BNProjectAccountKey];
			self.latestStatuses = [decoder decodeObjectForKey:BNProjectLatestStatusesKey];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	if ([aCoder allowsKeyedCoding]) {
		[aCoder encodeObject:self.name forKey:BNProjectNameKey];
		[aCoder encodeObject:self.companyName forKey:BNProjectCompanyNameKey];
		[aCoder encodeObject:self.URL forKey:BNProjectURLKey];
		[aCoder encodeObject:self.account forKey:BNProjectAccountKey];
		[aCoder encodeObject:self.latestStatuses forKey:BNProjectLatestStatusesKey];
	}
}

- (void)dealloc {
	[self setName:nil];
	[self setCompanyName:nil];
	[self setLatestStatuses:nil];
	[self setURL:nil];
	[super dealloc];
}

@end
