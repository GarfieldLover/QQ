//
//  MemberViewController.h
//  iPhoneXMPP
//
//  Created by zhangke on 15/3/17.
//  Copyright (c) 2015年 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MemberViewController : UIViewController<NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *fetchedResultsController;

}

@property (nonatomic,weak) IBOutlet UITableView* tableivew;

@end
