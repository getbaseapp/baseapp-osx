//
//  BNProject.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BNProject : NSObject <NSCopying> {
	NSArray *latestStatuses;
	NSString *name;
	NSString *companyName;
	NSURL *URL;
}

@property (retain, readwrite) NSArray *latestStatuses;
@property (retain, readonly) NSString *name;
@property (retain, readonly) NSString *companyName;
@property (retain, readwrite) NSURL *URL;

- (id)initWithName:(NSString *)aName companyName:(NSString *)compName URL:(NSURL *)theURL;
+ (BNProject *)projectWithName:(NSString *)aName companyName:(NSString *)compName URL:(NSURL *)theURL;

@end
