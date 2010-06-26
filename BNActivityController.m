//
//  BNActivityController.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/14/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNActivityController.h"
#import "BNAccount.h"
#import "BNProject.h"
#import "BNStatus.h"
#import "BNFeedOperation.h"
#import "NSTimer+NPBlocks.h"

NSString * const BNStatusesDownloadedNotification = @"BNStatusesDownloadedNotification";
NSString * const BNProjectArrayKey = @"BNProjectArrayKey";

@interface BNActivityController ()
- (void)_userDefaultsNotificationReceived:(NSNotification *)aNotification;
@end

@implementation BNActivityController

- (id)init {
	if (self = [super init]) {
		_feedQueue = [[NSOperationQueue alloc] init];
		_accountArray = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userDefaultsNotificationReceived:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
		[self _userDefaultsNotificationReceived:nil];
	}
	return self;
}

- (void)addAccount:(BNAccount *)anAccount {
	if (![anAccount isComplete] || [_accountArray containsObject:anAccount])
		return;
	 [_accountArray addObject:anAccount];
	[self refreshAllAccounts];
}

- (void)removeAccount:(BNAccount *)anAccount {
	if (![_accountArray containsObject:anAccount])
		return;
	[_accountArray removeObject:anAccount];
}

- (void)refreshAllAccounts {
	NSLog(@"Refreshing!");
	for (BNAccount *currAccount in _accountArray) {
		BNFeedOperation *feedOperation = [[BNFeedOperation alloc] initWithAccount:currAccount delegate:self];
		[_feedQueue addOperation:feedOperation];
		[feedOperation release];
	}
}

#pragma mark Feed Operation Delegate Methods

- (void)feedOperation:(BNFeedOperation *)theOperation didSucceedWithProjects:(NSArray *)projectArray {
	NSLog(@"Posting notification!");
	[[NSNotificationCenter defaultCenter] postNotificationName:BNStatusesDownloadedNotification object:[theOperation account] userInfo:[NSDictionary dictionaryWithObject:projectArray forKey:BNProjectArrayKey]];
}

- (void)feedOperation:(BNFeedOperation *)theOperation didFailWithError:(NSError *)theError {
	NSLog(@"%@", theError);
}

#pragma mark User Defaults

- (void)_userDefaultsNotificationReceived:(NSNotification *)aNotification {
	if (_refreshTimer != nil && [_refreshTimer isValid])
		[_refreshTimer invalidate];
	_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:[[[NSUserDefaults standardUserDefaults] objectForKey:@"RefreshInterval"] unsignedIntegerValue] block:^(NSTimer *theTimer){
		[self refreshAllAccounts];
	} repeats:YES];
}

#pragma mark Singleton Methods

static BNActivityController *sharedInstance = nil;

+ (BNActivityController *)sharedController {
	if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedController] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
	
}

- (id)autorelease {
    return self;
}

@end
