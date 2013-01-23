//
//  DGSiteOauthViewController.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/30/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGSiteOauthViewController.h"
#import "DGDClient.h"
#import "DGAppDelegate.h"
#import "DGTitleBarView.h"
@interface DGSiteOauthViewController ()

@end

@implementation DGSiteOauthViewController
@synthesize siteViewController;
@synthesize urlToLoad;
@synthesize siteUrl;
@synthesize webView;
@synthesize selectedRow;
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
  requestTokens = [NSMutableDictionary new];
  accessTokens  = [NSMutableDictionary new];
  [webView setDelegate:self];
  UIButton *uiCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [uiCancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
  uiCancelButton.frame = CGRectMake(uiCancelButton.frame.origin.x, uiCancelButton.frame.origin.y, 35, 30.0);
  [uiCancelButton setBackgroundImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
  [uiCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [uiCancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:uiCancelButton]];
  [webView setDelegate:self];
  if(![AppDelegate hasInternet]) {
    [[AppDelegate customStatusBar] showWithStatusMessage:@"Please check your Internet connection."];
    return;
  }
  [DGDClient getSiteAvailability:[self getURL] success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //oauth
    [self getRequestTokens];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [[AppDelegate customStatusBar] showWithStatusMessage:@"Error connecting to site :(."];
  }];
  backCount = 0;
}
- (void)cancel:(id)sender {
  if ([webView canGoBack] && backCount >= 1) {
    [webView goBack];
    backCount--;
  } else {
    [[AppDelegate customStatusBar] hide];
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}
- (NSString*) getURL {
  NSRange rangeOfURL = [siteUrl rangeOfString:@"http://"];
  if (rangeOfURL.location == NSNotFound) {
    siteUrl = [NSString stringWithFormat:@"%@%@", @"http://", siteUrl];
  }
  return siteUrl;
}
- (void) getRequestTokens{
  [DIOSSession sharedOauthSessionWithURL:[self getURL] consumerKey:CONSUMER_KEY secret:CONSUMER_SECRET];
  [DIOSSession getRequestTokensWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

    NSArray *arr = [operation.responseString componentsSeparatedByCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    if([arr count] == 4) {
      [requestTokens setObject:[arr objectAtIndex:1] forKey:[arr objectAtIndex:0]];
      [requestTokens setObject:[arr objectAtIndex:3] forKey:[arr objectAtIndex:2]];
    } else {
    }
    [self setUrlToLoad:[NSString stringWithFormat:@"%@/oauth/authorize?%@", [self getURL], operation.responseString]];
    [self loadWebView];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
  }];
}

- (void) convertRequestTokensToAccess {
  [DIOSSession getAccessTokensWithRequestTokens:requestTokens success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSArray *arr = [operation.responseString componentsSeparatedByCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    if([arr count] == 4) {
      [accessTokens setObject:[arr objectAtIndex:1] forKey:[arr objectAtIndex:0]];
      [accessTokens setObject:[arr objectAtIndex:3] forKey:[arr objectAtIndex:2]];
    } else {
    }
    if ([[accessTokens allKeys] count] >=1) {
      [AppDelegate updateSiteAccessTokens:[self getURL] accessToken:accessTokens];

      [siteViewController dismissModalViewControllerAnimated:YES];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      [siteViewController dismissModalViewControllerAnimated:YES];
  }];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  NSRange findCreate = [[request.URL absoluteString] rangeOfString:@"whpub://authorized"];
  if (findCreate.location != NSNotFound) {
      [[AppDelegate customStatusBar] hide];
    [self convertRequestTokensToAccess];
    return YES;
  }
  NSRange findPassword = [[request.URL absoluteString] rangeOfString:@"mast/password"];
  if (findPassword.location != NSNotFound) {
    backCount++;
  }
  return YES;
}

- (void)loadWebView {
  //Create a URL object.
  NSURL *url = [NSURL URLWithString:urlToLoad];
  //URL Requst Object
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  //Load the request in the UIWebView.
  [webView loadRequest:requestObj];
  [[AppDelegate customStatusBar] showWithStatusMessage:@"Loading..." hide:NO showLoadingIndicator:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[AppDelegate customStatusBar] hide];
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
