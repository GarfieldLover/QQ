//
//  RoomViewController.h
//  iPhoneXMPP
//
//  Created by zhangke on 15/3/17.
//  Copyright (c) 2015年 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoom.h"


@interface RoomViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) XMPPRoom *xmppRoom;

@property (weak, nonatomic) IBOutlet UIView *voiceView;

@property (weak, nonatomic) IBOutlet UIView *aioView;


@end
