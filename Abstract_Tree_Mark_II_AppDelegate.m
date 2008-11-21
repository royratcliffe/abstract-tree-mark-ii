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
		[[[RRCoreDataStack sharedInstance] coordinator] addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error];
	}
	if (error)
	{
		[NSApp presentError:error];
	}
	
	// Watch out for this! Make sure that the data is available before enabling
	// auto-save for expanded items. You can switch it on within the
	// nib. Problem though is that the data store must be available at nib
	// awaking time! Otherwise, how can the auto-saving of expanded items
	// compare against existing items in order to determine whether or not they
	// should be restored as expanded or not.
	// There's another caveat. You need to let the bindings make the necessary
	// connections first, before connecting the Core Data context and persistent
	// store coordinator to the store. In other words, the store must be added
	// last. Here is a good place. Application-did-finish-launching occurs after
	// all nib awaking methods, after bindings have been established. Hence,
	// when the store gets added, the outline view immediately sees the contents
	// through its bindings. Otherwise the outline-view expanded items
	// auto-saver cannot see the items at all.
	[outlineView setAutosaveExpandedItems:YES];
	
	[outlineView registerForDraggedTypes:[NSArray arrayWithObject:kAbstractTreeNodeType]];
	
	// The tree controller needs a sort descriptor, sorting by "order" key. The
	// key contains an integer value specifying the order. Although moving items
	// around does not re-sort, initial ordering necessarily applies the given
	// sort descriptors.
	[treeController setSortDescriptors:[NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease], nil]];
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

// write items
- (BOOL)outlineView:(NSOutlineView *)ov
		 writeItems:(NSArray *)items
	   toPasteboard:(NSPasteboard *)pasteboard
{
	[pasteboard declareTypes:[NSArray arrayWithObject:kAbstractTreeNodeType] owner:self];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:[[items objectAtIndex:0] indexPath]] forType:kAbstractTreeNodeType];
	return YES;
}

// validate drop
- (NSDragOperation)outlineView:(NSOutlineView *)ov
				  validateDrop:(id <NSDraggingInfo>)info
				  proposedItem:(id)item
			proposedChildIndex:(NSInteger)index
{
	// If the proposed drop item is a descendant of the item being dragged,
	// answer none for drag operation. You cannot do it; not in one operation at
	// least. Only move the drag item if, and only if, the proposed target is
	// not the item itself nor any of the proposed item's parents.
	NSTreeNode *node = [[treeController arrangedObjects] descendantNodeAtIndexPath:[NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:kAbstractTreeNodeType]]];
	for (NSTreeNode *parentNode = item; parentNode; parentNode = [parentNode parentNode])
	{
		if (node == parentNode) return NSDragOperationNone;
	}
	return NSDragOperationMove;
}

// accept drop
- (BOOL)outlineView:(NSOutlineView *)ov
		 acceptDrop:(id <NSDraggingInfo>)info
			   item:(id)item
		 childIndex:(NSInteger)index
{
	// Note, argument "index" equals NSOutlineViewDropOnItemIndex (value of
	// minus one) when the user drops an item directly on top of another.
	// Also note, moving a node does not rearrange the objects. If sorting
	// descriptors apply, moving does not re-apply the descriptors
	// automatically.
	NSIndexPath *indexPath;
	if (item == nil)
	{
		if (index == NSOutlineViewDropOnItemIndex)
		{
			index = [[[treeController arrangedObjects] childNodes] count];
		}
		indexPath = [NSIndexPath indexPathWithIndex:index];
	}
	else
	{
		if (index == NSOutlineViewDropOnItemIndex)
		{
			index = [[item childNodes] count];
		}
		indexPath = [[item indexPath] indexPathByAddingIndex:index];
	}
	[treeController moveNode:[[treeController arrangedObjects] descendantNodeAtIndexPath:[NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:kAbstractTreeNodeType]]] toIndexPath:indexPath];
	[treeController orderRepresentedObjectsForKey:@"order"];
	return YES;
}

@end
