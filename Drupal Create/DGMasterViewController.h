//
//  DGMasterViewController.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DGDetailViewController;
@class DGSiteListViewController;
@class DGCustomNavBar;

@interface DGMasterViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *backgroundView;

@property (retain, nonatomic) IBOutlet UIImageView *dgLogo;

@property (strong, nonatomic) DGDetailViewController *detailViewController;
@property (strong, nonatomic)  DGSiteListViewController *siteListViewController;
@property (retain, nonatomic) IBOutlet UIButton *login;
- (UINavigationController*) customNavigationController;
@end
