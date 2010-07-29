//
//  BNGrowlProjectStatusWrapper.m
//  Flare
//
//  Created by Nick Paulson on 7/29/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNGrowlProjectStatusWrapper.h"

@interface BNGrowlProjectStatusWrapper ()
@property (retain, readwrite) BNProject *project;
@property (retain, readwrite) BNStatus *status;
@property (assign, readwrite, getter=isSingleStatus) BOOL singleStatus;
@end

static NSString * const BNGrowlProjectStatusWrapperProjectKey = @"BNGrowlProjectStatusWrapperProjectKey";
static NSString * const BNGrowlProjectStatusWrapperStatusKey = @"BNGrowlProjectStatusWrapperStatusKey";
static NSString * const BNGrowlProjectStatusWrapperSingleStatusKey = @"BNGrowlProjectStatusWrapperSingleStatusKey";

@implementation BNGrowlProjectStatusWrapper
@synthesize project, status, singleStatus;

- (id)initWithProject:(BNProject *)aProject status:(BNStatus *)aStatus singleStatus:(BOOL)isSingle {
	if (self = [super init]) {
		self.project = aProject;
		self.status = aStatus;
		self.singleStatus = isSingle;
	}
	return self;
}

+ (BNGrowlProjectStatusWrapper *)wrapperWithProject:(BNProject *)aProject status:(BNStatus *)aStatus singleStatus:(BOOL)isSingle {
	return [[[[self class] alloc] initWithProject:aProject status:aStatus singleStatus:isSingle] autorelease];
}

- (id)initWithPropertyList:(NSDictionary *)propList {
	BNProject *theProject = [NSKeyedUnarchiver unarchiveObjectWithData:[propList objectForKey:BNGrowlProjectStatusWrapperProjectKey]];
	BNStatus *theStatus = [NSKeyedUnarchiver unarchiveObjectWithData:[propList objectForKey:BNGrowlProjectStatusWrapperStatusKey]];
	BOOL single = [[propList objectForKey:BNGrowlProjectStatusWrapperSingleStatusKey] boolValue];
	return [self initWithProject:theProject status:theStatus singleStatus:single];
}

+ (BNGrowlProjectStatusWrapper *)wrapperWithPropertyList:(NSDictionary *)propList {
	return [[[[self class] alloc] initWithPropertyList:propList] autorelease];
}

- (NSDictionary *)propertyListRepresentation {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSKeyedArchiver archivedDataWithRootObject:self.project], BNGrowlProjectStatusWrapperProjectKey,
			[NSKeyedArchiver archivedDataWithRootObject:self.status], BNGrowlProjectStatusWrapperStatusKey,
			[NSNumber numberWithBool:self.singleStatus], BNGrowlProjectStatusWrapperSingleStatusKey, nil];
}

- (void)dealloc {
	self.project = nil;
	self.status = nil;
	[super dealloc];
}

@end
