//
//  DGAuthorPickerViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 9/3/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGSiteSettingsViewController.h"
#import "DGAddArticleViewController.h"

@class DGSiteSettingsViewController;

@interface DGAuthorPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
  NSString *urlToAutoComplete;
  NSMutableDictionary *options;
  NSMutableDictionary *oldOptions;
  IBOutlet UITableView *tableView;
  NSIndexPath *selectedIndex;
  NSIndexPath *oldSelectedIndex;
  NSMutableDictionary *defaultAuthor;
  DGSiteSettingsViewController *siteSettingsViewController;
  DGAddArticleViewController *addArticleViewController;
  NSDictionary *fieldInfo;
  IBOutlet UITextField *searchField;
  BOOL backspace;
}
@property (nonatomic, retain) NSString *urlToAutoComplete;
@property (nonatomic, retain) NSDictionary *fieldInfo;
@property (nonatomic, retain) DGSiteSettingsViewController *siteSettingsViewController; 
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, retain) NSMutableDictionary *oldOptions;
@property (nonatomic, retain) NSIndexPath *selectedIndex;
@property (nonatomic, retain) NSIndexPath *oldSelectedIndex;
@property (nonatomic, retain) NSMutableDictionary *defaultAuthor;
@property (nonatomic, retain) DGAddArticleViewController *addArticleViewController;
@end
