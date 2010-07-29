//
//  BNLaunchPadOperation.h
//  Flare
//
//  Created by Nick Paulson on 7/29/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BNLaunchPadOperation;
@protocol BNLaunchPadOperationDelegate <NSObject>
- (void)launchPadOperation:(BNLaunchPadOperation *)operation gotAccounts:(NSArray *)accounts;
- (void)launchPadOperation:(BNLaunchPadOperation *)operation failedWithError:(NSError *)error;
@end

@interface BNLaunchPadOperation : NSOperation {
	NSString *username;
	NSString *password;
	id<BNLaunchPadOperationDelegate> delegate;
	NSString *identifier;
}

@property (copy, readonly) NSString *username;
@property (copy, readonly) NSString *password;
@property (retain, readwrite) id<BNLaunchPadOperationDelegate> delegate;
@property (copy, readonly) NSString *identifier;

- (id)initWithUsername:(NSString *)aName password:(NSString *)aPassword delegate:(id<BNLaunchPadOperationDelegate>)aDelegate;
+ (BNLaunchPadOperation *)launchPadOperationWithUsername:(NSString *)aName password:(NSString *)aPassword delegate:(id<BNLaunchPadOperationDelegate>)aDelegate;

@end
