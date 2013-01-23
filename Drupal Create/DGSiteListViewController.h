//
//  DGSiteListViewController.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import "PullRefreshTableViewController.h"
@class DGSiteListCustomCell;
@interface DGSiteListViewController : UITableViewController {
  BOOL newCells;
  NSIndexPath *selectedIndex;
  BOOL shouldSelectRow;
  BOOL addSiteView;
  BOOL showNavigation;
  id currentVc;
  NSString *contentType;
}
@property (nonatomic, retain) NSIndexPath *selectedIndex;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain)   NSMutableArray *_sites;
@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *addButton;
@property (nonatomic, retain) UITableViewCell *savedSourceCell;
@property (nonatomic, assign) BOOL shouldSelectRow;
@property (nonatomic, assign) BOOL addSiteView;
@property (nonatomic, assign) BOOL showNavigation;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (DGSiteListCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
