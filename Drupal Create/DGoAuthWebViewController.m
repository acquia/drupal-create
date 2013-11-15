//
//  DGWebViewViewController.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGoAuthWebViewController.h"
#import "DGTitleBarView.h"
#import "DGAppDelegate.h"
@interface DGoAuthWebViewController ()

@end

@implementation DGoAuthWebViewController

@synthesize webView, urlToLoad, addSiteViewController;
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
  DGTitleBarView *titleBar = [[DGTitleBarView alloc] initWithImage:[UIImage imageNamed:@"dg_logo_white.png"]];
  [self.navigationItem setTitleView:titleBar];
  [titleBar release];
  [webView setDelegate:self];
  UIButton *uiCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [uiCancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
  uiCancelButton.frame = CGRectMake(uiCancelButton.frame.origin.x, uiCancelButton.frame.origin.y, 35, 30.0);
  [uiCancelButton setBackgroundImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
  [uiCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [uiCancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:uiCancelButton]];
  [self loadWebView];
    // Do any additional setup after loading the view from its nib.
  backCount = 0;
}
- (void)cancel:(id)sender {
  if ([webView canGoBack] && backCount >= 1) {
    [webView goBack];
    backCount--;
  } else {
    [[AppDelegate customStatusBar] hide];
    [self.navigationController popViewControllerAnimated:YES];
  }
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  NSRange findCreate = [[request.URL absoluteString] rangeOfString:@"whpub://authorized"];
  if (findCreate.location != NSNotFound) {
      [[AppDelegate customStatusBar] hide];
    [addSiteViewController convertRequestTokensToAccess];
    return YES;
  }
  NSRange findPassword = [[request.URL absoluteString] rangeOfString:@"mast/password"];
  NSRange findLogin = [[request.URL absoluteString] rangeOfString:@"mast/login"];
  if (findPassword.location != NSNotFound && findLogin.location != NSNotFound) {
    backCount++;
  }
  return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
  [[AppDelegate customStatusBar] showWithStatusMessage:@"Loading..." hide:NO showLoadingIndicator:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [[AppDelegate customStatusBar] hide];
}
- (void)loadWebView {
  //Create a URL object.
  NSURL *url = [NSURL URLWithString:urlToLoad];
  //URL Requst Object
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  
  //Load the request in the UIWebView.
  [webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [webView release];
  [super dealloc];
}
- (void)viewDidUnload {
  [self setWebView:nil];
  [super viewDidUnload];
}
@end
