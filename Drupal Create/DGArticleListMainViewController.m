//
//  DGArticleListMainViewController.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGArticleListMainViewController.h"
#import "DGAddArticleViewController.h"
#import "DGCustomMySitesButton.h"
#import "DGSiteSettingsViewController.h"
#import "DGDClient.h"

#import "DGAppDelegate.h"
@interface DGArticleListMainViewController ()

@end

@implementation DGArticleListMainViewController
@synthesize tableViewController;
@synthesize siteInfo = _siteInfo;
@synthesize siteNid = _siteNid;
@synthesize fields = _fields;
@synthesize selectedContentType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [tableViewController setSiteInfo:_siteInfo];
  NSString *contentCachekey = [[_siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  NSMutableArray *content = [cache objectForKey:@"data"];
  if([AppDelegate isCacheOutOfDate:contentCachekey expiryKey:expireTimestampKey expireTime:300] || [tableViewController shouldUpdate]) {
    [tableViewController startLoading];
  }
  [tableViewController setContent:content];
  //[addContentView setFrame:CGRectMake(0, 410, 320, 49)];
  [addContentView setHidden:YES];
  [self getFieldInfo];
  [self hideAllContentButtons];
}

- (void) resizeViews:(id)sender {
  [tableViewController startLoading];
  CGRect tempFrame = [UIApplication sharedApplication].statusBarFrame;
  if (tempFrame.size.height == 40) {
    addContentButton.frame = CGRectMake(addContentButton.frame.origin.x, addContentButton.frame.origin.y - 20, 320, 44);
  } else {
    addContentButton.frame = CGRectMake(addContentButton.frame.origin.x, addContentButton.frame.origin.y + 20, 320, 44);
  }
  [self hideAllContentButtons];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  addContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
  addContentView = [[UIView alloc] init];
  CGRect tempFrame = [UIApplication sharedApplication].statusBarFrame;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(resizeViews:)
                                               name:@"UIApplicationDidChangeStatusBarFrameNotification"
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(contentTypeReload:)
                                               name:@"DrupalCreateContentTypesChanged"
                                             object:nil];
  appHeight = [ [ UIScreen mainScreen ] bounds ].size.height;
  
  if (tempFrame.size.height == 40) {
    addContentButton.frame = CGRectMake(0, appHeight-125, 320, 44);
    addContentView.frame = CGRectMake(0, appHeight-49, 320, 49);
  } else {
    addContentButton.frame = CGRectMake(0, appHeight-105, 320, 44);
    addContentView.frame = CGRectMake(0, appHeight-49, 320, 49);
  }
  
  [addContentView setBackgroundColor:[UIColor clearColor]];
  
  [addContentButton setImage:[UIImage imageNamed:@"create_content_btn.png"] forState:UIControlStateNormal];
  [addContentButton addTarget:self action:@selector(addContent:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:addContentButton];
  [self.view addSubview:tableViewController.view];
  [self.view bringSubviewToFront:addContentButton];
  [self.view addSubview:addContentView];
  [tableViewController setSiteInfo:_siteInfo];
  [tableViewController setMainViewController:self];
  DGCustomMySitesButton *backButton = [[DGCustomMySitesButton alloc] initWithText:@"My Sites"];
  [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  [backButton setTitle:@"My Sites" forState:UIControlStateNormal];
  backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, 68.0, 30.0);
  [backButton setBackgroundImage:[UIImage imageNamed:@"toolbar_back_btn_lg.png"] forState:UIControlStateNormal];
  [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease]];
  [backButton release];
  
  UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectZero];
  [settingsButton addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchUpInside];
  settingsButton.frame = CGRectMake(settingsButton.frame.origin.x +30, settingsButton.frame.origin.y, 62.0, 30.0);
  [settingsButton setImage:[UIImage imageNamed:@"toolbar_settings_btn.png"] forState:UIControlStateNormal];
  [settingsButton setContentEdgeInsets:UIEdgeInsetsMake(0, +10, 0, -10)];
  [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:settingsButton] autorelease]];
  [settingsButton release];
  
  addOneContentImage   = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_1_content.png"]];
  [addOneContentImage setFrame:CGRectMake(0, 0, 320, 49)];
  addTwoContentImage   = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_2_content.png"]];
  [addTwoContentImage setFrame:CGRectMake(0, 0, 320, 49)];
  addThreeContentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_3_content.png"]];
  [addThreeContentImage setFrame:CGRectMake(0, 0, 320, 49)];
  addFourContentImage  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_4_content.png"]];
  [addFourContentImage setFrame:CGRectMake(0, 0, 320, 49)];


  
  blogIconImage = [UIImage imageNamed:@"blog.png"];
  articleIconImage = [UIImage imageNamed:@"page.png"];
  photoIconImage = [UIImage imageNamed:@"photo.png"];
  
  contentTypes = [NSMutableArray new];
  machineNames = [NSMutableArray new];
  
  NSString *contentCachekey = [[_siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  [self setTitle:[cache objectForKey:siteLabelKey]];

  if([cache objectForKey:loggedinUsername] == nil) {
    [DGDClient getSiteMetaUserInfoWithUrl:[_siteInfo objectForKey:siteURLKey] accessTokens:[_siteInfo objectForKey:siteAccessTokens] success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSString *contentCachekey = [[_siteInfo objectForKey:siteURLKey] MD5];
      NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
      [cache setObject:[responseObject objectForKey:@"name"] forKey:loggedinUsername];
      [AppDelegate saveCache:cache ForKey:contentCachekey expireKey:expireLoggedinUsername];
      [[NSUserDefaults standardUserDefaults] synchronize];
      [_siteInfo setObject:[responseObject objectForKey:@"name"] forKey:loggedinUsername];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
    }];
  } else {
    [_siteInfo setObject:[cache objectForKey:loggedinUsername] forKey:loggedinUsername];
  }
  if([cache objectForKey:siteLabelKey] == nil) {
    [DGDClient getSiteMetaSiteInfoWithUrl:[_siteInfo objectForKey:siteURLKey] accessTokens:[_siteInfo objectForKey:siteAccessTokens] success:^(AFHTTPRequestOperation *operation, id responseObject) {
      [_siteInfo setObject:[responseObject objectForKey:@"name"] forKey:siteLabelKey];
      NSString *contentCachekey = [[_siteInfo objectForKey:siteURLKey] MD5];
      NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
      [cache setObject:[responseObject objectForKey:@"name"] forKey:siteLabelKey];
      [AppDelegate saveCache:cache ForKey:contentCachekey];
      [self setTitle:[_siteInfo objectForKey:siteLabelKey]];
      [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
  } else {
    [_siteInfo setObject:[cache objectForKey:siteLabelKey] forKey:siteLabelKey];
  }
  [self getFieldInfo];
}

- (void)contentTypeReload:(id)sender {
  [self getFieldInfo];
}
- (void) getFieldInfo {

  NSString *contentCachekey = [[_siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  if ([cache objectForKey:fieldCacheKey] == nil || [AppDelegate isCacheOutOfDate:contentCachekey expiryKey:expireTimestampKey expireTime:300]) {
    [DGDClient getSiteFields:[_siteInfo objectForKey:siteURLKey] accessTokens:[_siteInfo objectForKey:siteAccessTokens] success:^(AFHTTPRequestOperation *operation, id responseObject) {
      [self setFields:responseObject];
      [self setupFields];
      //NSString *contentCachekey = [[_siteInfo objectForKey:siteURLKey] MD5];
      //NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
      //[cache setObject:_fields forKey:fieldCacheKey];
      //[AppDelegate saveCache:cache ForKey:contentCachekey];
      [self selectAddContent];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
  } else {
    [self setFields:[cache objectForKey:fieldCacheKey]];
    [self setupFields];
    [self selectAddContent];
  }
}
- (void) selectAddContent {
  int indexToSelect = 99;
  for (NSString *machineName in machineNames) {
    if ([machineName isEqualToString:selectedContentType]) {
      indexToSelect = [machineNames indexOfObject:machineName];
    }
  }
  switch (indexToSelect) {
    case 0:
      [self addContentOne:nil];
      break;
    case 1:
      [self addContentTwo:nil];
      break;
    case 2:
      [self addContentThree:nil];
      break;
    case 3:
      [self addContentFour:nil];
      break;
    default:
      break;
  }
  [self setSelectedContentType:@""];
}
- (void) setupFields {
  count = 0;
  [contentTypes removeAllObjects];
  [machineNames removeAllObjects];
  for (NSString *bundle in _fields) {
    for (NSString *contentType in [_fields objectForKey:bundle]) {
      [contentTypes addObject:[[[_fields objectForKey:bundle] objectForKey:contentType] objectForKey:@"short_name"]];
      [machineNames addObject:contentType];
      count++;
    }
  }
}
- (void)settings:(id)sender {
  DGSiteSettingsViewController *vc = [[DGSiteSettingsViewController alloc] initWithNibName:@"DGSiteSettingsViewController" bundle:nil];
  [vc setSiteTitle:self.title];
  [vc setSiteInfo:_siteInfo];
  [vc setArticleListViewController:tableViewController];
  [self.navigationController pushViewController:vc animated:YES];
  [vc release];
}
- (void)back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)addContentOne:(id)sender {
  DGAddArticleViewController *addArticleVc = [[DGAddArticleViewController alloc] initWithNibName:@"DGAddArticleViewController" bundle:nil];
  [addArticleVc setArticleSiteNid:[_siteInfo objectForKey:@"nid"]];
  [addArticleVc setListViewController:tableViewController];
  [addArticleVc setSiteInfo:_siteInfo];
  [addArticleVc setContentType:[contentTypes objectAtIndex:0]];
  [addArticleVc setMachineName:[machineNames objectAtIndex:0]];
  [addArticleVc setSiteFields:_fields];
  UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:addArticleVc];
  [self presentModalViewController:navVC animated:YES];
  [addArticleVc release];
  [navVC release];
  
}
- (void)addContentTwo:(id)sender {
  DGAddArticleViewController *addArticleVc = [[DGAddArticleViewController alloc] initWithNibName:@"DGAddArticleViewController" bundle:nil];
  [addArticleVc setArticleSiteNid:[_siteInfo objectForKey:@"nid"]];
  [addArticleVc setListViewController:tableViewController];
  [addArticleVc setSiteInfo:_siteInfo];
  [addArticleVc setContentType:[contentTypes objectAtIndex:1]];
  [addArticleVc setMachineName:[machineNames objectAtIndex:1]];
  [addArticleVc setSiteFields:_fields];
  UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:addArticleVc];
  [self presentModalViewController:navVC animated:YES];
  [addArticleVc release];
  [navVC release];
}
- (void)addContentThree:(id)sender {
  DGAddArticleViewController *addArticleVc = [[DGAddArticleViewController alloc] initWithNibName:@"DGAddArticleViewController" bundle:nil];
  [addArticleVc setArticleSiteNid:[_siteInfo objectForKey:@"nid"]];
  [addArticleVc setListViewController:tableViewController];
  [addArticleVc setSiteInfo:_siteInfo];
  [addArticleVc setContentType:[contentTypes objectAtIndex:2]];
  [addArticleVc setMachineName:[machineNames objectAtIndex:2]];
  [addArticleVc setSiteFields:_fields];
  UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:addArticleVc];
  [self presentModalViewController:navVC animated:YES];
  [addArticleVc release];
  [navVC release];
}
- (void)addContentFour:(id)sender {
  DGAddArticleViewController *addArticleVc = [[DGAddArticleViewController alloc] initWithNibName:@"DGAddArticleViewController" bundle:nil];
  [addArticleVc setArticleSiteNid:[_siteInfo objectForKey:@"nid"]];
  [addArticleVc setListViewController:tableViewController];
  [addArticleVc setSiteInfo:_siteInfo];
  [addArticleVc setContentType:[contentTypes objectAtIndex:3]];
  [addArticleVc setMachineName:[machineNames objectAtIndex:3]];
  [addArticleVc setSiteFields:_fields];
  UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:addArticleVc];
  [self presentModalViewController:navVC animated:YES];
  [addArticleVc release];
  [navVC release];  
}
- (void)addContent:(id)sender {
  [tableViewController removeSelection];
  NSString *icon = @"";
  NSMutableArray *icons = [NSMutableArray new];
  for (NSString *bundle in _fields) {
    for (NSString *contentType in [_fields objectForKey:bundle]) {
      icon = [[[_fields objectForKey:bundle] objectForKey:contentType] objectForKey:@"icon"];
      icon = [NSString stringWithFormat:@"%@.png", icon];
      [icons addObject:icon];
    }
  }
  NSInteger y;
    CGRect tempFrame = [UIApplication sharedApplication].statusBarFrame;
  if (tempFrame.size.height == 20) {
    y = appHeight-110;
  } else {
    y = appHeight-130;
  }
  switch (count) {
    case 1:
      [addOneContentImage setHidden:NO];
      [addContentView addSubview:addOneContentImage];
      [addButtonOne release];
      addButtonOne = [[UIButton alloc] initWithFrame:CGRectMake(138, 9, 40, 30)];
      [addButtonOne setImage:[UIImage imageNamed:[icons objectAtIndex:0]] forState:UIControlStateNormal];
      [addButtonOne addTarget:self action:@selector(addContentOne:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonOne];
      
      [UIView animateWithDuration:0.2
                       animations:^{
                         [addContentView setHidden:NO];
                         [addContentView setFrame:CGRectMake(0, y, 320, 49)];
                       }
                       completion:^(BOOL finished){
                         
                       }];
      
      break;
    case 2:
      
      [addTwoContentImage setHidden:NO];
      [addContentView addSubview:addTwoContentImage];
      [addButtonOne release];
      addButtonOne = [[UIButton alloc] initWithFrame:CGRectMake(110, 9, 40, 30)];
      [addButtonOne setImage:[UIImage imageNamed:[icons objectAtIndex:0]] forState:UIControlStateNormal];
      [addButtonOne addTarget:self action:@selector(addContentOne:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonOne];
      [addButtonTwo release];
      addButtonTwo = [[UIButton alloc] initWithFrame:CGRectMake(173, 9, 40, 30)];
      [addButtonTwo setImage:[UIImage imageNamed:[icons objectAtIndex:1]] forState:UIControlStateNormal];
      [addButtonTwo addTarget:self action:@selector(addContentTwo:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonTwo];
      [UIView animateWithDuration:0.2
                       animations:^{
                         [addContentView setHidden:NO];
                         [addContentView setFrame:CGRectMake(0, y, 320, 49)];
                       }
                       completion:^(BOOL finished){
                         
                       }];
      break;
    case 3:
      
      [addThreeContentImage setHidden:NO];
      [addContentView addSubview:addThreeContentImage];
      
      [addButtonOne release];
      addButtonOne = [[UIButton alloc] initWithFrame:CGRectMake(75, 9, 40, 30)];
      [addButtonOne setImage:[UIImage imageNamed:[icons objectAtIndex:0]] forState:UIControlStateNormal];
      [addButtonOne addTarget:self action:@selector(addContentOne:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonOne];

      [addButtonTwo release];
      addButtonTwo = [[UIButton alloc] initWithFrame:CGRectMake(140, 9, 40, 30)];
      [addButtonTwo setImage:[UIImage imageNamed:[icons objectAtIndex:1]] forState:UIControlStateNormal];
      [addButtonTwo addTarget:self action:@selector(addContentTwo:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonTwo];

      [addButtonThree release];
      addButtonThree = [[UIButton alloc] initWithFrame:CGRectMake(205, 9, 40, 30)];
      [addButtonThree setImage:[UIImage imageNamed:[icons objectAtIndex:2]] forState:UIControlStateNormal];
      [addButtonThree addTarget:self action:@selector(addContentThree:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonThree];
      
      [UIView animateWithDuration:0.2
                       animations:^{
                         [addContentView setHidden:NO];
                         [addContentView setFrame:CGRectMake(0, y, 320, 49)];
                       }
                       completion:^(BOOL finished){
                         
                       }];
      break;
    case 4:

      [addFourContentImage setHidden:NO];
      [addContentView addSubview:addFourContentImage];

      [addButtonOne release];
      addButtonOne = [[UIButton alloc] initWithFrame:CGRectMake(42, 9, 40, 30)];
      [addButtonOne setImage:[UIImage imageNamed:[icons objectAtIndex:0]] forState:UIControlStateNormal];
      [addButtonOne addTarget:self action:@selector(addContentOne:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonOne];

      [addButtonTwo release];
      addButtonTwo = [[UIButton alloc] initWithFrame:CGRectMake(108, 9, 40, 30)];
      [addButtonTwo setImage:[UIImage imageNamed:[icons objectAtIndex:1]] forState:UIControlStateNormal];
      [addButtonTwo addTarget:self action:@selector(addContentTwo:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonTwo];

      [addButtonThree release];
      addButtonThree = [[UIButton alloc] initWithFrame:CGRectMake(173, 9, 40, 30)];
      [addButtonThree setImage:[UIImage imageNamed:[icons objectAtIndex:2]] forState:UIControlStateNormal];
      [addButtonThree addTarget:self action:@selector(addContentThree:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonThree];

      [addButtonFour release];
      addButtonFour = [[UIButton alloc] initWithFrame:CGRectMake(240, 9, 40, 30)];
      [addButtonFour setImage:[UIImage imageNamed:[icons objectAtIndex:3]] forState:UIControlStateNormal];
      [addButtonFour addTarget:self action:@selector(addContentFour:) forControlEvents:UIControlEventAllEvents];
      [addContentView addSubview:addButtonFour];
      
      [UIView animateWithDuration:0.2
                       animations:^{
                         [addContentView setHidden:NO];
                         [addContentView setFrame:CGRectMake(0, y, 320, 49)];
                       }
                       completion:^(BOOL finished){
                         
                       }];
      break;
    default:
      break;
  }
}
- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [tableViewController viewDidAppear:animated];

}
- (void) hideAllContentButtons {
  [UIView animateWithDuration:0.1
                   animations:^{
                     //[self.view addSubview:addContentView];
                     //[addContentView setHidden:NO];
                     CGRect tempFrame = [UIApplication sharedApplication].statusBarFrame;
                     if (tempFrame.size.height == 40) {
                       addContentView.frame = CGRectMake(0, appHeight-49, 320, 49);
                     } else {
                       addContentView.frame = CGRectMake(0, appHeight-49, 320, 49);
                     }
                   }
                   completion:^(BOOL finished){
                     [addOneContentImage setHidden:YES];
                     [addTwoContentImage setHidden:YES];
                     [addThreeContentImage setHidden:YES];
                     [addFourContentImage setHidden:YES];
                     [addButtonOne setHidden:YES];
                     [addButtonTwo setHidden:YES];
                     [addButtonThree setHidden:YES];
                     [addButtonFour setHidden:YES];
                     [addContentView setHidden:YES];
                   }];

}
- (void)viewDidUnload
{
    [self setTableViewController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [tableViewController release];
    [super dealloc];
}
@end
