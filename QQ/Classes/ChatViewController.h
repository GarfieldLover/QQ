//
//  ChatViewController.h
//  iPhoneXMPP
//
//  Created by zhangke on 15/3/6.
//  Copyright (c) 2015年 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPUserCoreDataStorageObject.h"

@interface ChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) XMPPUserCoreDataStorageObject *xmppUserObject;

@end
