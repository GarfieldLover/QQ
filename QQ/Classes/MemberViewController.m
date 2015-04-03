//
//  MemberViewController.m
//  iPhoneXMPP
//
//  Created by zhangke on 15/3/17.
//  Copyright (c) 2015年 XMPPFramework. All rights reserved.
//

#import "MemberViewController.h"
#import "iPhoneXMPPAppDelegate.h"

@interface MemberViewController ()

@end

@implementation MemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self fetchedResultsController];
}

- (iPhoneXMPPAppDelegate *)appDelegate
{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_room];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomOccupantCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"role" ascending:YES];
        //        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"users" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1];
        //        NSArray *sortDescriptors=[NSArray array];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
//            DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return fetchedResultsController;
}

//人员重复，需要leave，
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    [self.tableivew reloadData];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSArray* userArray= [[self fetchedResultsController] fetchedObjects];

    return userArray.count;
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
    NSArray* userArray= [[self fetchedResultsController] fetchedObjects];

    XMPPRoomOccupantCoreDataStorageObject *user = [userArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=user.nickname;
    
    return cell;
}








@end
