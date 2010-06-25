//
//  NSString+NPWidthTruncation.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/20/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (NPWidthTruncation)
- (NSString *)stringByTruncatingToWidth:(CGFloat)theWidth withFont:(NSFont *)theFont;
@end
