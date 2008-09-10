// Abstract_Tree_Mark_II_AppDelegate.h
//
// Copyright © 2008, Roy Ratcliffe, Lancaster, United Kingdom
// All rights reserved
//
//------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface Abstract_Tree_Mark_II_AppDelegate : NSObject
{
	IBOutlet NSWindow *window;
	IBOutlet NSOutlineView *outlineView;
}

- (IBAction)saveAction:(id)sender;

@end
