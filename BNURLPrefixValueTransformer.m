//
//  BNURLPrefixValueTransformer.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/25/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNURLPrefixValueTransformer.h"


@implementation BNURLPrefixValueTransformer

+ (Class)transformedValueClass { 
	return [NSURL class]; 
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
    if (value == nil)
		return nil;
	if ([value isKindOfClass:[NSString class]]) {
		return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.basecamphq.com/", value]];
	} else if ([value isKindOfClass:[NSURL class]]) {
		NSScanner *theScanner = [NSScanner scannerWithString:[value absoluteString]];
		[theScanner scanUpToString:@"://" intoString:nil];
		if ([[[theScanner string] substringFromIndex:[theScanner scanLocation]] length] <= 3)
			return nil;
		[theScanner setScanLocation:[theScanner scanLocation] + 3];
		NSString *retPrefix = nil;
		[theScanner scanUpToString:@"." intoString:&retPrefix];
		return retPrefix;
	}
	return nil;
}


@end
