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
#import "BNMenuItemRef.h"
#import "NSMenu+NPAdditions.h"
#import "NSDictionary+NPAdditions.h"

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
- (NSMenuItem *)_newItemForStatus:(BNStatus *)currentStatus;
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
	
	//If it is already added, don't add it again.
	if ([_projectDictionary containsKey:aProject] || [_sortedProjects containsObject:aProject])
		return;
	
	//Add project to the projects array, then sort it.
	[_sortedProjects addObject:aProject];
	[self _sortProjectArray:_sortedProjects];

	//Find the insertion point with the new project added.
	//Note that even if it is in there, it will return the index before.
	NSInteger insertionIndex = [self _menuIndexForProject:aProject];

	//Capacity includes all statuses, plus the title item and the separator
	NSMutableDictionary *itemDictionary = [NSMutableDictionary dictionaryWithCapacity:[[aProject latestStatuses] count] + 2];

	//Create the title item, with the attributed title
	NPBlocksMenuItem *titleItem = [[NPBlocksMenuItem alloc] initWithTitle:@"" block:nil keyEquivalent:@""];
	
	NSFont *theFont = [NSFont fontWithName:@"Lucida Grande" size:14.0];
	NSString *realString = [NSString stringWithFormat:@"%@ (%@)", [aProject name], [aProject companyName]];
	theFont = [[NSFontManager sharedFontManager] convertFont:theFont toHaveTrait:NSBoldFontMask];
	NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:[realString stringByTruncatingToWidth:300.0 withFont:[NSFont menuFontOfSize:14.0]]
																	  attributes:[NSDictionary dictionaryWithObjectsAndKeys:theFont, NSFontAttributeName, 
																				  [NSColor blackColor], NSForegroundColorAttributeName, nil]];
	[titleItem setAttributedTitle:titleString];
	[titleString release];
	
	//No status tied to the title item
	[menu insertItem:titleItem atIndex:insertionIndex++];
	[itemDictionary setObject:[NSNull null] forKey:[BNMenuItemRef menuItemRefForMenuItem:titleItem]];
	[titleItem release];
	
	for (BNStatus *currentStatus in [aProject latestStatuses]) {
		NSMenuItem *currItem = [self _newItemForStatus:currentStatus];
	
		[itemDictionary setObject:currentStatus forKey:[BNMenuItemRef menuItemRefForMenuItem:currItem]];
		[menu insertItem:currItem atIndex:insertionIndex++];
	}
	
	//Create the separator item, add it to the dictionary with no status attached, and then insert into menu.
	NSMenuItem *sepItem = [NSMenuItem separatorItem];
	[itemDictionary setObject:[NSNull null] forKey:[BNMenuItemRef menuItemRefForMenuItem:sepItem]];
	[menu insertItem:sepItem atIndex:insertionIndex];
	
	//Add our dictionary to the project dictionary
	[_projectDictionary setObject:itemDictionary forKey:aProject];
}

- (void)updateProject:(BNProject *)aProject {
	//Get BNMenuItemRef --> BNStatus dict.
	NSMutableDictionary *projItemDict = [_projectDictionary objectForKey:aProject];
	
	//An array of BNMenuItemRefs
	NSMutableArray *toDelete = [[[projItemDict allKeys] mutableCopy] autorelease];
	for (BNStatus *currentStatus in [aProject latestStatuses]) {
		//If the dictionary contains the status (the menu already has the status)
		if ([projItemDict containsValue:currentStatus]) {
			//Do not include the item in the array to be removed
			[toDelete removeObject:[projItemDict firstKeyForValue:currentStatus]];
		} else {
			NSInteger insertIndex = -1;
			for (BNStatus *currOldStatus in [projItemDict allValues]) {
				//Make sure it is not an NSNull status
				if ([currentStatus isKindOfClass:[BNStatus class]]) {
					//If the current status is later than the old status
					if ([[currentStatus date] laterDate:[currOldStatus date]] == [currentStatus date]) {
						//Insert index is the same as the old one (it will insert it before)
						insertIndex = [menu indexOfItem:[projItemDict firstKeyForValue:currOldStatus]];
						break;
					}
				}
			}
			
			
			//Create a new item
			NSMenuItem *currItem = [self _newItemForStatus:currentStatus];
			
			[projItemDict setObject:currentStatus forKey:[BNMenuItemRef menuItemRefForMenuItem:currItem]];
			[menu insertItem:currItem atIndex:insertIndex];			
			
		}
	}
	
	//For all the items that are left (aka ones that are too old)
	for (BNMenuItemRef *currRef in toDelete) {
		//if the menu contains it
		if ([menu containsItem:[currRef menuItem]]) {
			//Remove the item
			[menu removeItem:[currRef menuItem]];
		}
	}
}

- (void)removeProject:(BNProject *)aProject {
	//Get BNMenuItemRef --> BNStatus dict.
	NSMutableDictionary *projItemDict = [_projectDictionary objectForKey:aProject];
	//An array of BNMenuItemRefs
	NSMutableArray *toDelete = [[[projItemDict allKeys] mutableCopy] autorelease];
	
	for (BNMenuItemRef *currRef in toDelete) {
		//if the menu contains it
		if ([menu containsItem:[currRef menuItem]]) {
			//Remove the item
			[menu removeItem:[currRef menuItem]];
		}
	}
	[_projectDictionary removeObjectForKey:aProject];
	[_sortedProjects removeObject:aProject];
}

#pragma mark Private Methods

- (void)_sortProjectArray:(NSMutableArray *)theArray {
	NSSortDescriptor *compSortDesc = [[NSSortDescriptor alloc] initWithKey:@"companyName" ascending:YES];
	NSSortDescriptor *nameSortDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[theArray sortUsingDescriptors:[NSArray arrayWithObjects:compSortDesc, nameSortDesc, nil]];
	[compSortDesc release];
	[nameSortDesc release];
}

- (NSInteger)_menuIndexForProject:(BNProject *)theProject {
	NSInteger i = 0;
	for (BNProject *currProject in _sortedProjects) {
		if ([currProject isEqual:theProject])
			break;
		i += [[currProject latestStatuses] count] + 2;
	}
	return i;
}

- (void)_doNotificationIfNecessary {
	BOOL allRead = YES;
	for (BNProject *currProject in [_projectDictionary allKeys]) {
		//Get BNMenuItemRef --> BNStatus dict.
		NSMutableDictionary *projItemDict = [_projectDictionary objectForKey:currProject];
		for (BNStatus *currentStatus in [projItemDict allValues]) {
			if ([currentStatus isKindOfClass:[BNStatus class]] && ![currentStatus isRead]) {
				allRead = NO;
				break;
			}
		}
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:(allRead ? BNAllStatusesReadNotification : BNHasUnreadStatusesNotification) object:self];
}

- (void)_receivedNotification:(NSNotification *)aNotification {
	if ([[aNotification name] isEqual:BNStatusesDownloadedNotification]) {
		NSArray *projArray = [[aNotification userInfo] objectForKey:BNProjectArrayKey];
		for (BNProject *currProject in projArray) {
			NSInteger arrayCount = [[currProject latestStatuses] count];
			[currProject setLatestStatuses:[[currProject latestStatuses] subarrayWithRange:NSMakeRange(0, arrayCount < 5 ? arrayCount : 5)]];
			if (![_sortedProjects containsObject:currProject]) {
				[self addProject:currProject];
			} else {
				NSMutableArray *newStatuses = [[[currProject latestStatuses] mutableCopy] autorelease];
				BNProject *oldProject = nil;
				for (BNProject *currProject in _sortedProjects)
					if ([currProject isEqual:currProject])
						oldProject = currProject;
				if (oldProject != nil) {
					for (BNStatus *currentStatus in [oldProject latestStatuses]) {
						if (![currentStatus isRead] && ![[currProject latestStatuses] containsObject:currentStatus])
							[newStatuses addObject:currentStatus];
						else if ([currentStatus isRead] && [[currProject latestStatuses] containsObject:currentStatus]) {
							BNStatus *exactStatus = [newStatuses objectAtIndex:[newStatuses indexOfObject:currentStatus]];
							[exactStatus setRead:YES];
						}
					}
				}
				[currProject setLatestStatuses:newStatuses];
				[self updateProject:currProject];
			}
		}
		[self _doNotificationIfNecessary];
	}
}

- (NSMenuItem *)_newItemForStatus:(BNStatus *)currentStatus {
	NPBlocksMenuItem *currItem = [[NPBlocksMenuItem alloc] initWithTitle:[[currentStatus title] stringByTruncatingToWidth:300.0 withFont:[NSFont menuFontOfSize:14.0]] block:^(NSMenuItem *item) {
		NSURL *theURL = [currentStatus URL];
		if (theURL != nil)
			[[NSWorkspace sharedWorkspace] openURL:theURL];
		[currentStatus setRead:YES];
		[item setState:NSOffState];
		[self _doNotificationIfNecessary];
	} keyEquivalent:@""];
	
	//Set the custom on state image
	[currItem setOnStateImage:_onStateImage];
	
	//Set the dot status to be what the current status is.
	[currItem setState:[currentStatus isRead] ? NSOffState : NSOnState];
	
	//Determine what the icon image will be
	NSImage *theImage = nil;
	switch ([currentStatus type]) {
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
	//Set the icon image
	[currItem setImage:theImage];
	return [currItem autorelease];
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