//
//  NSString+NPWidthTruncation.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/20/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NSString+NPWidthTruncation.h"


@implementation NSString (NPWidthTruncation)

- (NSString *)stringByTruncatingToWidth:(CGFloat)theWidth withFont:(NSFont *)theFont {
	NSMutableString *retString = [NSMutableString string];
	NSDictionary *atributeDict = [NSDictionary dictionaryWithObjectsAndKeys:theFont, NSFontAttributeName, nil];
	theWidth -= [@"..." sizeWithAttributes:atributeDict].width;
	for (NSInteger i = 0; i < [self length] && [retString sizeWithAttributes:atributeDict].width <= theWidth; i++)
		[retString appendString:[self substringWithRange:NSMakeRange(i, 1)]];
	if ([self isEqualToString:retString])
		return retString;
	[retString deleteCharactersInRange:NSMakeRange([retString length] - 1, 1)];
	[retString appendString:@"..."];
	return retString;
}

@end
