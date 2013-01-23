//
//  DGArticleListViewController.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "DGArticleListMainViewController.h"
@class DGArticleListMainViewController;
@interface DGArticleListViewController : PullRefreshTableViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
  UIActionSheet *shareActionSheet;
  UIActionSheet *deleteActionSheet;
  NSString *siteNid;
  NSDictionary *siteInfo;
  IBOutlet UITableView *tableView;
  NSMutableArray *content;
  BOOL shouldUpdate;
  NSIndexPath *selectedSwipeRow;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *content;
@property (nonatomic, retain) NSString *siteNid;
@property (nonatomic, retain) NSDictionary *siteInfo;
@property (nonatomic, retain) DGArticleListViewController *tableViewController;
@property (nonatomic, retain) DGArticleListMainViewController *mainViewController;
@property (nonatomic, assign) BOOL shouldUpdate;
@property (nonatomic, retain) NSIndexPath *selectedSwipeRow;
- (void) showDeleteDialog;
- (void) showShareDialog;
- (void) showArticle;
- (void) removeSelection;
- (void) deleteRowAtIndexPath:(NSIndexPath*)indexPath;
@end
