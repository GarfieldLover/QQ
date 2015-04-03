#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoom.h"
#import "RoomViewController.h"


@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate,XMPPRoomDelegate>
{
	NSFetchedResultsController *fetchedResultsController;
    NSMutableArray* sectionArray;

    XMPPRoom * _xmppRoom;
}

- (IBAction)settings:(id)sender;

@end
