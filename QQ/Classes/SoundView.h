//
//  SoundView.h
//  QQ
//
//  Created by zhangke on 15/4/3.
//  Copyright (c) 2015年 zhangke. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMPPMessageArchiving_Message_CoreDataObject;
@class XMPPUserCoreDataStorageObject;



@interface SoundView : UITableViewCell




// Class method for computing a view height based on a given message transcript
+ (CGFloat)viewHeightForTranscript:(XMPPMessageArchiving_Message_CoreDataObject *)transcript;

- (void)setData:(XMPPMessageArchiving_Message_CoreDataObject *)message photo:(UIImage*)photo;


@end
