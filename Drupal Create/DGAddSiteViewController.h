//
//  DGAddSiteViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/2/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGSiteListViewController.h"
@interface DGAddSiteViewController : UIViewController {
  UIBarButtonItem *doneButton;
  UIBarButtonItem *cancelButton;
  DGSiteListViewController *siteListViewController;
  IBOutlet UIButton *signinButton;
  IBOutlet UILabel *errorTextOne;
  IBOutlet UILabel *errorTextTwo;
  IBOutlet UILabel *pleaseWaitText;
  IBOutlet UITextField *siteUrl;
  NSMutableDictionary *requestTokens;
  NSMutableDictionary *accessTokens;
  IBOutlet UILabel *notFoundError;
  BOOL hasSiteUrlAlready;
}
@property (retain, nonatomic) DGSiteListViewController *siteListViewController;
@property (retain, nonatomic) IBOutlet UITextField *siteLabel;
@property (retain, nonatomic) IBOutlet UITextField *siteUrl;
@property (retain, nonatomic) NSMutableDictionary *requestTokens;
@property (retain, nonatomic) NSMutableDictionary *accessTokens;
- (IBAction)signIn:(id)sender;
- (void) convertRequestTokensToAccess;
- (NSString*) getURL;
- (void) showNotFoundError;
@end
