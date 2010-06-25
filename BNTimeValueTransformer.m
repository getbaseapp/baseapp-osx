//
//  BNTimeValueTransformer.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/24/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNTimeValueTransformer.h"


@implementation BNTimeValueTransformer

+ (Class)transformedValueClass { 
	return [NSNumber class]; 
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
    if (value == nil)
		return nil;
	if ([value isKindOfClass:[NSString class]]) {
		NSScanner *tempScanner = [NSScanner scannerWithString:value];
		NSInteger scannedNumber = -1;
		[tempScanner scanInteger:&scannedNumber];
		NSUInteger retSeconds = -1;
		if ([value rangeOfString:@"seconds"].location != NSNotFound)
			retSeconds = scannedNumber;
		else if ([value rangeOfString:@"minute"].location != NSNotFound)
			retSeconds = scannedNumber * 60;
		else if ([value rangeOfString:@"hour"].location != NSNotFound)
			retSeconds = scannedNumber * 3600;
		else if ([value rangeOfString:@"day"].location != NSNotFound)
			retSeconds = scannedNumber * 86400;
		if (retSeconds < 0)
			return nil;
		return [NSNumber numberWithUnsignedInteger:retSeconds];
	} else if ([value isKindOfClass:[NSNumber class]]) {
		NSUInteger secondsValue = [value unsignedIntegerValue];
		NSString *stringValue = nil;
		if (secondsValue < 60)
			stringValue = [NSString stringWithFormat:@"%i second%@", secondsValue, (secondsValue == 1 ? @"" : @"s")];
		else if (secondsValue < 3600)
			stringValue = [NSString stringWithFormat:@"%i minute%@", secondsValue / 60, (secondsValue / 60 == 1 ? @"" : @"s")];
		else if (secondsValue < 86400)
			stringValue = [NSString stringWithFormat:@"%i hour%@", secondsValue / 3600, (secondsValue / 3600 == 1 ? @"" : @"s")];
		else
			stringValue = [NSString stringWithFormat:@"%i day%@", secondsValue, (secondsValue / 86400 == 1 ? @"" : @"s")];
		return stringValue;
	}
	return nil;
}

@end
