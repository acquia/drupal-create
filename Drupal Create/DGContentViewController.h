//
//  DGContentViewController.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGArticleListViewController.h"
@interface DGContentViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
    NSString *urlToLoad;
  NSString *customTitle;
  BOOL loading;
  NSIndexPath *selectedIndexPath;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic)  NSString *urlToLoad;
@property (retain, nonatomic)  NSString *customTitle;
@property (retain, nonatomic)  DGArticleListViewController *articleListViewController;
@property (retain, nonatomic)  NSIndexPath *selectedIndexPath;
- (IBAction)deleteNode:(id)sender;
- (IBAction)shareNode:(id)sender;
- (void) loadWebView;
@end
