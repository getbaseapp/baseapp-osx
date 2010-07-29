//
//  BNGrowlProjectStatusWrapper.h
//  Flare
//
//  Created by Nick Paulson on 7/29/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BNProject, BNStatus;
@interface BNGrowlProjectStatusWrapper : NSObject {
	BNProject *project;
	BNStatus *status;
	BOOL singleStatus;
}

@property (retain, readonly) BNProject *project;
@property (retain, readonly) BNStatus *status;
@property (assign, readonly, getter=isSingleStatus) BOOL singleStatus;

- (id)initWithProject:(BNProject *)aProject status:(BNStatus *)aStatus singleStatus:(BOOL)isSingle;
+ (BNGrowlProjectStatusWrapper *)wrapperWithProject:(BNProject *)aProject status:(BNStatus *)aStatus singleStatus:(BOOL)isSingle;
- (id)initWithPropertyList:(NSDictionary *)propList;
+ (BNGrowlProjectStatusWrapper *)wrapperWithPropertyList:(NSDictionary *)propList;

- (NSDictionary *)propertyListRepresentation;

@end
