#import "RootViewController.h"
#import "iPhoneXMPPAppDelegate.h"
#import "SettingsViewController.h"

#import "XMPPFramework.h"
#import "DDLog.h"
#import "ChatViewController.h"
#import "XMPPvCardTemp.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
  static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
  static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface RootViewController ()

@property (nonatomic, strong) RoomViewController *roomVC;


@end



@implementation RootViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (iPhoneXMPPAppDelegate *)appDelegate
{
	return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)viewDidLoad
{
    sectionArray=[NSMutableArray array];
    XMPPvCardTempModule* vCardTemp=[[self appDelegate] xmppvCardTempModule];
    NSString* name=[[vCardTemp myvCardTemp] nickname];

    self.title = [NSString stringWithFormat:@"联系人"];
    [self fetchedResultsController];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createRoom)];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(settings:)];
    

}

-(void)createRoom
{

    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.%@",@"聊天室",@"192.168.9.100"]];
    
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:[[self appDelegate] roomStorage] jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    
    
    [_xmppRoom activate:[self appDelegate].xmppStream];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    XMPPvCardTemp* myvCardTemp=[[[self appDelegate] xmppvCardTempModule] myvCardTemp];
    [_xmppRoom joinRoomUsingNickname:myvCardTemp.nickname history:nil];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
//        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"users" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1];
//        NSArray *sortDescriptors=[NSArray array];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return fetchedResultsController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//    [sectionArray removeAllObjects];
    
    NSArray* userArray= [[self fetchedResultsController] fetchedObjects];
    [userArray enumerateObjectsUsingBlock:^(XMPPUserCoreDataStorageObject* object , NSUInteger idx, BOOL *stop){
        XMPPGroupCoreDataStorageObject *group=[[object.groups allObjects] firstObject];
        if(![sectionArray containsObject:group] && group!=nil){
            [sectionArray addObject:group];
        }
    }];
    [[self tableView] reloadData];
    
    
#if 0
    if(sectionArray.count==0){

    }else{
        NSArray* userArray= [[self fetchedResultsController] fetchedObjects];
        [userArray enumerateObjectsUsingBlock:^(XMPPUserCoreDataStorageObject* object , NSUInteger idx, BOOL *stop){
            XMPPGroupCoreDataStorageObject *group=[[object.groups allObjects] firstObject];
            
            if(![sectionArray containsObject:group]){
                [sectionArray addObject:group];
                
                NSIndexSet* indexset=[NSIndexSet indexSetWithIndex:[sectionArray indexOfObject:group]];
                [[self tableView] reloadSections:indexset withRowAnimation:UITableViewRowAnimationNone];
            }else{
                XMPPGroupCoreDataStorageObject *oldgroup=[sectionArray objectAtIndex:[sectionArray indexOfObject:group]];
                [oldgroup.users.allObjects enumerateObjectsUsingBlock:^(XMPPUserCoreDataStorageObject* oldobject , NSUInteger idx, BOOL *stop){
                    if([oldobject.jidStr isEqualToString:object.jidStr] && oldobject.section!=object.section){
                        NSIndexPath* indexP=[NSIndexPath indexPathForRow:idx inSection:[sectionArray indexOfObject:group]];
                        [[self tableView] reloadRowsAtIndexPaths:@[indexP] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }];
            }
        }];
    }
#endif

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
    cell.textLabel.text = user.displayName;
    
    [[cell.contentView viewWithTag:111] removeFromSuperview];
    
    UILabel* onlineLabel=[[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-60, 0, 60, cell.frame.size.height)];
    [cell.contentView addSubview:onlineLabel];
    onlineLabel.tag=111;
    
    switch (user.section)
    {
        case 0:
            onlineLabel.text=@"在线";
            break;
        case 1:
            onlineLabel.text=@"离开";
            break;
        default:
            onlineLabel.text=@"离线";
    }
//online状态更新
	if (user.photo != nil)
    {
        cell.imageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil){
            cell.imageView.image = [UIImage imageWithData:photoData];

        }else{
            cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];

        }
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return sectionArray.count;
}


- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    XMPPGroupCoreDataStorageObject *group = [sectionArray objectAtIndex:sectionIndex];
    return group.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    XMPPGroupCoreDataStorageObject *group = [sectionArray objectAtIndex:sectionIndex];
    return group.users.allObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
		                               reuseIdentifier:CellIdentifier];
	}
	
    XMPPGroupCoreDataStorageObject *group = [sectionArray objectAtIndex:indexPath.section];
	XMPPUserCoreDataStorageObject *user = [[group.users allObjects] objectAtIndex:indexPath.row];
	
    
	[self configurePhotoForCell:cell user:user];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewController* chatVC=[[ChatViewController alloc] init];
    XMPPGroupCoreDataStorageObject *group = [sectionArray objectAtIndex:indexPath.section];
    XMPPUserCoreDataStorageObject *user = [[group.users allObjects] objectAtIndex:indexPath.row];
    chatVC.xmppUserObject=user;
    [self.navigationController pushViewController:chatVC animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)settings:(id)sender
{
	[self.navigationController presentViewController:[[self appDelegate] settingsViewController] animated:YES completion:NULL];
}






#pragma mark - xmpproom delegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"%@",sender);

    [sender configureRoomUsingOptions:nil];
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSLog(@"%s",__func__);
//    [_roomVC configurateRoomWithData:configForm];
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm
{
    NSLog(@"%@",roomConfigForm);
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"seccuss" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//    [alert show];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"failed" message:iqResult.description delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
    

    self.roomVC=[[RoomViewController alloc] init];
    self.roomVC.xmppRoom = _xmppRoom;
    [self.navigationController pushViewController:self.roomVC animated:YES];
    
    
}
- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);

}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
    
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
    
}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
 **/
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    if([_xmppRoom.myRoomJID isEqualToJID:occupantJID]){
        return;
    }

}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    NSLog(@"%@",items);
//    [_roomVC  listMemberWithData:items type:memberType_ban];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSLog(@"%@",items);
//    [_roomVC listMemberWithData:items type:memberType_members];
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    NSLog(@"%@",items);
//    [_roomVC listMemberWithData:items type:memberType_moderators];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
    
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}



@end
