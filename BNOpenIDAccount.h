//
//  BNOpenIDAccount.h
//  Flare
//
//  Created by Nick Paulson on 7/13/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNAccount.h"

@interface BNOpenIDAccount : BNAccount {
	
}

- (id)initWithAPIToken:(NSString *)theToken URL:(NSURL *)theURL;
+ (BNOpenIDAccount *)openIDAccountWithAPIToken:(NSString *)theToken URL:(NSURL *)theURL;

- (void)setAPIToken:(NSString *)theToken;
- (NSString *)APIToken;

@end
