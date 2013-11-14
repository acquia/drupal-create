//
//  DGAddSiteViewController.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/2/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGAddSiteViewController.h"
#import "DGAppDelegate.h"
#import "DGDClient.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "DGoAuthWebViewController.h"
#import "DGTitleBarView.h"
@interface DGAddSiteViewController ()

@end

@implementation DGAddSiteViewController
@synthesize siteLabel;
@synthesize siteUrl;
@synthesize siteListViewController;
@synthesize requestTokens;
@synthesize accessTokens;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)siteLabelChanged:(id)sender {
  if (![[siteLabel text] isEqualToString:@""] && ![[siteUrl text] isEqualToString:@""]) {
    [signinButton setEnabled:YES];
  }
}
- (IBAction)siteUrlChanged:(id)sender {
  if (![[siteLabel text] isEqualToString:@""] && ![[siteUrl text] isEqualToString:@""]) {
    [signinButton setEnabled:YES];
  }
}

- (void)cancel:(id)sender {
  [AppDelegate normalNavigationBar];
  [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//  //DGTitleBarView *titleBar = [[DGTitleBarView alloc] initWithImage:[UIImage imageNamed:@"dg_logo_white.png"]];
//  //[titleBar setFrame:CGRectMake(50, -20, titleBar.frame.size.width, titleBar.frame.size.height)];
//  [self.navigationItem setTitleView:titleBar];
//  [titleBar release];
  if([AppDelegate hasSites]) {
    [siteUrl setPlaceholder:@"Enter a new site URL"];
  } else {
    [siteUrl setPlaceholder:@"Enter a site URL to begin"];
  }
  requestTokens = [NSMutableDictionary new];
  accessTokens = [NSMutableDictionary new];
    // Do any additional setup after loading the view from its nib.
  UIButton *uiCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [uiCancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
  uiCancelButton.frame = CGRectMake(uiCancelButton.frame.origin.x, uiCancelButton.frame.origin.y, 35, 30.0);
  [uiCancelButton setBackgroundImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
  [uiCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [uiCancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  cancelButton = [[UIBarButtonItem alloc] initWithCustomView:uiCancelButton];
  [self.navigationItem setLeftBarButtonItem:cancelButton];
}

-(void) doneAdding:(id)sender {
  [AppDelegate addSiteWithLabel:[self getURL] andURL:[self getURL] andAccessTokens:accessTokens andDelegate:siteListViewController];
  [AppDelegate normalNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [siteLabel release];
  [siteUrl release];
  [signinButton release];
  [pleaseWaitText release];
  [errorTextOne release];
  [errorTextTwo release];
  [notFoundError release];
  [super dealloc];
}
- (void)viewDidUnload {
  [self setSiteLabel:nil];
  [self setSiteUrl:nil];
  [signinButton release];
  signinButton = nil;
  [pleaseWaitText release];
  pleaseWaitText = nil;
  [errorTextOne release];
  errorTextOne = nil;
  [errorTextTwo release];
  errorTextTwo = nil;
  [notFoundError release];
  notFoundError = nil;
  [super viewDidUnload];
}
- (void) showNotFoundError {
  [self hideError];
  [errorTextOne setHidden:NO];
  [notFoundError setHidden:NO];
}
- (void) showError {
  [errorTextOne setHidden:NO];
  [errorTextTwo setHidden:NO];
  [notFoundError setHidden:YES];
}
- (void) hideError {
  [errorTextOne setHidden:YES];
  [errorTextTwo setHidden:YES];
  [notFoundError setHidden:YES];
}

- (NSString*) getURL {
  NSString *url = [siteUrl text];
  NSURL *myUrl = [[NSURL alloc] initWithString: url];
  if (!myUrl.scheme) {
    url = [NSString stringWithFormat:@"%@%@", @"http://", url];
  }
  else {
      url = [myUrl absoluteString];
  }
  return url;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  [self signIn:signinButton];
  return YES;
}
- (IBAction)signIn:(id)sender {
  [siteUrl resignFirstResponder];
  if(![AppDelegate hasInternet]) {
    [[AppDelegate customStatusBar] showWithStatusMessage:@"Please check your internet connection."];
    [[AppDelegate customStatusBar] hide:2.0f];
    return;
  }
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *sites = [defaults objectForKey:sitesKey];
  for (NSDictionary *site in sites) {
    if ([[site objectForKey:siteURLKey] isEqualToString:[self getURL]]) {
      [[AppDelegate customStatusBar] showWithStatusMessage:@"That site's URL has already been added."];
      [[AppDelegate customStatusBar] hide:2.0f];
      return;
    }
  }
  [self hideError];
  [pleaseWaitText setHidden:NO];
  [DGDClient getSiteAvailability:[self getURL] success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //oauth
    [pleaseWaitText setHidden:YES];
    [self getRequestTokens];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [pleaseWaitText setHidden:YES];
    if ([[operation response] statusCode] == 404) {
      [self showNotFoundError];
    } else {
      [self showError];
    }
  }];

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  UITouch *touch = [[event allTouches] anyObject];
  if ([siteUrl isFirstResponder] && [touch view] != siteUrl) {
    [siteUrl resignFirstResponder];
  }
  [super touchesBegan:touches withEvent:event];
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
    DGoAuthWebViewController *webview = [[DGoAuthWebViewController alloc] initWithNibName:@"DGoAuthWebViewController" bundle:nil];
    [webview setUrlToLoad:[NSString stringWithFormat:@"%@/oauth/authorize?%@", [self getURL], operation.responseString]];
    [self.navigationController pushViewController:webview animated:YES];
    [webview setAddSiteViewController:self];
    [webview loadWebView];
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
    [self doneAdding:self];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [self showError];
    [self.navigationController popViewControllerAnimated:YES];
  }];
}
@end