//
//  RoomViewController.m
//  iPhoneXMPP
//
//  Created by zhangke on 15/3/17.
//  Copyright (c) 2015年 XMPPFramework. All rights reserved.
//

#import "RoomViewController.h"
#import "MemberViewController.h"
#import "iPhoneXMPPAppDelegate.h"
#import "MessageView.h"
#import "XMPPvCardTemp.h"
#import "LCVoice.h"
#import "SoundView.h"
#import "ImageView.h"
#import "XMPPTableViewCell.h"
#import "XMPPTableViewCellProtocol.h"

@interface RoomViewController ()<NSFetchedResultsControllerDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSFetchedResultsController *fetchedResultsController;
    
}

@property (nonatomic,strong) NSMutableArray* messageArray;

@property(nonatomic,retain) LCVoice * voice;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=self.xmppRoom.roomJID.user;
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"人员" style:UIBarButtonItemStylePlain target:self action:@selector(number)];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBackRoom)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.messageArray=[NSMutableArray array];
    //历史数据
    for(XMPPMessageArchiving_Message_CoreDataObject* object in [[self fetchedResultsController] fetchedObjects]){
        if(![object.message.fromStr isEqualToString:self.xmppRoom.myRoomJID.full] && ![self.messageArray containsObject:object]){
            NSPredicate* pre=[NSPredicate predicateWithFormat:@"body==%@",object.body];
            NSArray* array=[self.messageArray filteredArrayUsingPredicate:pre];
            if(array.count==0){
                [self.messageArray addObject:object];
            }
        }
    }
    if(self.messageArray.count>0){
        NSIndexPath* indexPath=[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

-(void)number
{
    MemberViewController* mem=[[MemberViewController alloc] init];
    [self.navigationController pushViewController:mem animated:YES];
}

-(void)goBackRoom
{
    if(self.xmppRoom){
        [self.xmppRoom leaveRoom];
        [self.xmppRoom deactivate];
        [self.xmppRoom destroyRoom];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    fetchedResultsController.delegate=nil;
    fetchedResultsController=nil;
    
}

- (iPhoneXMPPAppDelegate *)appDelegate
{
    iPhoneXMPPAppDelegate *delegate =  (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate;
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
        
//        NSPredicate* pre=[NSPredicate predicateWithFormat:@"bareJidStr=%@ AND NOT (messageStr CONTAINS[cd] %@)",self.xmppRoom.roomJID.full,self.xmppRoom.myRoomJID.full];
        NSPredicate* pre=[NSPredicate predicateWithFormat:@"bareJidStr==%@",self.xmppRoom.roomJID.full];
//        NSPredicate *pre = [NSPredicate predicateWithFormat:@"NOT (messageStr CONTAINS[cd] %@) AND NOT (messageStr CONTAINS[cd] %@)", self.xmppRoom.myRoomJID.full, @"from"];

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
    [self.messageArray removeAllObjects];

    for(XMPPMessageArchiving_Message_CoreDataObject* object in [[self fetchedResultsController] fetchedObjects]){
        if(![object.message.fromStr isEqualToString:self.xmppRoom.myRoomJID.full]){
            NSPredicate* pre=[NSPredicate predicateWithFormat:@"body==%@",object.body];
            NSArray* array=[self.messageArray filteredArrayUsingPredicate:pre];
            if(array.count==0){
                [self.messageArray addObject:object];
            }
        }
    }

    [[self tableView] reloadData];
    if(self.messageArray.count>0){
        NSIndexPath* indexPath=[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
//    NSArray *sections = [[self fetchedResultsController] sections];
//    
//    id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
//    if(sectionInfo.numberOfObjects>0){
//        NSIndexPath* indexPath=[NSIndexPath indexPathForRow:sectionInfo.numberOfObjects-1 inSection:0];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *object = [self.messageArray objectAtIndex:indexPath.row];
    
    NSDictionary* dic=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MessageType" ofType:@"plist"]];
    NSString* classString =[dic objectForKey:[object.body substringToIndex:5]];
    Class aClass=NSClassFromString(classString);
    return [aClass viewHeightForTranscript:object];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//[[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSArray *sections = [[self fetchedResultsController] sections];
//    
//    if (section < [sections count])
//    {
//        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
//        return sectionInfo.numberOfObjects;
//    }
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *object = self.messageArray[indexPath.row];
    
    NSDictionary* dic=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MessageType" ofType:@"plist"]];
    NSString* classString =[dic objectForKey:[object.body substringToIndex:5]];
    Class aClass=NSClassFromString(classString);
    
    
    XMPPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classString];
    if(cell==nil){
        cell=[[aClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classString];
    }
    
    [cell setData:object photo:[self getImage:object]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messageTextField resignFirstResponder];
    
}

-(UIImage*)getImage:(XMPPMessageArchiving_Message_CoreDataObject*)object
{
    XMPPJID* jid=nil;
    if([object.message.fromStr containsString:@"张科"]){
        jid=[XMPPJID jidWithString:@"zhangke@192.168.9.100"];
    }else if ([object.message.fromStr containsString:@"何举"]){
        jid=[XMPPJID jidWithString:@"heju@192.168.9.100"];
    }else if ([object.message.fromStr containsString:@"张丹丹"]){
        jid=[XMPPJID jidWithString:@"zhangdan@192.168.9.100"];
    }else if(object.message.fromStr==nil){
        NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyJID"];
        jid=[XMPPJID jidWithString:myJID];
    }
    
    XMPPvCardTemp* vCardTemp=[[[self appDelegate] xmppvCardTempModule] vCardTempForJID:jid shouldFetch:YES];
    return [UIImage imageWithData:vCardTemp.photo];
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
        if(self.messageArray.count>0){
            NSIndexPath* indexPath=[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }

        
//        NSArray *sections = [[self fetchedResultsController] sections];
//        
//        id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
//        if(sectionInfo.numberOfObjects>0){
//            NSIndexPath* indexPath=[NSIndexPath indexPathForRow:sectionInfo.numberOfObjects-1 inSection:0];
//            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//        }
    } completion:^(BOOL finish){
        
    }];
}

- (void)keyboardWillHidden:(NSNotification *)notif{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.toolbar.bounds.size.height);
        self.toolbar.center = CGPointMake(self.toolbar.center.x, self.view.bounds.size.height - self.toolbar.bounds.size.height / 2);
        if(self.messageArray.count>0){
            NSIndexPath* indexPath=[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    } completion:^(BOOL finish){

    }];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.messageTextField resignFirstResponder];
}





-(IBAction)voice:(id)sender
{
    if([(UIButton*)sender tag]==0){
        [self.messageTextField resignFirstResponder];
        self.messageTextField.hidden=YES;
        
        UIButton* keyButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [keyButton setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor.png"] forState:UIControlStateNormal];
        keyButton.frame=CGRectMake(2, 2, 40, 40);
        keyButton.tag=1;
        [keyButton addTarget:self action:@selector(voice:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* aioButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [aioButton setImage:[UIImage imageNamed:@"chat_bottom_up_nor.png"] forState:UIControlStateNormal];
        aioButton.frame=CGRectMake(2, 2, 40, 40);
        aioButton.tag=0;
        [aioButton addTarget:self action:@selector(aio:) forControlEvents:UIControlEventTouchUpInside];
        

        NSMutableArray* array=[NSMutableArray arrayWithArray:self.toolbar.items];
        array[5]=[[UIBarButtonItem alloc] initWithCustomView:aioButton];
        array[1]=[[UIBarButtonItem alloc] initWithCustomView:keyButton];
        self.toolbar.items=array;
        
        
        self.voice = [[LCVoice alloc] init];
        
        CGRect rect =self.toolbar.frame;
        rect.origin.y=self.view.frame.size.height- ( self.voiceView.frame.size.height+rect.size.height );

        CGRect rect2=self.voiceView.frame;
        rect2.origin.y=self.view.frame.size.height-rect2.size.height;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.toolbar.frame=rect;
            
            self.voiceView.frame=rect2;
            self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, rect.origin.y);
            if(self.messageArray.count>0){
                NSIndexPath* indexPath=[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } completion:^(BOOL finish){

        }];

    }else{
        [self.messageTextField becomeFirstResponder];
        self.messageTextField.hidden=NO;
        
        self.voice=nil;
        
        UIButton* voiceButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [voiceButton setImage:[UIImage imageNamed:@"chat_bottom_voice_nor.png"] forState:UIControlStateNormal];
        voiceButton.frame=CGRectMake(2, 2, 40, 40);
        voiceButton.tag=0;
        [voiceButton addTarget:self action:@selector(voice:) forControlEvents:UIControlEventTouchUpInside];

        
        NSMutableArray* array=[NSMutableArray arrayWithArray:self.toolbar.items];
        array[1]=[[UIBarButtonItem alloc] initWithCustomView:voiceButton];
        self.toolbar.items=array;
        

        
        CGRect rect2=self.voiceView.frame;
        rect2.origin.y=self.view.frame.size.height;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.voiceView.frame=rect2;
        } completion:^(BOOL finish){

        }];
    }

}


#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMessage];
    [self.messageTextField setText:nil];
    
    return YES;
}


- (void)sendMessage{
    //只能groupchat，语音后跟      语音文件
    XMPPMessage *message = [XMPPMessage messageWithType:@"groupchat" to:self.xmppRoom.roomJID];
    NSString* text= [@"chatT" stringByAppendingString:self.messageTextField.text];
    [message addBody:text];
    [[[self appDelegate] xmppStream] sendElement:message];
}


-(IBAction)recordStart:(id)sender
{
    NSDateFormatter* datefor=[[NSDateFormatter alloc] init];
    [datefor setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* recordPath=[NSString stringWithFormat:@"%@/Documents/%@%@.caf",  NSHomeDirectory(),[datefor stringFromDate:[NSDate date]],self.xmppRoom.roomJID.full];
    [self.voice startRecordWithPath:recordPath];
}

-(IBAction) recordEnd
{
    [self.voice stopRecordWithCompletionBlock:^{
        
        if (self.voice.recordTime > 1.0f) {
            
            NSURL *soundUrl = [NSURL fileURLWithPath:self.voice.recordPath];
            
            
            NSData *soundData = [[NSData alloc] initWithContentsOfURL:soundUrl];

            //将NSData转成base64的NSString类型
            NSString *sound=[soundData base64Encoding];
            sound=[@"sound" stringByAppendingString:sound];
            
            XMPPMessage *message = [XMPPMessage messageWithType:@"groupchat" to:self.xmppRoom.roomJID];
            [message addBody:sound];
            [[[self appDelegate] xmppStream] sendElement:message];

        }
    }];
}

-(IBAction) recordCancel
{
    [self.voice cancelled];
}


-(IBAction)aio:(id)sender
{
    if([(UIButton*)sender tag]==0){
        [self.messageTextField resignFirstResponder];
        self.messageTextField.hidden=YES;

        UIButton* keyButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [keyButton setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor.png"] forState:UIControlStateNormal];
        keyButton.frame=CGRectMake(2, 2, 40, 40);
        keyButton.tag=1;
        [keyButton addTarget:self action:@selector(aio:) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableArray* array=[NSMutableArray arrayWithArray:self.toolbar.items];
        array[5]=[[UIBarButtonItem alloc] initWithCustomView:keyButton];
        self.toolbar.items=array;
        

        CGRect rect =self.toolbar.frame;
        rect.origin.y=self.view.frame.size.height- ( self.aioView.frame.size.height+rect.size.height );
        
        CGRect rect2=self.aioView.frame;
        rect2.origin.y=self.view.frame.size.height-rect2.size.height;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.toolbar.frame=rect;
            
            self.aioView.frame=rect2;
            self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, rect.origin.y);
            
            if(self.messageArray.count>0){
                NSIndexPath* indexPath=[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } completion:^(BOOL finish){
            
        }];
        
    }else{
        [self.messageTextField becomeFirstResponder];
        self.messageTextField.hidden=NO;

        UIButton* aioButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [aioButton setImage:[UIImage imageNamed:@"chat_bottom_up_nor.png"] forState:UIControlStateNormal];
        aioButton.frame=CGRectMake(2, 2, 40, 40);
        aioButton.tag=0;
        [aioButton addTarget:self action:@selector(aio:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* voiceButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [voiceButton setImage:[UIImage imageNamed:@"chat_bottom_voice_nor.png"] forState:UIControlStateNormal];
        voiceButton.frame=CGRectMake(2, 2, 40, 40);
        voiceButton.tag=0;
        [voiceButton addTarget:self action:@selector(voice:) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSMutableArray* array=[NSMutableArray arrayWithArray:self.toolbar.items];
        array[1]=[[UIBarButtonItem alloc] initWithCustomView:voiceButton];
        array[5]=[[UIBarButtonItem alloc] initWithCustomView:aioButton];
        self.toolbar.items=array;
        
        
        CGRect rect2=self.aioView.frame;
        rect2.origin.y=self.view.frame.size.height;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.aioView.frame=rect2;
        } completion:^(BOOL finish){
            
        }];
    }
    
}



-(IBAction)pic:(id)sender
{
    UIImagePickerController* picker=[[UIImagePickerController alloc] init];
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate=self;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];

    NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
    

    //将NSData转成base64的NSString类型
    NSString *imageString=[imageData base64Encoding];
    imageString=[@"image" stringByAppendingString:imageString];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"groupchat" to:self.xmppRoom.roomJID];
    [message addBody:imageString];
    [[[self appDelegate] xmppStream] sendElement:message];
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

}










@end
