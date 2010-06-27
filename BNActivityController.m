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
#import "NSDictionary+NPAdditions.h"

NSString * const BNStatusesDownloadedNotification = @"BNStatusesDownloadedNotification";
NSString * const BNProjectArrayKey = @"BNProjectArrayKey";

@interface BNActivityController ()
- (void)_userDefaultsNotificationReceived:(NSNotification *)aNotification;
- (void)_terminationNotificationReceived:(NSNotification *)aNotification;
@end

@implementation BNActivityController

- (id)init {
	if (self = [super init]) {
		_feedQueue = [[NSOperationQueue alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userDefaultsNotificationReceived:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_terminationNotificationReceived:) name:NSApplicationWillTerminateNotification object:NSApp];
		[self _userDefaultsNotificationReceived:nil];
		_checkAccountDict = [[NSMutableDictionary alloc] init];
		_accountArray = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForDataFile]] mutableCopy];
		if (_accountArray == nil)
			_accountArray = [[NSMutableArray alloc] init];
		else {
			for (BNAccount *currAccount in _accountArray)
				[currAccount setPasswordFromKeychain];
			[self refreshAllAccounts];
		}
	}
	return self;
}

- (void)checkAccountCredentials:(BNAccount *)theAccount delegate:(id<BNAccountCheckingDelegate>)delegate {
	if (theAccount == nil || ![theAccount isComplete] || delegate == nil)
		return;
	BNFeedOperation *feedOperation = [[BNFeedOperation alloc] initWithAccount:theAccount delegate:self];
	[_feedQueue addOperation:feedOperation];
	[feedOperation release];
	[_checkAccountDict setObject:delegate forKey:theAccount];
}

- (void)addAccount:(BNAccount *)anAccount {
	if ([_accountArray containsObject:anAccount])
		return;
	[_accountArray addObject:anAccount];
	[self refreshAllAccounts];
}

- (void)removeAccount:(BNAccount *)anAccount {
	if (![_accountArray containsObject:anAccount])
		return;
	[anAccount removeFromKeychain];
	[_accountArray removeObject:anAccount];
}

- (NSUInteger)accountCount {
	return [_accountArray count];
}

- (BNAccount *)accountAtIndex:(NSUInteger)index {
	if (index >= 0 && index < [_accountArray count])
		return [_accountArray objectAtIndex:index];
	return nil;
}

- (void)refreshAllAccounts {
	for (BNAccount *currAccount in _accountArray) {
		if ([currAccount isComplete]) {
			BNFeedOperation *feedOperation = [[BNFeedOperation alloc] initWithAccount:currAccount delegate:self];
			[_feedQueue addOperation:feedOperation];
			[feedOperation release];
		}
	}
}

- (NSString *)pathForDataFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/Basecamp Notifications/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath:folder] == NO) {
		[fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
	}
    
	NSString *fileName = @"Accounts.bndata";
	return [folder stringByAppendingPathComponent:fileName];    
}

#pragma mark Feed Operation Delegate Methods

- (void)feedOperation:(BNFeedOperation *)theOperation didSucceedWithProjects:(NSArray *)projectArray {
	if ([_checkAccountDict containsKey:[theOperation account]]) {
		id<BNAccountCheckingDelegate> theDelegate = [_checkAccountDict objectForKey:[theOperation account]];
		if (theDelegate != nil && [theDelegate respondsToSelector:@selector(checkedCredentialsForAccount:success:)])
			[theDelegate checkedCredentialsForAccount:[theOperation account] success:YES];
		[_checkAccountDict removeObjectForKey:[theOperation account]];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:BNStatusesDownloadedNotification object:[theOperation account] userInfo:[NSDictionary dictionaryWithObject:projectArray forKey:BNProjectArrayKey]];
	}
}

- (void)feedOperation:(BNFeedOperation *)theOperation didFailWithError:(NSError *)theError {
	NSLog(@"%@", theError);
	
	if ([_checkAccountDict containsKey:[theOperation account]]) {
		if ([theError code] == NSURLErrorUserAuthenticationRequired) {
			id<BNAccountCheckingDelegate> theDelegate = [_checkAccountDict objectForKey:[theOperation account]];
			if (theDelegate != nil && [theDelegate respondsToSelector:@selector(checkedCredentialsForAccount:success:)])
				[theDelegate checkedCredentialsForAccount:[theOperation account] success:NO];
		}
		[_checkAccountDict removeObjectForKey:[theOperation account]];
	}
}

#pragma mark Notifications

- (void)_userDefaultsNotificationReceived:(NSNotification *)aNotification {
	if (_refreshTimer != nil && [_refreshTimer isValid])
		[_refreshTimer invalidate];
	_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:[[[NSUserDefaults standardUserDefaults] objectForKey:@"RefreshInterval"] unsignedIntegerValue] block:^(NSTimer *theTimer){
		[self refreshAllAccounts];
	} repeats:YES];
}

- (void)_terminationNotificationReceived:(NSNotification *)aNotification; {
	for (BNAccount *currAccount in _accountArray) {
		if ([currAccount isComplete]) {
			[currAccount writeToKeychain];
		}
	}
	[NSKeyedArchiver archiveRootObject:_accountArray toFile:[self pathForDataFile]];
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
