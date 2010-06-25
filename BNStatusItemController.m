//
//  BNStatusItemController.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNStatusItemController.h"
#import "BNMenuController.h"

NSString * const BNAllStatusesReadNotification = @"BNAllStatusesReadNotification";
NSString * const BNHasUnreadStatusesNotification = @"BNHasUnreadStatusesNotification";

#define kViewSideMargins 5

static NSImage *_normalImage = nil;
static NSImage *_unreadImage = nil;
static NSImage *_clickedImage = nil;

@interface BNStatusItemController ()
- (void)_receivedNotification:(NSNotification *)aNotification;
@end

@implementation BNStatusItemController
@synthesize hasUnread;

+ (void)initialize {
	_normalImage = [[NSImage imageNamed:@"StatusItem-Normal"] retain];
	_unreadImage = [[NSImage imageNamed:@"StatusItem-Unread"] retain];
	_clickedImage = [[NSImage imageNamed:@"StatusItem-Clicked"] retain];
}

- (id)init {
	if (self = [super init]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedNotification:) name:BNAllStatusesReadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedNotification:) name:BNHasUnreadStatusesNotification object:nil];
		
		CGFloat theWidth = [_normalImage size].width + 2 * kViewSideMargins;
		_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:theWidth] retain];
		[_statusItem setImage:_normalImage];
		[_statusItem setAlternateImage:_clickedImage];
		[_statusItem setMenu:[[BNMenuController sharedController] menu]];
		[_statusItem setHighlightMode:YES];
		[self setHasUnread:NO];
	}
	return self;
}

- (void)setHasUnread:(BOOL)flag {
	hasUnread = flag;
	[_statusItem setImage:hasUnread ? _unreadImage : _normalImage];
}

#pragma Private Methods

- (void)_receivedNotification:(NSNotification *)aNotification {
	if ([[aNotification name] isEqualToString:BNAllStatusesReadNotification])
		[self setHasUnread:NO];
	else if ([[aNotification name] isEqualToString:BNHasUnreadStatusesNotification])
		[self setHasUnread:YES];
}

#pragma mark Singleton Methods

static BNStatusItemController *sharedInstance = nil;

+ (BNStatusItemController *)sharedController {
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
