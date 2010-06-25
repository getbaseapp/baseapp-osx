//
//  BNStatusItemController.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const BNAllStatusesReadNotification;
extern NSString * const BNHasUnreadStatusesNotification;

@interface BNStatusItemController : NSObject {
	BOOL hasUnread;
	NSStatusItem *_statusItem;
}

+ (BNStatusItemController *)sharedController;
@property (readwrite) BOOL hasUnread;

@end
