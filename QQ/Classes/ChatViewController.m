//
//  ChatViewController.m
//  iPhoneXMPP
//
//  Created by zhangke on 15/3/6.
//  Copyright (c) 2015年 XMPPFramework. All rights reserved.
//

#import "ChatViewController.h"
#import "iPhoneXMPPAppDelegate.h"
#import "MessageView.h"
#import "XMPPvCardTemp.h"

@interface ChatViewController ()<NSFetchedResultsControllerDelegate,UIScrollViewDelegate>{
    NSFetchedResultsController *fetchedResultsController;

}

@property (nonatomic,strong) UIImage* recviceUserPhoto;
@property (nonatomic,strong) UIImage* selfUserPhoto;


@end



@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=self.xmppUserObject.displayName;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    self.recviceUserPhoto=[UIImage imageWithData:[[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:self.xmppUserObject.jid]] ;
    self.selfUserPhoto= [UIImage imageWithData:[[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:[[[self appDelegate] xmppStream] myJID]]];

    
    //历史数据
    NSArray *sections = [[self fetchedResultsController] sections];
    
//    [self.tableView reloadData];
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
    if(sectionInfo.numberOfObjects>0){
        NSIndexPath* indexPath=[NSIndexPath indexPathForRow:sectionInfo.numberOfObjects-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
}

- (iPhoneXMPPAppDelegate *)appDelegate
{
    iPhoneXMPPAppDelegate *delegate =  (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    return  [MessageView viewHeightForTranscript:object];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (section < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        return sectionInfo.numberOfObjects;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageView";
    
    MessageView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell=[[MessageView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    XMPPMessageArchiving_Message_CoreDataObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    XMPPJID* jid=nil;
    if([object.message.fromStr containsString:@"张科"]){
        jid=[XMPPJID jidWithString:@"zhangke@192.168.9.100"];
    }else if ([object.message.fromStr containsString:@"何举"]){
        jid=[XMPPJID jidWithString:@"heju@192.168.9.100"];
    }else if ([object.message.fromStr containsString:@"张丹丹"]){
        jid=[XMPPJID jidWithString:@"zhangdan@192.168.9.100"];
    }else if(object.message.fromStr==nil){
        jid=[XMPPJID jidWithString:@"heju@192.168.9.100"];
        
    }
    
    XMPPvCardTemp* vCardTemp=[[[self appDelegate] xmppvCardTempModule] vCardTempForJID:jid shouldFetch:YES];
    
    [cell setData:object photo: [UIImage imageWithData:vCardTemp.photo]];
    
    
#if 0
    if (object.body) {
        //        if ([object.body hasPrefix:@"base64"]) {
        //            [showString appendFormat:@"语音文件"];
        //            NSData *audioData = [[object.body substringFromIndex:6] base64DecodedData];
        //        }else{
            [showString appendFormat:@"%@\n",object.body];
//        }
    }

    cell.textLabel.numberOfLines = 10;
    cell.textLabel.text = showString;
#endif
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messageTextField resignFirstResponder];

}



- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[[self appDelegate] xmppMessageArchivingCoreDataStorage] mainThreadManagedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];

        NSArray *sortDescriptors = @[sd1];
        
        NSPredicate* pre=[NSPredicate predicateWithFormat:@"bareJidStr = %@ && streamBareJidStr=%@", self.xmppUserObject.jidStr,[[[[self appDelegate] xmppStream] myJID] bare]];
//        NSPredicate* pre=[NSPredicate predicateWithFormat:@"bareJidStr = %@", self.xmppUserObject.jidStr];

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        [fetchRequest setPredicate:pre];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {

        }
        
    }
    
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] reloadData];
    
    NSArray *sections = [[self fetchedResultsController] sections];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
    if(sectionInfo.numberOfObjects>0){
        NSIndexPath* indexPath=[NSIndexPath indexPathForRow:sectionInfo.numberOfObjects-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}




#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - keyboard reference
-(void)WillChangeFrame:(NSNotification *)notif{
    CGRect chatRect = CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.frame = CGRectMake(0, chatRect.origin.y, chatRect.size.width, chatRect.size.height - keyboardSize.height- self.toolbar.bounds.size.height );
        self.toolbar.center = CGPointMake(self.toolbar.center.x,self.view.bounds.size.height -  keyboardSize.height - self.toolbar.bounds.size.height / 2);
        
        NSArray *sections = [[self fetchedResultsController] sections];
        
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
        if(sectionInfo.numberOfObjects>0){
            NSIndexPath* indexPath=[NSIndexPath indexPathForRow:sectionInfo.numberOfObjects-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    } completion:^(BOOL finish){

    }];
}

- (void)keyboardWillHidden:(NSNotification *)notif{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.toolbar.bounds.size.height);
        self.toolbar.center = CGPointMake(self.toolbar.center.x, self.view.bounds.size.height - self.toolbar.bounds.size.height / 2);
    } completion:^(BOOL finish){
//        NSArray *sections = [[self fetchedResultsController] sections];
//        
//        id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
//        if(sectionInfo.numberOfObjects>0){
//            NSIndexPath* indexPath=[NSIndexPath indexPathForRow:sectionInfo.numberOfObjects-1 inSection:0];
//            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//        }
    }];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.messageTextField resignFirstResponder];
}


- (IBAction)sendDone:(id)sender {
    [self sendMessage];
    [self.messageTextField setText:nil];
}

- (void)sendMessage{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.xmppUserObject.jid];
    [message addBody:self.messageTextField.text];
    [[[self appDelegate] xmppStream] sendElement:message];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
