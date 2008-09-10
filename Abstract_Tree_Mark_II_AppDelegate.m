// Abstract_Tree_Mark_II_AppDelegate.m
//
// Copyright © 2008, Roy Ratcliffe, Lancaster, United Kingdom
// All rights reserved
//
//------------------------------------------------------------------------------

#import "Abstract_Tree_Mark_II_AppDelegate.h"

#import <RRCoreData/RRCoreData.h>
#import <RRAppKit/RRAppKit.h>

@implementation Abstract_Tree_Mark_II_AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	// In the following sequence, two possible errors exist.
	NSError *error = nil;
	NSURL *url = [NSURL appSupportFolderFileURLWithPathComponent:@"Abstract Tree Mark II.xml" error:&error];
	if (url)
	{
		[[RRCoreDataStack sharedInstance].coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error];
	}
	if (error)
	{
		[NSApp presentError:error];
	}
	// Watch out for this! Make sure that the data is available before enabling auto-save for expanded items. You can switch it on within the nib. Problem though is that the data store must be available at nib awaking time! Otherwise, how can the auto-saving of expanded items compare against existing items in order to determine whether or not they should be restored as expanded or not.
	[outlineView setAutosaveExpandedItems:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	return [[RRCoreDataStack sharedInstance] applicationShouldTerminate];
}

- (IBAction)saveAction:(id)sender
{
	[[RRCoreDataStack sharedInstance] save:sender];
}

@end
