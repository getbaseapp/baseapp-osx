//
//  BNLaunchPadOperation.m
//  Flare
//
//  Created by Nick Paulson on 7/29/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNLaunchPadOperation.h"
#import "NSString+NPAdditions.h"
#import "NSObject+NPMainThreadBlocks.h"
#import "RegexKitLite.h"
#import "BNAccount.h"

@interface BNLaunchPadOperation ()
@property (copy, readwrite) NSString *username;
@property (copy, readwrite) NSString *password;
@property (copy, readwrite) NSString *identifier;
@end

@implementation BNLaunchPadOperation
@synthesize username, password, delegate, identifier;

- (id)init {
	return [self initWithUsername:nil password:nil delegate:nil];
}

- (id)initWithUsername:(NSString *)aName password:(NSString *)aPassword delegate:(id<BNLaunchPadOperationDelegate>)aDelegate {
	if (self = [super init]) {
		self.username = aName;
		self.password = aPassword;
		self.delegate = aDelegate;
		self.identifier = [[NSProcessInfo processInfo] globallyUniqueString];
	}
	return self;
}

+ (BNLaunchPadOperation *)launchPadOperationWithUsername:(NSString *)aName password:(NSString *)aPassword delegate:(id<BNLaunchPadOperationDelegate>)aDelegate {
	return [[[[self class] alloc] initWithUsername:aName password:aPassword delegate:aDelegate] autorelease];
}

- (void)main {
	if ([self isCancelled])
		return;
	if (self.username == nil || [self.username length] == 0 || self.password == nil || [self.password length] == 0 || self.delegate == nil)
		return;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://launchpad.37signals.com/session"]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"application/xml" forHTTPHeaderField:@"Accept"];
	[request setHTTPBody:[[NSString stringWithFormat:@"username=%@&password=%@", self.username, self.password] dataUsingEncoding:NSUTF8StringEncoding]];
	NSHTTPURLResponse *theResp = nil;
	NSError *error = nil;
	NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResp error:&error];
	if (error != nil) {
		[self performBlockOnMainThread:^{
			if ([self.delegate respondsToSelector:@selector(launchPadOperation:failedWithError:)])
				[self.delegate launchPadOperation:self failedWithError:error];
		} waitUntilDone:YES];
	}
	
	if (retData == nil || [retData length] == 0) {
		[self performBlockOnMainThread:^{
			if ([self.delegate respondsToSelector:@selector(launchPadOperation:failedWithError:)])
				[self.delegate launchPadOperation:self failedWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
		} waitUntilDone:YES];
	}
	
	NSArray *matches = [[NSString stringWithData:retData encoding:NSUTF8StringEncoding] componentsMatchedByRegex:@"data-product=\"basecamp\" data-subdomain=\"[^\"]*"];
	if (matches == nil || [matches count] == 0) {
		[self performBlockOnMainThread:^{
			if ([self.delegate respondsToSelector:@selector(launchPadOperation:failedWithError:)])
				[self.delegate launchPadOperation:self failedWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
		} waitUntilDone:YES];
	}
	
	NSMutableArray *subdomainList = [NSMutableArray array];
	for (NSString *currMatch in matches) {
		NSArray *tempArray = [currMatch componentsSeparatedByString:@"data-subdomain=\""];
		NSString *subdomainName = [tempArray lastObject];
		if (subdomainName != nil && [subdomainName length] > 0)
			[subdomainList addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@.basecamphq.com/", subdomainName]]];
	}
	NSMutableArray *accountList = [NSMutableArray array];
	for (NSURL *currDomain in subdomainList) {
		BNAccount *account = [BNAccount accountWithUser:self.username password:self.password URL:currDomain];
		[accountList addObject:account];
	}
	[self performBlockOnMainThread:^{
		if ([self.delegate respondsToSelector:@selector(launchPadOperation:gotAccounts:)])
			[self.delegate launchPadOperation:self gotAccounts:accountList];
	} waitUntilDone:YES];
}

@end
