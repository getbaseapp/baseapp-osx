//
//  BNActivityController.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/14/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

//User info contains BNProjectArrayKey --> NSArray of BNProjects
extern NSString * const BNStatusesDownloadedNotification;
extern NSString * const BNProjectArrayKey;

#import <Cocoa/Cocoa.h>
@class BNAccount;

@interface BNActivityController : NSObject {
	NSMutableArray *_accountArray;
	NSOperationQueue *_feedQueue;
	NSTimer *_refreshTimer;
}

+ (BNActivityController *)sharedController;
- (void)addAccount:(BNAccount *)anAccount;
- (void)refreshAllAccounts;
- (NSString *)pathForDataFile;
- (BNAccount *)accountAtIndex:(NSUInteger)index;
- (NSUInteger)accountCount;
- (void)removeAccount:(BNAccount *)anAccount;

@end
