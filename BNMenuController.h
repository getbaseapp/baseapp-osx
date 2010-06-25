//
//  BNMenuController.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 2/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//BNNewStatusCountKey --> NSNumber
//BNProjectKey --> BNProject
extern NSString * const BNNewStatusesAddedNotification;

@class BNProject, BNPreferencesWindowController;
@interface BNMenuController : NSObject {
	NSMutableArray *_sortedProjects;
	NSMutableDictionary *_projectDictionary; //BNProject --> NSMutableArray of NSMenuItems
	NSMenu *menu;
	BNPreferencesWindowController *preferencesWindow;
}

@property (retain, readonly) NSMenu *menu;

+ (BNMenuController *)sharedController;
- (void)addProject:(BNProject *)aProject;
- (void)updateProject:(BNProject *)aProject;
- (void)removeProject:(BNProject *)aProject;

@end
