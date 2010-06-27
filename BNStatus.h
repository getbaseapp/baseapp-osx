//
//  BNStatus.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _BNStatusType {
	BNStatusTypeComment = 0,
	BNStatusTypeFileUpload = 1,
	BNStatusTypeTodo = 2,
	BNStatusTypeMessage = 3,
	BNStatusTypeUnknown = 4
} BNStatusType;

@interface BNStatus : NSObject<NSCoding> {
	NSString *creator;
	NSString *title;
	NSDate *date;
	NSURL *URL;
	BNStatusType type;
	BOOL read;
}

@property (retain, readonly) NSString *creator;
@property (retain, readonly) NSString *title;
@property (retain, readonly) NSDate *date;
@property (retain, readonly) NSURL *URL;
@property (readonly) BNStatusType type;
@property (readwrite, getter=isRead) BOOL read;

- (id)initWithTitle:(NSString *)aTitle creator:(NSString *)aCreator URL:(NSURL *)aURL date:(NSDate *)aDate type:(BNStatusType)theType;
+ (BNStatus *)statusWithTitle:(NSString *)aTitle creator:(NSString *)aCreator URL:(NSURL *)aURL date:(NSDate *)aDate type:(BNStatusType)theType;

@end
