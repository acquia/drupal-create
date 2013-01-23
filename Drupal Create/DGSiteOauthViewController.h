//
//  DGSiteOauthViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/30/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "DGSiteListViewController.h"
@interface DGSiteOauthViewController : UIViewController <UIWebViewDelegate> {
  DGSiteListViewController *siteViewController;
  NSMutableDictionary *requestTokens;
  NSMutableDictionary *accessTokens;
  NSString *urlToLoad;
  NSString *siteUrl;
  IBOutlet UIWebView *webView;
  NSIndexPath *selectedRow;
  int backCount;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) DGSiteListViewController *siteViewController;
@property (retain, nonatomic) NSString *urlToLoad;
@property (retain, nonatomic) NSString *siteUrl;
@property (retain, nonatomic) NSIndexPath *selectedRow;
@end
