//
//  BNMenuController.m
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "BNMenuController.h"
#import "BNProject.h"
#import "NPBlocksMenuItem.h"
#import "BNStatus.h"
#import "BNActivityController.h"
#import "BNStatusItemController.h"
#import "NSString+NPWidthTruncation.h"
#import "BNPreferencesWindowController.h"

static NSImage *_onStateImage = nil;
static NSImage *_messageImage = nil;
static NSImage *_fileUploadImage = nil;
static NSImage *_todoImage = nil;
static NSImage *_commentImage = nil;
static NSImage *_unknownImage = nil;

NSString * const BNNewStatusesAddedNotification = @"BNNewStatusesAddedNotification";

@interface BNMenuController ()
@property (retain, readwrite) NSMenu *menu;
- (void)_sortProjectArray:(NSMutableArray *)theArray;
- (NSInteger)_menuIndexForProject:(BNProject *)theProject;
- (void)_receivedNotification:(NSNotification *)aNotification;
- (void)_doNotificationIfNecessary;
@end

@implementation BNMenuController
@synthesize menu;

+ (void)initialize {
	_onStateImage = [[NSImage imageNamed:@"DropDown-OnStatusImage"] retain];
	_messageImage = [[NSImage imageNamed:@"DropDown-Message"] retain];
	_fileUploadImage = [[NSImage imageNamed:@"DropDown-FileUpload"] retain];
	_todoImage = [[NSImage imageNamed:@"DropDown-Todo"] retain];
	_commentImage = [[NSImage imageNamed:@"DropDown-Comment"] retain];
	_unknownImage = [[NSImage imageNamed:@"DropDown-Chalkboard"] retain];
}

- (id)init {
	if (self = [super init]) {
		preferencesWindow = [[BNPreferencesWindowController alloc] initWithWindowNibName:@"BNPreferencesWindowController"];
	
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedNotification:) name:BNStatusesDownloadedNotification object:nil];
		
		NSMenu *theMenu = [[NSMenu alloc] init];
		
		NPBlocksMenuItem *menuItem = [[NPBlocksMenuItem alloc] initWithTitle:@"Preferences..." block:^(NSMenuItem *item) {
			[NSApp activateIgnoringOtherApps:YES];
			[preferencesWindow showWindow:self];
		} keyEquivalent:@""];
		[theMenu addItem:menuItem];
		[menuItem release];
		
		menuItem = [[NPBlocksMenuItem alloc] initWithTitle:@"Quit Basecamp Notifications" block:^(NSMenuItem *item) {
			[NSApp terminate:self];
		} keyEquivalent:@""];
		
		[theMenu addItem:menuItem];
		[menuItem release];
		
		[self setMenu:theMenu];
		[theMenu release];
		_projectDictionary = [[NSMutableDictionary alloc] init];
		_sortedProjects = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addProject:(BNProject *)aProject {
	if ([_sortedProjects containsObject:aProject])
		return;
	[_sortedProjects addObject:aProject];
	[self _sortProjectArray:_sortedProjects];
	NSInteger insertIndex = [self _menuIndexForProject:aProject];
	NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:[[aProject latestStatuses] count]];
	NPBlocksMenuItem *titleItem = [[NPBlocksMenuItem alloc] initWithTitle:@"" block:nil keyEquivalent:@""];
	
	NSFont *theFont = [NSFont fontWithName:@"Lucida Grande" size:14.0];
	NSString *realString = [NSString stringWithFormat:@"%@ (%@)", [aProject name], [aProject companyName]];
	theFont = [[NSFontManager sharedFontManager] convertFont:theFont toHaveTrait:NSBoldFontMask];
	NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:[realString stringByTruncatingToWidth:300.0 withFont:[NSFont menuFontOfSize:14.0]]
									    attributes:[NSDictionary dictionaryWithObjectsAndKeys:theFont, NSFontAttributeName, 
										[NSColor blackColor], NSForegroundColorAttributeName, nil]];
	[titleItem setAttributedTitle:titleString];
	[titleString release];
	[menu insertItem:titleItem atIndex:insertIndex++];
	[menuItems addObject:titleItem];
	[titleItem release];
	
	NSArray *latestStats = [aProject latestStatuses];
	NSInteger unreadCount = 0;
	for (NSInteger i = 0; i < [latestStats count]; i++) {
		BNStatus *currStatus = [latestStats objectAtIndex:i];
		NPBlocksMenuItem *currItem = [[NPBlocksMenuItem alloc] initWithTitle:[[currStatus title] stringByTruncatingToWidth:300.0 withFont:[NSFont menuFontOfSize:14.0]] block:^(NSMenuItem *item) {
			NSURL *theURL = [currStatus URL];
			if (theURL != nil)
				[[NSWorkspace sharedWorkspace] openURL:theURL];
			[currStatus setRead:YES];
			[item setState:NSOffState];
			[self _doNotificationIfNecessary];
		} keyEquivalent:@""];
		[currItem setOnStateImage:_onStateImage];
		[currItem setState:[currStatus isRead] ? NSOffState : NSOnState];
		if (![currStatus isRead])
			unreadCount++;
		NSImage *theImage = nil;
		switch ([currStatus type]) {
			case BNStatusTypeTodo:
				theImage = _todoImage;
				break;
			case BNStatusTypeMessage:
				theImage = _messageImage;
				break;
			case BNStatusTypeComment:
				theImage = _commentImage;
				break;
			case BNStatusTypeFileUpload:
				theImage = _fileUploadImage;
				break;
			default:
				theImage = _unknownImage;
				break;
		}
		[currItem setImage:theImage];
		[menuItems addObject:currItem];
		[menu insertItem:currItem atIndex:insertIndex++];
		[currItem release];
	}
	
	NSMenuItem *separatorItem = [NSMenuItem separatorItem];
	[menu insertItem:separatorItem atIndex:insertIndex];
	[menuItems addObject:separatorItem];
	
	[_projectDictionary setObject:menuItems forKey:aProject];
	
	[titleItem setBlock:^(NSMenuItem *item) {
		NSURL *theURL = [aProject URL];
		if (theURL != nil)
			[[NSWorkspace sharedWorkspace] openURL:theURL];
		for (BNStatus *currStatus in [aProject latestStatuses]) {
			[currStatus setRead:YES];
		}
		for (NSMenuItem *currItem in menuItems) {
			[currItem setState:NSOffState];
		}
		[self _doNotificationIfNecessary];
	}];
	
	if (unreadCount > 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:BNNewStatusesAddedNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:unreadCount], @"BNNewStatusCountKey", aProject, @"BNProjectKey", nil]];
	}
}

- (void)updateProject:(BNProject *)aProject {
	NSMutableArray *newStatuses = [[[aProject latestStatuses] mutableCopy] autorelease];
	BNProject *oldProject = nil;
	for (BNProject *currProject in _sortedProjects)
		if ([currProject isEqual:aProject])
			oldProject = currProject;
	if (oldProject != nil) {
		for (BNStatus *currentStatus in [oldProject latestStatuses]) {
			if (![currentStatus isRead] && ![[aProject latestStatuses] containsObject:currentStatus])
				[newStatuses addObject:currentStatus];
		}
	}
	[aProject setLatestStatuses:newStatuses];
	[self removeProject:aProject];
	[self addProject:aProject];
}

- (void)removeProject:(BNProject *)aProject {
	if (aProject == nil || ![[_projectDictionary allKeys] containsObject:aProject] || ![_sortedProjects containsObject:aProject])
		return;
	NSArray *menuItems = [_projectDictionary objectForKey:aProject];
	for (NSMenuItem *currItem in menuItems) {
		if ([[menu itemArray] containsObject:currItem] && ![currItem isSeparatorItem])
			[menu removeItem:currItem];
	}
	NSMenuItem *possibleItem = [[menu itemArray] objectAtIndex:[self _menuIndexForProject:aProject]];
	if ([possibleItem isSeparatorItem])
		[menu removeItem:possibleItem];
	[_projectDictionary removeObjectForKey:aProject];
	[_sortedProjects removeObject:_sortedProjects];
}

#pragma mark Private Methods

- (void)_receivedNotification:(NSNotification *)aNotification {
	if ([[aNotification name] isEqual:BNStatusesDownloadedNotification]) {
		NSArray *projArray = [[aNotification userInfo] objectForKey:BNProjectArrayKey];
		NSMutableArray *toRemove = [[[_projectDictionary allKeys] mutableCopy] autorelease];
		for (BNProject *currProject in projArray) {
			NSInteger arrayCount = [[currProject latestStatuses] count];
			[currProject setLatestStatuses:[[currProject latestStatuses] subarrayWithRange:NSMakeRange(0, arrayCount < 5 ? arrayCount : 5)]];
			if (![[_projectDictionary allKeys] containsObject:currProject]) {
				[self addProject:currProject];
			} else {
				[self updateProject:currProject];
				[toRemove removeObject:currProject];
			}
		}
		for (BNProject *currProject in toRemove)
			[self removeProject:currProject];
		[self _doNotificationIfNecessary];
	}
}

- (void)_doNotificationIfNecessary {
	BOOL hasUnRead = NO;
	BOOL areAllRead = YES;
	for (BNProject *currProj in [_projectDictionary allKeys]) {
		for (BNStatus *currStatus in [currProj latestStatuses]) {
			if (![currStatus isRead]) {
				areAllRead = NO;
				hasUnRead = YES;
			}
		}
	}
	if (hasUnRead)
		[[NSNotificationCenter defaultCenter] postNotificationName:BNHasUnreadStatusesNotification object:self];
	else if (areAllRead)
		[[NSNotificationCenter defaultCenter] postNotificationName:BNAllStatusesReadNotification object:self];
}

- (NSInteger)_menuIndexForProject:(BNProject *)theProject {
	NSInteger retIndex = 0;
	for (BNProject *currProject in _sortedProjects) {
		if ([currProject isEqual:theProject])
			return retIndex;
		NSArray *latestStats = [currProject latestStatuses];
		retIndex += [latestStats count];
		retIndex += 2; //One for the title, one for the separator
	}
	return -1;
}

- (void)_sortProjectArray:(NSMutableArray *)theArray {
	NSSortDescriptor *compSortDesc = [[NSSortDescriptor alloc] initWithKey:@"companyName" ascending:YES];
	NSSortDescriptor *nameSortDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[theArray sortUsingDescriptors:[NSArray arrayWithObjects:compSortDesc, nameSortDesc, nil]];
	[compSortDesc release];
	[nameSortDesc release];
}

#pragma mark Singleton Methods

static BNMenuController *sharedInstance = nil;

+ (BNMenuController *)sharedController {
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
