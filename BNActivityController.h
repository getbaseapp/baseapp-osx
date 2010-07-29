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
#import "BNLaunchPadOperation.h"

@class BNAccount;

@protocol BNAccountGettingDelegate <NSObject>
- (void)foundAccounts:(NSArray *)accounts;
- (void)findingAccountsFailedWithError:(NSError *)theError;
@end

@protocol BNAccountCheckingDelegate <NSObject>
- (void)checkedCredentialsForAccount:(BNAccount *)theAccount success:(BOOL)success;
@end


@interface BNActivityController : NSObject<BNLaunchPadOperationDelegate> {
	NSMutableArray *_accountArray;
	NSOperationQueue *_feedQueue;
	NSTimer *_refreshTimer;
	NSMutableDictionary *_checkAccountDict;
	NSMutableDictionary *_getAccountsDict;
}

+ (BNActivityController *)sharedController;
- (void)addAccount:(BNAccount *)anAccount;
- (void)refreshAllAccounts;
- (NSString *)pathForDataFile;
- (BNAccount *)accountAtIndex:(NSUInteger)index;
- (NSUInteger)accountCount;
- (void)removeAccount:(BNAccount *)anAccount;
- (BOOL)hasAccount:(BNAccount *)anAccount;
- (void)checkAccountCredentials:(BNAccount *)theAccount delegate:(id<BNAccountCheckingDelegate>)delegate;
- (void)getAccountsForUsername:(NSString *)aName password:(NSString *)aPass delegate:(id<BNAccountGettingDelegate>)aDelegate;

@end
