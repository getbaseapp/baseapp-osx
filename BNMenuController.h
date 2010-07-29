//
//  BNMenuController.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//@"BNNewStatusesArray" --> New BNStatuses
extern NSString * const BNNewStatusesAddedNotification;

@class BNProject, BNAccount, BNPreferencesWindowController;
@interface BNMenuController : NSObject<NSMenuDelegate> {
	NSMutableArray *_sortedProjects;
	NSMutableDictionary *_projectDictionary; //BNProject --> NSMutableDictionary (BNMenuItemRef --> BNStatus/NSNull)
	NSMenu *menu;
	BNPreferencesWindowController *preferencesWindow;
	NSMenuItem *_markAllItem;
	NSMenuItem *_markAllSepItem;
}

@property (retain, readonly) NSMenu *menu;

+ (BNMenuController *)sharedController;
- (void)addProject:(BNProject *)aProject;
- (void)updateProject:(BNProject *)aProject;
- (void)removeProject:(BNProject *)aProject;
- (void)removeProjectsForAccount:(BNAccount *)theAccount;
- (NSString *)pathForDataFile;
- (void)markAllItemsAsRead;
- (void)markProjectAsRead:(BNProject *)aProject;
- (BOOL)allStatusesAreRead;
- (void)updateMenuItemStatusesForProject:(BNProject *)theProject;

@end
