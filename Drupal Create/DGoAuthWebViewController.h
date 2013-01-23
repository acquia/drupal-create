//
//  DGWebViewViewController.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGAddSiteViewController.h"
@interface DGoAuthWebViewController : UIViewController <UIWebViewDelegate> {
  NSString *urlToLoad;
  DGAddSiteViewController *addSiteViewController;
  int backCount;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) NSString *urlToLoad;
@property (retain, nonatomic) DGAddSiteViewController *addSiteViewController;
- (void)loadWebView;
@end
