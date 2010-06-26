//
//  BNStatus.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNStatus.h"

@interface BNStatus ()
@property (retain, readwrite) NSString *creator;
@property (retain, readwrite) NSString *title;
@property (retain, readwrite) NSDate *date;
@property (retain, readwrite) NSURL *URL;
@property (readwrite) BNStatusType type;
@end

@implementation BNStatus
@synthesize creator, title, URL, date, type, read;

- (id)init {
	return [self initWithTitle:@"" creator:@"" URL:[NSURL URLWithString:@"http://basecamphq.com/"] date:[NSDate date] type:BNStatusTypeUnknown];
}

- (id)initWithTitle:(NSString *)aTitle creator:(NSString *)aCreator URL:(NSURL *)aURL date:(NSDate *)aDate type:(BNStatusType)theType {
	if (self = [super init]) {
		[self setTitle:aTitle];
		[self setCreator:aCreator];
		[self setURL:aURL];
		[self setDate:aDate];
		[self setType:theType];
	}
	return self;
}

+ (BNStatus *)statusWithTitle:(NSString *)aTitle creator:(NSString *)aCreator URL:(NSURL *)aURL date:(NSDate *)aDate type:(BNStatusType)theType {
	return [[[[self class] alloc] initWithTitle:aTitle creator:aCreator URL:aURL date:aDate type:theType] autorelease];
}

- (BOOL)isEqual:(BNStatus *)otherStatus {
	if (![otherStatus isKindOfClass:[BNStatus class]])
		return NO;
	return [[self title] isEqual:[otherStatus title]] && 
	[[self creator] isEqual:[otherStatus creator]] &&
	[[self URL] isEqual:[otherStatus URL]] &&
	[[self date] isEqual:[otherStatus date]] &&
	[self type] == [otherStatus type];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ (%@)", [self title], [self isRead] ? @"READ" : @"UNREAD"];
}

- (void)dealloc {
	[self setCreator:nil];
	[self setTitle:nil];
	[self setDate:nil];
	[self setURL:nil];
	[super dealloc];
}

@end
