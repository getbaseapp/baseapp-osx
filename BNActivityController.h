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

@protocol BNAccountCheckingDelegate <NSObject>
- (void)checkedCredentialsForAccount:(BNAccount *)theAccount success:(BOOL)success;
@end


@interface BNActivityController : NSObject {
	NSMutableArray *_accountArray;
	NSOperationQueue *_feedQueue;
	NSTimer *_refreshTimer;
	NSMutableDictionary *_checkAccountDict;
}

+ (BNActivityController *)sharedController;
- (void)addAccount:(BNAccount *)anAccount;
- (void)refreshAllAccounts;
- (NSString *)pathForDataFile;
- (BNAccount *)accountAtIndex:(NSUInteger)index;
- (NSUInteger)accountCount;
- (void)removeAccount:(BNAccount *)anAccount;
- (void)checkAccountCredentials:(BNAccount *)theAccount delegate:(id<BNAccountCheckingDelegate>)delegate;

@end
