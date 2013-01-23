//
//  DGContentViewController.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGContentViewController.h"
#import "DGAppDelegate.h"
@interface DGContentViewController ()

@end

@implementation DGContentViewController
@synthesize webView = _webView;
@synthesize urlToLoad = _urlToLoad;
@synthesize customTitle = _customTitle;
@synthesize articleListViewController, selectedIndexPath;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  [backButton setTitle:@"Posts" forState:UIControlStateNormal];
  backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, 62.0, 30.0);
  [backButton setBackgroundImage:[UIImage imageNamed:@"toolbar_back_btn.png"] forState:UIControlStateNormal];
  [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
  [backButton release];
    // Do any additional setup after loading the view from its nib.
  [[self webView] setScalesPageToFit:YES];
  [[self webView] setDelegate:self];
}
- (void) viewWillAppear:(BOOL)animated {
    [self setTitle:_customTitle];
}
- (void)back:(id)sender {
  [[AppDelegate customStatusBar] hide:0.0f];
  loading = NO;
  [self.navigationController popViewControllerAnimated:YES];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
  if(!loading)
  [[AppDelegate customStatusBar] showWithStatusMessage:@"Loading..." hide:NO showLoadingIndicator:YES];
  loading = YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [[AppDelegate customStatusBar] hide:0.0f];
}
- (void) showDeleteDialog {
  UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate: self cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle: @"Delete"
                                                 otherButtonTitles: nil];

  [styleAlert showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
      [articleListViewController deleteRowAtIndexPath:selectedIndexPath];
      [[AppDelegate customStatusBar] hide:0.0f];
      loading = NO;
      [self.navigationController popViewControllerAnimated:YES];
      break;
  }
}
- (IBAction)deleteNode:(id)sender {
  [self showDeleteDialog];
}

- (IBAction)shareNode:(id)sender {
  [articleListViewController showShareDialog];
}

- (void) loadWebView {
  NSURL *url = [NSURL URLWithString:_urlToLoad];
  //URL Requst Object
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  
  //Load the request in the UIWebView.
  [_webView loadRequest:requestObj];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_webView release];
  [_urlToLoad release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
  [self setUrlToLoad:nil];
    [super viewDidUnload];
}
@end
