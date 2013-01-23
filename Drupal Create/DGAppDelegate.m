//
//  DGAppDelegate.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGAppDelegate.h"

#import "DGMasterViewController.h"
#import "Reachability.h"
#import "DGDClient.h"
#import "DGSiteListViewController.h"
@interface UIImage (scale)

-(UIImage*)scaleToSize:(CGSize)size;

@end

@implementation UIImage (scale)

-(UIImage*)scaleToSize:(CGSize)size
{
  // Create a bitmap graphics context
  // This will also set it as the current context
  UIGraphicsBeginImageContext(size);
  
  // Draw the scaled image in the current context
  [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
  
  // Create a new image from current context
  UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  
  // Pop the current context from the stack
  UIGraphicsEndImageContext();
  
  // Return our new scaled image
  return scaledImage;
}
@end;

@implementation DGAppDelegate
@synthesize customStatusBar = _customStatusBar;
@synthesize  currentSiteID;

- (void)dealloc
{
  [_window release];
  [_navigationController release];
    [super dealloc];
}

-(void) addSiteWithLabel:(NSString *)label andURL:(NSString *)url andAccessTokens:(NSMutableDictionary*)accessTokens andDelegate:(DGSiteListViewController*)delegate {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *sites = [defaults objectForKey:sitesKey];
  NSMutableArray *newSites = [[NSMutableArray alloc] initWithArray:sites];
  NSRange rangeOfURL = [url rangeOfString:@"http://"];
  if (rangeOfURL.location == NSNotFound) {
    url = [NSString stringWithFormat:@"%@%@", @"http://", url];
  }
  [DGDClient getSiteMeta:url meta:@"site" accessTokens:accessTokens success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString *faviconUrl = [[responseObject objectForKey:@"icon"] objectForKey:@"icon"];;
    NSString *label = [responseObject objectForKey:@"name"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:faviconUrl]];

    NSDictionary *site = [[NSDictionary alloc] initWithObjects:[[[NSArray alloc] initWithObjects:label, url, accessTokens, faviconUrl, imageData, nil] autorelease] forKeys:[[[NSArray alloc] initWithObjects:siteLabelKey, siteURLKey, siteAccessTokens, siteFaviconURLKey, siteFaviconData, nil] autorelease]];
    [newSites addObject:site];
    [defaults setObject:newSites forKey:sitesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [site release];
    [newSites release];
    [delegate.parentViewController dismissModalViewControllerAnimated:YES];
    [delegate.tableView reloadData];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSDictionary *site = [[NSDictionary alloc] initWithObjects:[[[NSArray alloc] initWithObjects:label, url, accessTokens, nil] autorelease] forKeys:[[[NSArray alloc] initWithObjects:siteLabelKey, siteURLKey, siteAccessTokens, nil] autorelease]];
    [newSites addObject:site];
    [defaults setObject:newSites forKey:sitesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [site release];
    [newSites release];
    [delegate.parentViewController dismissModalViewControllerAnimated:YES];
    [delegate.tableView reloadData];
  }];


}
-(UIColor*)colorWithHexString:(NSString*)hex
{
  NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
  
  // String should be 6 or 8 characters
  if ([cString length] < 6) return [UIColor grayColor];
  
  // strip 0X if it appears
  if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
  
  if ([cString length] != 6) return  [UIColor grayColor];
  
  // Separate into r, g, b substrings
  NSRange range;
  range.location = 0;
  range.length = 2;
  NSString *rString = [cString substringWithRange:range];
  
  range.location = 2;
  NSString *gString = [cString substringWithRange:range];
  
  range.location = 4;
  NSString *bString = [cString substringWithRange:range];
  
  // Scan values
  unsigned int r, g, b;
  [[NSScanner scannerWithString:rString] scanHexInt:&r];
  [[NSScanner scannerWithString:gString] scanHexInt:&g];
  [[NSScanner scannerWithString:bString] scanHexInt:&b];
  
  return [UIColor colorWithRed:((float) r / 255.0f)
                         green:((float) g / 255.0f)
                          blue:((float) b / 255.0f)
                         alpha:1.0f];
}
- (void) normalNavigationBar {
  if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"title_bar_bkg.png"] forBarMetrics:UIBarMetricsDefault];
  }
}

- (void) addSiteNavigationBar {
  if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"title_alt_bar_bkg.png"] forBarMetrics:UIBarMetricsDefault];
  }
}
- (BOOL) hasSites {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *sites = [defaults objectForKey:sitesKey];
  BOOL ret = NO;
  if ([sites count]) {
    return ret;
  }
  return ret;
}
- (int) siteCount {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *sites = [defaults objectForKey:sitesKey];
  return [sites count];
}
- (BOOL) hasInternet {
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  NetworkStatus networkStatus = [reachability currentReachabilityStatus];
  return !(networkStatus == NotReachable);
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque
                                            animated:NO];
  _customStatusBar = [[CustomStatusBar alloc] initWithFrame:CGRectZero];
  _customStatusBar.rootViewController = [[[UIViewController alloc] init] autorelease];
  [self normalNavigationBar];

  //[_customStatusBar showWithStatusMessage:@"Connecting"];
  DGMasterViewController *masterViewController = [[[DGMasterViewController alloc] initWithNibName:@"DGMasterViewController" bundle:nil] autorelease];
  //  self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
  self.window.rootViewController = masterViewController;
  // Register the preference defaults early.
  
  NSDictionary *appDefaults = [NSDictionary
                               dictionaryWithObjects:@[[[NSArray new] autorelease], [[NSMutableDictionary new] autorelease]] forKeys:@[sitesKey, cacheKey]];
  [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
  
  [self.window makeKeyAndVisible];
  return YES;
}
- (BOOL)isCacheOutOfDate:(NSString*)aCacheKey expiryKey:(NSString*)expiryKey expireTime:(int)expireTime {
  if (expireTime == 0) {
    expireTime = 300;
  }
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *cachedData = [defaults objectForKey:aCacheKey];
  NSString *timestamp = [cachedData objectForKey:expiryKey];
  NSDate *now = [NSDate date];
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
  NSTimeInterval difference = fabs([date timeIntervalSinceDate:now]);
  if(difference >= expireTime || timestamp == nil) {
    return YES;
  }
  return NO;
}
- (NSMutableDictionary*)getCachedData:(NSString*)aCacheKey {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *cachedData = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:aCacheKey]];
  if (cachedData) {
    return cachedData;
  }
  return [[NSMutableDictionary new] autorelease];
}
- (void)saveCache:(NSMutableDictionary *)cache ForKey:(NSString*)aCacheKey {
  [self saveCache:cache ForKey:aCacheKey expireKey:nil];
}
- (void)saveCache:(NSMutableDictionary *)cache ForKey:(NSString*)aCacheKey expireKey:(NSString *)expireKey {
  if (expireKey == nil) {
    expireKey = expireTimestampKey;
  }
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  NSDate *expireDate = [NSDate new];
  NSTimeInterval time = [expireDate timeIntervalSince1970];
  NSString *timeStamp = [NSString stringWithFormat:@"%f", time];
  [cache setObject:timeStamp forKey:expireKey];
  [defaults setObject:cache forKey:aCacheKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void) logoutOfSites {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *sites = [defaults objectForKey:sitesKey];
  NSEnumerator *e = [sites objectEnumerator];
  id object;
  while (object = [e nextObject]) {
    // do something with object
    [self logoutOfSiteWithURL:[object objectForKey:siteURLKey] shouldForceLogout:NO];
  }
}
- (NSDictionary*)siteForUrl:(NSString*)siteUrl {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *sites = [defaults objectForKey:sitesKey];
  NSEnumerator *e = [sites objectEnumerator];
  id object;
  while (object = [e nextObject]) {
    if ([[object objectForKey:siteURLKey] isEqualToString:siteUrl]) {
      return object;
    }
  }
  return nil;
}
- (BOOL) isLoggedOutofSiteURL:(NSString*)siteUrl {
  id object = [self siteForUrl:siteUrl];
  if([object objectForKey:siteAccessTokens] == nil) {
    return YES;
  }
  return NO;
}
- (void) updateSiteAccessTokens:(NSString*)siteUrl accessToken:(NSMutableDictionary*)accessTokens {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *sites = [defaults objectForKey:sitesKey];
  NSEnumerator *e = [sites objectEnumerator];
  NSMutableArray *newSites = [[NSMutableArray alloc] initWithArray:sites];
  id object;
  while (object = [e nextObject]) {
    int index = [newSites indexOfObject:object];
    if ([[object objectForKey:siteURLKey] isEqualToString:siteUrl]) {
      NSMutableDictionary *tempSiteDict = [[NSMutableDictionary alloc] initWithDictionary:object];
      [tempSiteDict setObject:accessTokens forKey:siteAccessTokens];
      [newSites removeObjectAtIndex:index];
      [newSites insertObject:tempSiteDict atIndex:index];
    }
  }
  [defaults setObject:newSites forKey:sitesKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) logoutOfSiteWithURL:(NSString*)siteUrl shouldForceLogout:(BOOL)force {
  NSString *contentCachekey = [siteUrl MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  if (([[cache objectForKey:keepLogin] isEqualToString:@"0"]) || force) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *sites = [defaults objectForKey:sitesKey];
    NSEnumerator *e = [sites objectEnumerator];
    NSMutableArray *newSites = [[NSMutableArray alloc] initWithArray:sites];
    id object;
    while (object = [e nextObject]) {
      int index = [newSites indexOfObject:object];
      if ([[object objectForKey:siteURLKey] isEqualToString:siteUrl]) {
        NSMutableDictionary *tempSiteDict = [[NSMutableDictionary alloc] initWithDictionary:object];
        [DGDClient logoutUserWithUrl:siteUrl accessTokens:[tempSiteDict objectForKey:siteAccessTokens] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
        [tempSiteDict removeObjectForKey:siteAccessTokens];
        [newSites removeObjectAtIndex:index];
        [newSites insertObject:tempSiteDict atIndex:index];
      }
    }
    [defaults setObject:newSites forKey:sitesKey];
    NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
    [cache removeObjectForKey:@"data"];
    [cache removeObjectForKey:loggedinUsername];
    [cache removeObjectForKey:authorDataKey];
    [AppDelegate saveCache:cache ForKey:contentCachekey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  NSString *query = [url query];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"appDidOpenSiteUrl" object:query];
  return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

//  NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//  for (NSHTTPCookie *each in [[[cookieStorage cookiesForURL:[NSURL URLWithString:currentSiteID]] copy] autorelease]) {
//    NSLog(@"%@", each);
//  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"appDidBecomeEnterForeground" object:nil];
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [self logoutOfSites];
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
