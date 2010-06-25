//
//  BNUserNotificationController.h
//  Basecamp Notifications
//
//  Created by Nick Paulson on 6/25/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface BNUserNotificationController : NSObject<GrowlApplicationBridgeDelegate> {

}

+ (BNUserNotificationController *)sharedController;

@end
