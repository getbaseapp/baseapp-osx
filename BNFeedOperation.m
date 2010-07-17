//
//  BNFeedOperation.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/15/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNFeedOperation.h"
#import "NSObject+NPMainThreadBlocks.h"
#import "NSData+Base64.h"
#import "BNAccount.h"
#import "BNProject.h"
#import "BNStatus.h"
#import "BNFeedOperation.h"
#import <PubSub/PubSub.h>

@interface BNFeedOperation ()
- (NSArray *)_projectsInFeed:(PSFeed *)theFeed account:(BNAccount *)theAccount;
- (NSString *)_projectNameInEntry:(PSEntry *)theEntry;
- (BNStatus *)_statusForEntry:(PSEntry *)theEntry;
- (NSArray *)_statusesForProject:(BNProject *)theProject inFeed:(PSFeed *)theFeed account:(BNAccount *)theAccount;
- (NSArray *)_projectsForAccount:(BNAccount *)theAccount error:(NSError **)theError;
- (NSURLRequest *)_requestForURL:(NSURL *)theURL account:(BNAccount *)theAccount;
- (NSArray *)_projectsForPaidAccount:(BNAccount *)theAccount projectArray:(NSArray *)projArray error:(NSError **)error;
- (NSArray *)_projectsForFreeAccount:(BNAccount *)theAccount error:(NSError **)error;
- (NSString *)_companyNameInEntry:(PSEntry *)theEntry;
- (NSString *)_firstCompanyNameInFeed:(PSFeed *)theFeed;
@end

@implementation BNFeedOperation
@synthesize account, delegate;

- (id)initWithAccount:(BNAccount *)theAccount delegate:(id)theDel {
	if (self = [super init]) {
		[self setAccount:theAccount];
		[self setDelegate:theDel];
	}
	return self;
}

- (void)main {
	NSError *theError = nil;
	BNAccount *theAccount = [self account];
	NSArray *projArray = [self _projectsForAccount:theAccount error:&theError];
	if (theError != nil && delegate != nil && [delegate respondsToSelector:@selector(feedOperation:didFailWithError:)]) {
		[delegate performBlockOnMainThread:^{
			[delegate feedOperation:self didFailWithError:theError];
		} waitUntilDone:YES];
		return;
	}
	
	[theAccount setFree:projArray == nil];
	
	NSArray *sendArray = [theAccount isFree] ? [self _projectsForFreeAccount:theAccount error:&theError] : [self _projectsForPaidAccount:theAccount projectArray:projArray error:&theError];
	if (theError != nil) {
		if (delegate != nil && [delegate respondsToSelector:@selector(feedOperation:didFailWithError:)])
			[delegate performBlockOnMainThread:^{
				[delegate feedOperation:self didFailWithError:theError];
			} waitUntilDone:YES];
	} else {
		if (delegate != nil && [delegate respondsToSelector:@selector(feedOperation:didSucceedWithProjects:)])
			[delegate performBlockOnMainThread:^{
				[delegate feedOperation:self didSucceedWithProjects:sendArray];
			} waitUntilDone:YES];
	}
	
}

- (NSArray *)_projectsForPaidAccount:(BNAccount *)theAccount projectArray:(NSArray *)projArray error:(NSError **)error {
	NSError *theError = nil;
	NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:[projArray count]];
	for (NSNumber *currID in projArray) {
		NSInteger intValue = [currID integerValue];
		NSString *URLString = [NSString stringWithFormat:@"https://%@/projects/%i/feed/recent_items_rss", [[theAccount URL] host], intValue];
		NSData *retData = [NSURLConnection sendSynchronousRequest:[self _requestForURL:[NSURL URLWithString:URLString] account:theAccount] returningResponse:nil error:&theError];
		if (theError != nil) {
			*error = theError;
			return nil;
		}
		NSURL *projectURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/projects/%i", [[theAccount URL] host], intValue]];
		PSFeed *theFeed = [[PSFeed alloc] initWithData:retData URL:[theAccount URL]];
		BNProject *theProject = [BNProject projectWithName:[theFeed title] companyName:[self _firstCompanyNameInFeed:theFeed] URL:projectURL account:theAccount];
		[theProject setProjectID:[currID integerValue]];
		NSArray *theStatuses = [self _statusesForProject:theProject inFeed:theFeed account:theAccount];
		NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
		theStatuses = [theStatuses sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
		[sortDesc release];
		[theProject setLatestStatuses:theStatuses];
		[retArray addObject:theProject];
		[theFeed release];
	}
	return retArray;
}

- (NSArray *)_projectsForFreeAccount:(BNAccount *)theAccount error:(NSError **)error {
	NSString *URLString = [NSString stringWithFormat:@"https://%@/feed/recent_items_rss", [[theAccount URL] host]];
	NSError *theError = nil;
	NSData *retData = [NSURLConnection sendSynchronousRequest:[self _requestForURL:[NSURL URLWithString:URLString] account:theAccount] returningResponse:nil error:&theError];
	if (theError != nil) {
		*error = theError;
		return nil;
	}
	
	PSFeed *theFeed = [[PSFeed alloc] initWithData:retData URL:[theAccount URL]];
	NSArray *theProjects = [self _projectsInFeed:theFeed account:theAccount];
	NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:[theProjects count]];
	for (BNProject *currProject in theProjects) {
		NSArray *theStatuses = [self _statusesForProject:currProject inFeed:theFeed account:theAccount];
		NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
		theStatuses = [theStatuses sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
		[sortDesc release];
		[currProject setLatestStatuses:theStatuses];
		[currProject setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/", [[theAccount URL] host]]]];
		[currProject setProjectID:BNProjectFreeID];
		[retArray addObject:currProject];
	}
	
	return retArray;
}

- (NSURLRequest *)_requestForURL:(NSURL *)theURL account:(BNAccount *)theAccount {
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
	NSString *authStr = [NSString stringWithFormat:@"%@:%@", [theAccount user], [theAccount password]];
	NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
	[theRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	return theRequest;
}

- (NSString *)_firstCompanyNameInFeed:(PSFeed *)theFeed {
	NSEnumerator *entryEnumerator = [theFeed entryEnumeratorSortedBy:nil];
	PSEntry *currEntry;
	while (currEntry = [entryEnumerator nextObject]) {
		NSString *compName = [self _companyNameInEntry:currEntry];
		if (compName != nil)
			return compName;
	}
	return @"Unknown Company";
}

- (NSString *)_companyNameInEntry:(PSEntry *)theEntry {
	NSString *plainText = [[theEntry content] plainTextString];
	if (plainText == nil)
		return nil;
	NSScanner *theScanner = [NSScanner scannerWithString:plainText];
	NSString *projectString = @"Company: ";
	NSString *testString = nil;
	while ([theScanner scanUpToString:projectString intoString:&testString]);
	@try {
		[theScanner setScanLocation:[theScanner scanLocation] + [projectString length]];
	}
	@catch (NSException * e) {
		return nil;
	}
	NSString *retString = nil;
	[theScanner scanUpToString:@" |" intoString:&retString];
	return retString;
}

- (NSArray *)_projectsForAccount:(BNAccount *)theAccount error:(NSError **)theError {
	NSError *tempError = nil;
	NSString *projectsURL = [NSString stringWithFormat:@"https://%@/projects.xml", [[theAccount URL] host]];
	NSData *projXMLRetData = [NSURLConnection sendSynchronousRequest:[self _requestForURL:[NSURL URLWithString:projectsURL] account:theAccount] returningResponse:nil error:&tempError];
	NSString *testString = [[NSString alloc] initWithData:projXMLRetData encoding:NSUTF8StringEncoding];
	if ([testString isEqualToString:@"HTTP Basic: Access denied.\n"] || [testString isEqualToString:@" "]) {
		*theError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUserAuthenticationRequired userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Login failed", NSLocalizedDescriptionKey, nil]];
		return nil;
	}
	if ([testString rangeOfString:@"<error>The API is not available to this account</error>"].location != NSNotFound) {
		NSLog(@"API Not supported Error!");
		return nil;
	}
	[testString release];
	if (projXMLRetData == nil) {
		NSLog(@"projXML returned nil");
		*theError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil];
		return nil;
	}
	
	NSXMLDocument *readDoc = [[NSXMLDocument alloc] initWithData:projXMLRetData options:NSXMLDocumentValidate error:&tempError];
	if (tempError != nil) {
		NSLog(@"Error occurred while making XML document: %@", tempError);
		*theError = tempError;
		return nil;
	}
	NSArray *projectsArray = [[readDoc rootElement] children];
	if (projectsArray == nil || [projectsArray count] == 0) {
		NSLog(@"Projects array was nil or empty!");
		return nil;
	}
	NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:[projectsArray count]];
	for (NSXMLNode *currProject in projectsArray) {
		NSNumber *retNum = nil;
		BOOL isNotUsed = NO;
		for (NSXMLNode *currChild in [currProject children]) {
			if ([[currChild name] isEqualToString:@"id"]) {
				retNum = [NSNumber numberWithInteger:[[currChild stringValue] integerValue]];
			}
			if ([[currChild name] isEqualToString:@"status"]) {
				NSString *theString = [currChild stringValue];
				if (![theString isEqualToString:@"active"])
					isNotUsed = YES;
			}
		}
		if (retNum != nil && !isNotUsed)
			[retArray addObject:retNum];
	}
	return retArray;
}

- (NSArray *)_projectsInFeed:(PSFeed *)theFeed account:(BNAccount *)theAccount {
	NSEnumerator *entryEnumerator = [theFeed entryEnumeratorSortedBy:nil];
	PSEntry *currEntry;
	NSMutableArray *retArray = [NSMutableArray array];
	while (currEntry = [entryEnumerator nextObject]) {
		NSString *projName = [self _projectNameInEntry:currEntry];
		if (projName == nil)
			continue;
		BNProject *theProject = [BNProject projectWithName:projName companyName:[theFeed title] URL:nil account:theAccount];
		if (![retArray containsObject:theProject])
			[retArray addObject:theProject];
	}
	return retArray;
}

- (NSString *)_projectNameInEntry:(PSEntry *)theEntry {
	NSString *plainText = [[theEntry content] plainTextString];
	if (plainText == nil)
		return nil;
	NSScanner *theScanner = [NSScanner scannerWithString:plainText];
	NSString *projectString = @"| Project: ";
	NSString *testString = nil;
	while ([theScanner scanUpToString:projectString intoString:&testString]);
	@try {
		[theScanner setScanLocation:[theScanner scanLocation] + [projectString length]];
	}
	@catch (NSException * e) {
		return nil;
	}
	NSString *retString = nil;
	[theScanner scanUpToString:@" |" intoString:&retString];
	return retString;
}

- (NSArray *)_statusesForProject:(BNProject *)theProject inFeed:(PSFeed *)theFeed account:(BNAccount *)theAccount {
	NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"datePublished" ascending:YES];
	NSEnumerator *entryEnumerator = [theFeed entryEnumeratorSortedBy:[NSArray arrayWithObject:sortDesc]];
	[sortDesc release];
	PSEntry *currEntry;
	NSMutableArray *retArray = [NSMutableArray array];
	while (currEntry = [entryEnumerator nextObject]) {
		NSString *currProjName = ([theAccount isFree] ? [self _projectNameInEntry:currEntry] : [theFeed title]) ;
		NSString *currProjCompName = ([theAccount isFree] ? [theFeed title] : [self _firstCompanyNameInFeed:theFeed]);
		if ([currProjName isEqual:theProject.name] && [currProjCompName isEqual:theProject.companyName]) {
			[retArray addObject:[self _statusForEntry:currEntry]];
		}
	}
	return retArray;
}

- (BNStatus *)_statusForEntry:(PSEntry *)theEntry {
	NSString *title = [theEntry title];
	
	BNStatusType theType = BNStatusTypeUnknown;
	
	NSString *creator = @"Unknown User";
	if ([[theEntry authors] count] > 0)
		creator = [[[theEntry authors] objectAtIndex:0] name];
	
	NSDate *pubDate = [theEntry datePublished];
	
	NSURL *theURL = [theEntry alternateURL];
	
	NSString *commentString = @"Comment posted: ";
	NSString *messageString = @"Message posted: ";
	NSString *fileUploadString = @"File uploaded: ";
	NSString *todoAddedString = @"Todo added: ";
	NSString *todoCompletedString = @"Todo completed: ";
	if ([[theEntry title] hasPrefix:commentString]) {
		theType = BNStatusTypeComment;
		title = [NSString stringWithFormat:@"%@ commented on \"%@\"", creator, [[theEntry title] substringFromIndex:[commentString length]]];
	} else if ([[theEntry title] hasPrefix:messageString]) {
		theType = BNStatusTypeMessage;
		title = [NSString stringWithFormat:@"%@ posted \"%@\"", creator, [[theEntry title] substringFromIndex:[messageString length]]];
	} else if ([[theEntry title] hasPrefix:fileUploadString]) {
		theType = BNStatusTypeFileUpload;
		NSString *readInto = @"";
		NSScanner *theScanner = [NSScanner scannerWithString:[[theEntry title] substringFromIndex:[fileUploadString length]]];
		NSMutableString *fullString = [NSMutableString string];
		
		BOOL isFound = [[[theScanner string] substringFromIndex:[theScanner scanLocation]] rangeOfString:@"("].location != NSNotFound;
		while (isFound && [theScanner scanUpToString:@"(" intoString:&readInto]) {
			[fullString appendString:readInto];
			[theScanner setScanLocation:[theScanner scanLocation] + 1];
			isFound = [[[theScanner string] substringFromIndex:[theScanner scanLocation]] rangeOfString:@"("].location != NSNotFound;
			if (isFound)
				[fullString appendString:@"("];
		}
		
		while ([fullString hasSuffix:@" "])
			[fullString replaceCharactersInRange:NSMakeRange([fullString length] - 1, 1) withString:@""];
		title = [NSString stringWithFormat:@"%@ uploaded \"%@\"", creator, fullString];
	} else if ([[theEntry title] hasPrefix:todoAddedString]) {
		theType = BNStatusTypeTodo;
		NSScanner *theScanner = [NSScanner scannerWithString:[[theEntry title] substringFromIndex:[todoAddedString length]]];
		NSString *readInto = @"";
		NSMutableString *fullString = [NSMutableString string];
		BOOL isFound = [[[theScanner string] substringFromIndex:[theScanner scanLocation]] rangeOfString:@"("].location != NSNotFound;
		while (isFound && [theScanner scanUpToString:@"(" intoString:&readInto]) {
			[fullString appendString:readInto];
			[theScanner setScanLocation:[theScanner scanLocation] + 1];
			isFound = [[[theScanner string] substringFromIndex:[theScanner scanLocation]] rangeOfString:@"("].location != NSNotFound;
			if (isFound)
				[fullString appendString:@"("];
		}
		while ([fullString hasSuffix:@" "])
			[fullString replaceCharactersInRange:NSMakeRange([fullString length] - 1, 1) withString:@""];
		[theScanner scanUpToString:@" responsible)" intoString:&readInto];
		title = [NSString stringWithFormat:@"%@ assigned \"%@\" to %@", creator, fullString, readInto];
	} else if ([[theEntry title] hasPrefix:todoCompletedString]) {
		theType = BNStatusTypeTodo;
		NSScanner *theScanner = [NSScanner scannerWithString:[[theEntry title] substringFromIndex:[todoCompletedString length]]];
		NSString *readInto = @"";
		NSMutableString *fullString = [NSMutableString string];
		BOOL isFound = [[[theScanner string] substringFromIndex:[theScanner scanLocation]] rangeOfString:@"("].location != NSNotFound;
		while (isFound && [theScanner scanUpToString:@"(" intoString:&readInto]) {
			[fullString appendString:readInto];
			[theScanner setScanLocation:[theScanner scanLocation] + 1];
			isFound = [[[theScanner string] substringFromIndex:[theScanner scanLocation]] rangeOfString:@"("].location != NSNotFound;
			if (isFound)
				[fullString appendString:@"("];
		}
		while ([fullString hasSuffix:@" "])
			[fullString replaceCharactersInRange:NSMakeRange([fullString length] - 1, 1) withString:@""];
		[theScanner scanUpToString:@" responsible)" intoString:&readInto];
		title = [NSString stringWithFormat:@"%@ completed \"%@\"", readInto, fullString];
	}
	return [BNStatus statusWithTitle:title creator:creator URL:theURL date:pubDate type:theType];
}

- (void)dealloc {
	[self setAccount:nil];
	[self setDelegate:nil];
	[super dealloc];
}

@end
