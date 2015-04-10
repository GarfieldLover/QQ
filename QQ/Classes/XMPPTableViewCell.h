//
//  XMPPTableViewCell.h
//  QQ
//
//  Created by zhangke on 15/4/8.
//  Copyright (c) 2015年 zhangke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPTableViewCellProtocol.h"

@protocol XMPPTableViewCellProtocol;


@interface XMPPTableViewCell : UITableViewCell<XMPPTableViewCellProtocol>

+ (CGFloat)viewHeightForTranscript:(XMPPMessageArchiving_Message_CoreDataObject *)transcript;


@end
