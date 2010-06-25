//
//  BNFeedOperation.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/15/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BNFeedOperation, BNAccount;

@interface NSObject (BNFeedOperationDelegate)
- (void)feedOperation:(BNFeedOperation *)theOperation didSucceedWithProjects:(NSArray *)projectArray;
- (void)feedOperation:(BNFeedOperation *)theOperation didFailWithError:(NSError *)theError;
@end

@interface BNFeedOperation : NSOperation {
	BNAccount *account;
	id delegate;
}

@property (retain, readwrite) BNAccount *account;
@property (assign, readwrite) id delegate;

- (id)initWithAccount:(BNAccount *)theAccount delegate:(id)theDel;

@end
