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
- (NSInteger)_menuIndexForProject:(BNProject *)theProject inArray:(NSArray *)sortedArray;
- (NSMenuItem *)_newItemForStatus:(BNStatus *)currentStatus;
- (void)_receivedNotification:(NSNotification *)aNotification;
- (void)_terminatingNotificationReceived:(NSNotification *)aNotification;
- (void)_notifyAndUpdateUI;
- (NSMenuItem *)_separatorItemForProject:(BNProject *)aProject;
- (void)_updateTitleItemForProject:(BNProject *)theProject;
- (void)_reorganizeMenu;
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_terminatingNotificationReceived:) name:NSApplicationWillTerminateNotification object:NSApp];
		
		NSMenu *theMenu = [[NSMenu alloc] init];
		[theMenu setDelegate:self];
		
		_markAllItem = [[NPBlocksMenuItem alloc] initWithTitle:@"Mark All As Read" block:^(NSMenuItem *item) {
			[self markAllItemsAsRead];
		} keyEquivalent:@""];
		[theMenu addItem:_markAllItem];
		[_markAllItem setHidden:YES];
		
		_markAllSepItem = [[NSMenuItem separatorItem] retain];
		[theMenu addItem:_markAllSepItem];
		[_markAllSepItem setHidden:YES];
		
		NPBlocksMenuItem *menuItem = [[NPBlocksMenuItem alloc] initWithTitle:@"Preferences..." block:^(NSMenuItem *item) {
			[NSApp activateIgnoringOtherApps:YES];
			[preferencesWindow showWindow:self];
		} keyEquivalent:@""];
		[theMenu addItem:menuItem];
		[menuItem release];
		
		menuItem = [[NPBlocksMenuItem alloc] initWithTitle:@"Quit Flare" block:^(NSMenuItem *item) {
			[NSApp terminate:self];
		} keyEquivalent:@""];
		
		[theMenu addItem:menuItem];
		[menuItem release];
		
		[self setMenu:theMenu];
		[theMenu release];
		_projectDictionary = [[NSMutableDictionary alloc] init];
		_sortedProjects = [[NSMutableArray alloc] init];
		NSArray *cachedProjects = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForDataFile]];
		if (cachedProjects != nil && [cachedProjects count] > 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:BNStatusesDownloadedNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:cachedProjects, BNProjectArrayKey, nil]];
		}
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
	NSInteger insertionIndex = [self _menuIndexForProject:aProject inArray:_sortedProjects];
	
	//Capacity includes all statuses, plus the title item and the separator
	NSMutableDictionary *itemDictionary = [NSMutableDictionary dictionaryWithCapacity:[[aProject latestStatuses] count] + 2];
	
	//Create the title item, with the attributed title
	NPBlocksMenuItem *titleItem = [[NPBlocksMenuItem alloc] initWithTitle:@"" block:nil keyEquivalent:@""];
	
	NSFont *theFont = [NSFont fontWithName:@"Lucida Grande" size:14.0];
	NSString *realString = [NSString stringWithFormat:@"%@ (%@)", [aProject name], [aProject companyName]];
	theFont = [[NSFontManager sharedFontManager] convertFont:theFont toHaveTrait:NSBoldFontMask];
	NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:[realString stringByTruncatingToWidth:300.0 withFont:theFont]
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
	
	[titleItem setBlock:^(NSMenuItem *item) {
		NSURL *theURL = [aProject URL];
		if (theURL != nil)
			[[NSWorkspace sharedWorkspace] openURL:theURL];
		[self markProjectAsRead:aProject];
		[self _notifyAndUpdateUI];
	}];
	
	
	NSMutableArray *finalPostArray = [NSMutableArray array];
	for (BNStatus *currStatus in [aProject latestStatuses]) {
		if (![currStatus isRead])
			[finalPostArray addObject:currStatus];
	}
	
	if ([finalPostArray count] > 0)
		[[NSNotificationCenter defaultCenter] postNotificationName:BNNewStatusesAddedNotification object:aProject userInfo:[NSDictionary dictionaryWithObjectsAndKeys:finalPostArray, @"BNNewStatusesArray", nil]];
}

- (void)updateProject:(BNProject *)aProject {
	//Get BNMenuItemRef --> BNStatus dict.
	NSMutableDictionary *projItemDict = [_projectDictionary objectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:aProject]]];
	
	NSMutableArray *newStatusesArray = [NSMutableArray array];
	for (BNStatus *currStatus in [aProject latestStatuses]) {
		if (![projItemDict containsValue:currStatus])
			[newStatusesArray addObject:currStatus];
	}
	
	
	//An array of BNMenuItemRefs
	NSMutableArray *toDelete = [[[projItemDict allKeys] mutableCopy] autorelease];
	NSInteger insertionIndex = 1 + [self _menuIndexForProject:aProject inArray:_sortedProjects];
	for (BNStatus *currentStatus in [aProject latestStatuses]) {
		//If the dictionary contains the status (the menu already has the status)
		if ([projItemDict containsValue:currentStatus]) {
			//Do not include the item in the array to be removed
			[toDelete removeObject:[projItemDict firstKeyForValue:currentStatus]];
		} else {
			//Create a new item
			NSMenuItem *currItem = [self _newItemForStatus:currentStatus];
			[projItemDict setObject:currentStatus forKey:[BNMenuItemRef menuItemRefForMenuItem:currItem]];
			[menu insertItem:currItem atIndex:insertionIndex++];		
			
		}
	}
	projItemDict = [_projectDictionary objectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:aProject]]];
	[_sortedProjects replaceObjectAtIndex:[_sortedProjects indexOfObject:aProject] withObject:aProject];
	//For all the items that are left (aka ones that are too old)
	for (BNMenuItemRef *currRef in toDelete) {
		//if the menu contains it, and that it is a status.
		if ([menu containsItem:[currRef menuItem]] && [[[projItemDict objectForKey:currRef] class] isEqual:[BNStatus class]]) {
			//Remove the item
			[menu removeItem:[currRef menuItem]];
		}
	}
	
	//Fix up the title item block
	NSArray *potentialTitles = [projItemDict keysForValue:[NSNull null]];
	for (BNMenuItemRef *currRef in potentialTitles) {
		NSMenuItem *theItem = [currRef menuItem];
		if (![theItem isSeparatorItem]) {
			[(NPBlocksMenuItem *)theItem setBlock:^(NSMenuItem *item) {
				NSURL *theURL = [aProject URL];
				if (theURL != nil)
					[[NSWorkspace sharedWorkspace] openURL:theURL];
				[self markProjectAsRead:aProject];
				[self _notifyAndUpdateUI];
			}];
			
			break;
		}
	}
	
	NSMutableArray *finalPostArray = [NSMutableArray array];
	for (BNStatus *currStatus in newStatusesArray) {
		if (![currStatus isRead])
			[finalPostArray addObject:currStatus];
	}
	
	if ([finalPostArray count] > 0)
		[[NSNotificationCenter defaultCenter] postNotificationName:BNNewStatusesAddedNotification object:aProject userInfo:[NSDictionary dictionaryWithObjectsAndKeys:finalPostArray, @"BNNewStatusesArray", nil]];
	
}

- (void)updateMenuItemStatusesForProject:(BNProject *)theProject {
	if ([_sortedProjects indexOfObject:theProject] == NSNotFound || [[_projectDictionary allKeys] indexOfObject:theProject] == NSNotFound)
		return;
	BNProject *dictProject = [[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:theProject]];
	NSMutableDictionary *projItemDict = [_projectDictionary objectForKey:dictProject];
	for (BNStatus *currStatus in theProject.latestStatuses) {
		BNMenuItemRef *firstRef = [projItemDict firstKeyForValue:currStatus];
		[[firstRef menuItem] setState:currStatus.read ? NSOffState : NSOnState];
		[[firstRef menuItem] setHidden:currStatus.read];
	}
	[dictProject setLatestStatuses:theProject.latestStatuses];
	
	[_sortedProjects replaceObjectAtIndex:[_sortedProjects indexOfObject:theProject] withObject:theProject];
	[self _notifyAndUpdateUI];
	
	BOOL hasUnread = NO;
	for (BNProject *currProject in _sortedProjects) {
		for (BNStatus *currStatus in currProject.latestStatuses) {
			if (![currStatus isRead]) {
				hasUnread = YES;
				break;
			}
		}
		if (hasUnread)
			break;
	}
	if (!hasUnread)
		[[NSNotificationCenter defaultCenter] postNotificationName:BNAllStatusesReadNotification object:self];
}

- (void)removeProject:(BNProject *)aProject {
	//Get BNMenuItemRef --> BNStatus dict.
	NSMutableDictionary *projItemDict = [_projectDictionary objectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:aProject]]];
	//An array of BNMenuItemRefs
	NSMutableArray *toDelete = [[[projItemDict allKeys] mutableCopy] autorelease];
	
	for (BNMenuItemRef *currRef in toDelete) {
		//if the menu contains it
		if ([menu containsItem:[currRef menuItem]]) {
			//Remove the item
			[menu removeItem:[currRef menuItem]];
		}
	}
	[_projectDictionary removeObjectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:aProject]]];
	[_sortedProjects removeObject:[_sortedProjects objectAtIndex:[_sortedProjects indexOfObject:aProject]]];
	[self _notifyAndUpdateUI];
}

- (void)removeProjectsForAccount:(BNAccount *)theAccount {
	NSArray *tempArray = [[_sortedProjects copy] autorelease];
	for (BNProject *currProject in tempArray) {
		if ([[currProject account] isEqual:theAccount])
			[self removeProject:currProject];
	}
}

- (void)markProjectAsRead:(BNProject *)aProject {
	//Get BNMenuItemRef --> BNStatus dict.
	NSMutableDictionary *projectDict = [_projectDictionary objectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:aProject]]];
	for (BNStatus *currStatus in [projectDict allValues]) {
		if ([currStatus isKindOfClass:[BNStatus class]])
			[currStatus setRead:YES];
	}
	BNProject *sortedProject = [_sortedProjects objectAtIndex:[_sortedProjects indexOfObject:aProject]];
	for (BNStatus *currStatus in sortedProject.latestStatuses) {
		[currStatus setRead:YES];
	}
	for (BNMenuItemRef *currItem in [projectDict allKeys]) {
		//Protection against the title and separator items
		if ([[currItem menuItem] state] == NSOnState) {
			[[currItem menuItem] setState:NSOffState];
		}
		if ([[projectDict objectForKey:currItem] isKindOfClass:[BNStatus class]])
			[[currItem menuItem] setHidden:YES];
	}
}

- (void)markAllItemsAsRead {
	for (BNProject *aProject in [_projectDictionary allKeys]) {
		NSMutableDictionary *projectDict = [_projectDictionary objectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:aProject]]];
		for (BNStatus *currStatus in [projectDict allValues]) {
			if ([currStatus isKindOfClass:[BNStatus class]]) {
				[currStatus setRead:YES];
			}
		}
		
		BNProject *sortedProject = [_sortedProjects objectAtIndex:[_sortedProjects indexOfObject:aProject]];
		for (BNStatus *currStatus in sortedProject.latestStatuses) {
			[currStatus setRead:YES];
		}
		
		for (BNMenuItemRef *currItem in [projectDict allKeys]) {
			//Protection against the title and separator items
			if ([[currItem menuItem] state] == NSOnState) {
				[[currItem menuItem] setState:NSOffState];
			}
			if ([[projectDict objectForKey:currItem] isKindOfClass:[BNStatus class]])
				[[currItem menuItem] setHidden:YES];
		}
	}
	
	[self _notifyAndUpdateUI];
}

- (void)menuDidClose:(NSMenu *)menu {
	[[NSNotificationCenter defaultCenter] postNotificationName:BNAllStatusesReadNotification object:self];
}

#pragma mark Private Methods

- (void)_sortProjectArray:(NSMutableArray *)theArray {
	NSSortDescriptor *hasUnreadDesc = [[NSSortDescriptor alloc] initWithKey:@"hasUnread" ascending:NO];
	NSSortDescriptor *compSortDesc = [[NSSortDescriptor alloc] initWithKey:@"companyName" ascending:YES];
	NSSortDescriptor *nameSortDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[theArray sortUsingDescriptors:[NSArray arrayWithObjects:hasUnreadDesc, compSortDesc, nameSortDesc, nil]];
	[hasUnreadDesc release];
	[compSortDesc release];
	[nameSortDesc release];
}

- (NSInteger)_menuIndexForProject:(BNProject *)theProject inArray:(NSArray *)sortedArray {
	NSInteger i = 2;  //One for mark all button, one for separator item.
	for (BNProject *currProject in sortedArray) {
		if ([currProject isEqual:theProject])
			break;
		i += [[currProject latestStatuses] count] + 2;
	}
	return i;
}

- (void)_notifyAndUpdateUI {
	[_markAllItem setHidden:[self allStatusesAreRead]];
	[_markAllSepItem setHidden:[_markAllItem isHidden]];
	[self _reorganizeMenu];
	for (BNProject *currProj in _sortedProjects) {
		NSMenuItem *sepItem = [self _separatorItemForProject:currProj];
		if (![[currProj hasUnread] boolValue]) {
			[sepItem setHidden:![[_sortedProjects lastObject] isEqual:currProj]];
		} else
			[sepItem setHidden:NO];
		
		[self _updateTitleItemForProject:currProj];
	}
	
}

- (void)_reorganizeMenu {
	NSArray *oldArray = [[_sortedProjects copy] autorelease];
	[self _sortProjectArray:_sortedProjects];
	for (NSInteger i = 0; i < [_sortedProjects count] && i < [oldArray count]; i++) {
		BNProject *oldProject = [oldArray objectAtIndex:i];
		BNProject *newProject = [_sortedProjects objectAtIndex:i];
		if (![oldProject isEqual:newProject]) {
			NSMutableDictionary *projectDict = [_projectDictionary objectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:oldProject]]];
			for (BNMenuItemRef *currRef in [projectDict allKeys]) {
				if ([menu containsItem:[currRef menuItem]])
					[menu removeItem:[currRef menuItem]];
			}
			NSInteger insertIndex = [self _menuIndexForProject:oldProject inArray:_sortedProjects];
			NSInteger origIndex = insertIndex;
			NSMutableArray *lastItemsArray = [[[projectDict allKeys] mutableCopy] autorelease];
			for (BNStatus *currStatus in oldProject.latestStatuses) {
				BNMenuItemRef *theRef = [projectDict firstKeyForValue:currStatus];
				if (theRef != nil)
					[menu insertItem:[theRef menuItem] atIndex:insertIndex++];
				[lastItemsArray removeObject:theRef];
			}
			for (BNMenuItemRef *currRef in lastItemsArray) {
				if (![[projectDict objectForKey:currRef] isKindOfClass:[BNStatus class]]) {
					if ([[currRef menuItem] isSeparatorItem] && ![menu containsItem:[currRef menuItem]])
						[menu insertItem:[currRef menuItem] atIndex:insertIndex];
					else if (![menu containsItem:[currRef menuItem]]) {
						[menu insertItem:[currRef menuItem] atIndex:origIndex];
						insertIndex++;
					}
				}
			}
		}
	}	
}

- (NSMenuItem *)_separatorItemForProject:(BNProject *)aProject {
	NSMenuItem *sepItem = nil;
	//Get BNMenuItemRef --> BNStatus dict.
	NSMutableDictionary *projItemDict = [_projectDictionary objectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:aProject]]];
	
	NSArray *potentialItems = [projItemDict keysForValue:[NSNull null]];
	for (BNMenuItemRef *theRef in potentialItems) {
		if ([[theRef menuItem] isSeparatorItem]) {
			sepItem = [theRef menuItem];
			break;
		}
	}
	return sepItem;
}

- (NSMenuItem *)_titleItemForProject:(BNProject *)aProject {
	NSMenuItem *titleItem = nil;
	//Get BNMenuItemRef --> BNStatus dict.
	NSMutableDictionary *projItemDict = [_projectDictionary objectForKey:[[_projectDictionary allKeys] objectAtIndex:[[_projectDictionary allKeys] indexOfObject:aProject]]];
	
	NSArray *potentialItems = [projItemDict keysForValue:[NSNull null]];
	for (BNMenuItemRef *theRef in potentialItems) {
		if (![[theRef menuItem] isSeparatorItem]) {
			titleItem = [theRef menuItem];
			break;
		}
	}
	return titleItem;
}

- (void)_updateTitleItemForProject:(BNProject *)aProject {
	NSMenuItem *titleItem = [self _titleItemForProject:aProject];
	if (titleItem != nil) {
		NSFont *theFont = [NSFont fontWithName:@"Lucida Grande" size:14.0];
		NSString *realString = [NSString stringWithFormat:@"%@ (%@)", [aProject name], [aProject companyName]];
		if ([[aProject hasUnread] boolValue]) {
			
			theFont = [[NSFontManager sharedFontManager] convertFont:theFont toHaveTrait:NSBoldFontMask];
			NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:[realString stringByTruncatingToWidth:300.0 withFont:theFont]
																			  attributes:[NSDictionary dictionaryWithObjectsAndKeys:theFont, NSFontAttributeName, 
																						  [NSColor blackColor], NSForegroundColorAttributeName, nil]];
			[titleItem setAttributedTitle:titleString];
			[titleString release];
		} else {
			[titleItem setAttributedTitle:nil];
			[titleItem setTitle:[realString stringByTruncatingToWidth:300.0 withFont:[NSFont menuFontOfSize:14.0]]];
		}
	}
}

- (void)_receivedNotification:(NSNotification *)aNotification {
	if ([[aNotification name] isEqual:BNStatusesDownloadedNotification]) {
		NSArray *projArray = [[aNotification userInfo] objectForKey:BNProjectArrayKey];
		BOOL shouldPostNotification = NO;
		for (BNProject *currProject in projArray) {
			NSInteger arrayCount = [[currProject latestStatuses] count];
			[currProject setLatestStatuses:[[currProject latestStatuses] subarrayWithRange:NSMakeRange(0, arrayCount < 5 ? arrayCount : 5)]];
			if (![_sortedProjects containsObject:currProject]) {
				[self addProject:currProject];
				for (BNStatus *currStatus in currProject.latestStatuses) {
					if (![currStatus isRead]) {
						shouldPostNotification = YES;
						break;
					}
				}
			} else {
				NSMutableArray *newStatuses = [[[currProject latestStatuses] mutableCopy] autorelease];
				BNProject *oldProject = [_sortedProjects objectAtIndex:[_sortedProjects indexOfObject:currProject]];
				for (BNStatus *currentStatus in [oldProject latestStatuses]) {
					if (![currentStatus isRead] && ![[currProject latestStatuses] containsObject:currentStatus]) {
						[newStatuses addObject:currentStatus];
					} else if ([currentStatus isRead] && [newStatuses containsObject:currentStatus]) {
						BNStatus *exactStatus = [newStatuses objectAtIndex:[newStatuses indexOfObject:currentStatus]];
						[exactStatus setRead:YES];
					}
				}
				for (BNStatus *currStatus in newStatuses) {
					if ([oldProject.latestStatuses indexOfObject:currStatus] == NSNotFound && ![currStatus isRead]) {
						shouldPostNotification = YES;
						break;
					}
				}
				[currProject setLatestStatuses:newStatuses];
				[self updateProject:currProject];
			}
		}
		
		
		
		if (shouldPostNotification)
			[[NSNotificationCenter defaultCenter] postNotificationName:BNHasUnreadStatusesNotification object:self];
		
		[self _notifyAndUpdateUI];
	}
}

- (BOOL)allStatusesAreRead {
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
		if (!allRead)
			break;
	}
	return allRead;
}

- (NSString *)pathForDataFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/Flare/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath:folder] == NO) {
		[fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
	}
    
	NSString *fileName = @"CachedStatuses.flaredata";
	return [folder stringByAppendingPathComponent:fileName];    
}

- (void)_terminatingNotificationReceived:(NSNotification *)aNotification {
	[NSKeyedArchiver archiveRootObject:_sortedProjects toFile:[self pathForDataFile]];
}

- (NSMenuItem *)_newItemForStatus:(BNStatus *)currentStatus {
	NPBlocksMenuItem *currItem = [[NPBlocksMenuItem alloc] initWithTitle:[[currentStatus title] stringByTruncatingToWidth:300.0 withFont:[NSFont menuFontOfSize:14.0]] block:^(NSMenuItem *item) {
		NSURL *theURL = [currentStatus URL];
		if (theURL != nil)
			[[NSWorkspace sharedWorkspace] openURL:theURL];
		[currentStatus setRead:YES];
		for (BNProject *currProj in _sortedProjects) {
			if ([currProj.latestStatuses containsObject:currentStatus]) {
				BNStatus *theStatus = [currProj.latestStatuses objectAtIndex:[currProj.latestStatuses indexOfObject:currentStatus]];
				[theStatus setRead:YES];
				break;
			}
		}
		[item setHidden:YES];
		[item setState:NSOffState];
		[self _notifyAndUpdateUI];
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
	[currItem setHidden:[currentStatus isRead]];
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
