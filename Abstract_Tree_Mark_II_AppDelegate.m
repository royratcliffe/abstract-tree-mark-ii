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

static NSString *kAbstractTreeNodeType = @"AbstractTreeNodeType";

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
	// There's another caveat. You need to let the bindings make the necessary connections first, before connecting the Core Data context and persistent store coordinator to the store. In other words, the store must be added last. Here is a good place. Application-did-finish-launching occurs after all nib awaking methods, after bindings have been established. Hence, when the store gets added, the outline view immediately sees the contents through its bindings. Otherwise the outline-view expanded items auto-saver cannot see the items at all.
	[outlineView setAutosaveExpandedItems:YES];
	[outlineView registerForDraggedTypes:[NSArray arrayWithObject:kAbstractTreeNodeType]];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	return [[RRCoreDataStack sharedInstance] applicationShouldTerminate];
}

- (IBAction)saveAction:(id)sender
{
	[[RRCoreDataStack sharedInstance] save:sender];
}

#pragma mark Outline View Data Source

- (id)outlineView:(NSOutlineView *)ov itemForPersistentObject:(id)object
{
	return [[RROutlineViewExpandedItemsAutosaver sharedOutlineViewExpandedItemsAutosaver] outlineView:ov itemForPersistentObject:object];
}

- (id)outlineView:(NSOutlineView *)ov persistentObjectForItem:(id)item
{
	return [[RROutlineViewExpandedItemsAutosaver sharedOutlineViewExpandedItemsAutosaver] outlineView:ov persistentObjectForItem:item];
}

#pragma mark Outline View Optional Drag & Drop Support

- (BOOL)outlineView:(NSOutlineView *)ov writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
	NSIndexPath *indexPath = [[items objectAtIndex:0] indexPath];
	NSData *indexPathData = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
	[pasteboard declareTypes:[NSArray arrayWithObject:kAbstractTreeNodeType] owner:self];
	[pasteboard setData:indexPathData forType:kAbstractTreeNodeType];
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
	return index == -1 ? NSDragOperationGeneric : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
	NSIndexPath *indexPath = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:kAbstractTreeNodeType]];
	id root = [treeController arrangedObjects];
	NSTreeNode *node = [root descendantNodeAtIndexPath:indexPath];
	[treeController moveNode:node toIndexPath:[[item indexPath] indexPathByAddingIndex:0]];
	return YES;
}

@end
