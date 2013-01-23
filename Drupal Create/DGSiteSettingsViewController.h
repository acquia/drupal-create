//
//  DGSiteSettingsViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 7/24/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGArticleListViewController.h"
#import "DGAuthorPickerViewController.h"
@class DGAuthorPickerViewController;
@interface DGSiteSettingsViewController : UIViewController {
  NSString *siteTitle;
  NSDictionary *siteInfo;
  IBOutlet UIScrollView *mainScrollView;
  NSMutableArray *settingsOptions;
  NSMutableArray *CreateMetaOptions;
  DGArticleListViewController *articleListViewController;
  DGAuthorPickerViewController *authorPickerViewController;
  NSDictionary *authorData;
  NSString *contentType;
  NSString *fieldName;
  IBOutlet UIImageView *faviconImg;
  IBOutlet UILabel *siteName;
  IBOutlet UIView *dropShadow;
  IBOutlet UIButton *signoutButton;
  IBOutlet UILabel *versionNumber;
}
- (IBAction)signout:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollVIew;
@property (retain, nonatomic) IBOutlet UITableView *SiteSettings;
@property (retain, nonatomic) IBOutlet UITableView *CreateMetaInfo;
@property (retain, nonatomic) NSMutableArray *settingsOptions;
@property (retain, nonatomic) NSMutableArray *CreateMetaOptions;
@property (nonatomic, retain) NSString *siteTitle;
@property (nonatomic, retain) NSDictionary *siteInfo;
@property (nonatomic, retain) NSDictionary *authorData;
@property (nonatomic, retain) DGArticleListViewController *articleListViewController;
@property (nonatomic, retain) DGAuthorPickerViewController *authorPickerViewController;
- (void)updateDefaultAuthor:(NSMutableDictionary*)data;
@end