//
//  DGSiteSettingsViewController.m
//  Drupal Create
//
//  Created by Kyle Browning on 7/24/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGSiteSettingsViewController.h"
#import "DGCustomMySitesButton.h"
#import "DGCustomSettingsCell.h"
#import "DGAppDelegate.h"
#import "DGImageSizeViewController.h"
#import "DGDClient.h"
#import "AFHTTPRequestOperation.h"
@interface DGSiteSettingsViewController ()

@end

@implementation DGSiteSettingsViewController
@synthesize siteTitle, siteInfo, SiteSettings, CreateMetaInfo, mainScrollVIew, CreateMetaOptions, settingsOptions, articleListViewController;
@synthesize authorData, authorPickerViewController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectZero];
  [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  [backButton setTitle:@"Back" forState:UIControlStateNormal];
  backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, 62.0, 30.0);
  [backButton setBackgroundImage:[UIImage imageNamed:@"toolbar_back_btn.png"] forState:UIControlStateNormal];
  [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, +15, 0, 10)];
  [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
  [backButton release];
  [self setTitle:@"Site Settings"];
  [self.view setFrame:CGRectMake(0, 0, 320, 480)];
  UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  [bgImageView release];
  UIImageView *optionsTableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_top_bkg.png"]];
  UIImageView *optionsTableFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bottom_bkg.png"]];
  UIImageView *CreateMetaHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_top_bkg.png"]];
  UIImageView *CreateMetaFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bottom_bkg.png"]];
  [SiteSettings setTableHeaderView:optionsTableHeader];
  [SiteSettings setTableFooterView:optionsTableFooter];
  [SiteSettings setBackgroundColor:[UIColor clearColor]];
  [SiteSettings setSeparatorStyle:UITableViewCellSelectionStyleNone];
  [CreateMetaInfo setTableHeaderView:CreateMetaHeader];
  [CreateMetaInfo setTableFooterView:CreateMetaFooter];
  [CreateMetaInfo setBackgroundColor:[UIColor clearColor]];
  [CreateMetaInfo setSeparatorStyle:UITableViewCellSelectionStyleNone];
  [mainScrollVIew setContentSize:CGSizeMake(320, 615)];
  [mainScrollView setBackgroundColor:[AppDelegate colorWithHexString:@"e6f0fa"]];
  //[SiteSettings setFrame:CGRectMake(0, 20, 320, 100)];
  //  [signoutButton setTitleEdgeInsets:UIEdgeInsetsMake(70.0, 0, 5.0, 5.0)];
  authorPickerViewController = [[DGAuthorPickerViewController alloc] initWithNibName:@"DGAuthorPickerViewController" bundle:nil];

  settingsOptions = [NSMutableArray new];
  NSData *imageData = [siteInfo objectForKey:siteFaviconData];
  if (imageData != nil) {
    [faviconImg setImage:[UIImage imageWithData:imageData]];
  }
  dropShadow.layer.shadowColor = [UIColor blackColor].CGColor;
  dropShadow.layer.shadowOffset = CGSizeMake(0, 1);
  dropShadow.layer.shadowOpacity = 1;
  dropShadow.layer.shadowRadius = 2.0f;
  dropShadow.layer.cornerRadius = 3.0f;
  dropShadow.clipsToBounds = NO;
  [siteName setText:[siteInfo objectForKey:siteLabelKey]];
  authorData = nil;
  NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  NSDictionary *fields = [[articleListViewController mainViewController] fields];
  for (NSString *field in fields) {
    for (NSString *aContentType in [fields objectForKey:field]) {
      for (NSString *aFieldName in [[[fields objectForKey:field] objectForKey:aContentType] objectForKey:@"fields"]) {
        if ([aFieldName isEqualToString:@"author"]) {
          authorData = [[[[fields objectForKey:field] objectForKey:aContentType] objectForKey:@"fields"] objectForKey:aFieldName];
          contentType = aContentType;
          fieldName = aFieldName;
          break;
        }
      }
    }
  }
  if ([cache objectForKey:@"authorData"]) {
    
  }
  NSMutableDictionary *savedOptionsData = [NSMutableDictionary dictionaryWithDictionary:[cache objectForKey:authorOptions]];
  if(savedOptionsData == nil  || [AppDelegate isCacheOutOfDate:authorOptions expiryKey:expireAuthorTimestampKey expireTime:300]) {
    if (contentType != nil && fieldName != nil) {
      NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:contentType, fieldName, @"100", nil]
                                                          forKeys:[NSArray arrayWithObjects:@"bundle", @"field_name", @"count", nil]];
      [DGDClient getOptions:[siteInfo objectForKey:siteURLKey] accessTokens:[siteInfo objectForKey:siteAccessTokens] bundle:contentType params:params fieldName:fieldName success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [authorPickerViewController setOptions:[NSMutableDictionary dictionaryWithDictionary:[responseObject objectForKey:@"values"]]];
        [authorPickerViewController setOldOptions:[NSMutableDictionary dictionaryWithDictionary:[responseObject objectForKey:@"values"]]];
        [cache setObject:[responseObject objectForKey:@"values"] forKey:authorOptions];
        [AppDelegate saveCache:cache ForKey:contentCachekey expireKey:expireAuthorTimestampKey];
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == CONTENT_TYPE_ERROR_CODE) {
          [self dismissViewControllerAnimated:YES completion:nil];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"DrupalCreateContentTypesChanged" object:nil];
          NSString *text = [NSString stringWithFormat:@"%@ is disabled, reloading settings...", contentType];
          [[AppDelegate customStatusBar] showWithStatusMessage:text hide:NO];
          [[AppDelegate customStatusBar] hide:3.0f];
        }
      }];
    }
  } else {
    [authorPickerViewController setOptions:savedOptionsData];
    [authorPickerViewController setOldOptions:[NSMutableDictionary dictionaryWithDictionary:savedOptionsData]];
  }
  [authorPickerViewController setSiteSettingsViewController:self];
  NSMutableDictionary *author = [NSMutableDictionary new];
  if (authorData != nil) {
    NSMutableDictionary *savedAuthorData = [cache objectForKey:authorDataKey];
    if (savedAuthorData != nil) {
      [author setObject:[savedAuthorData objectForKey:@"value"] forKey:@"value"];
      [authorPickerViewController setDefaultAuthor:savedAuthorData];
    } else {
      [cache setObject:[authorData objectForKey:@"default"] forKey:authorDataKey];
      [AppDelegate saveCache:cache ForKey:contentCachekey];
      [author setObject:[[authorData objectForKey:@"default"] objectForKey:@"value"] forKey:@"value"];
      [authorPickerViewController setDefaultAuthor:[authorData objectForKey:@"default"]];
    }
  } else {
    NSString *authorName = [siteInfo objectForKey:loggedinUsername];
    if(authorName != nil) {
      [author setObject:authorName forKey:@"value"];
    }
  }
  [author setObject:@"autocomplete" forKey:@"type"];
  if (authorData == nil) {
    [author setObject:@"0" forKey:@"selectable"];
  } else {
    [author setObject:@"1" forKey:@"selectable"];
  }
  [author setObject:@"Author" forKey:@"label"];
  [settingsOptions addObject:author];
  [author release];
  
  NSMutableDictionary *username = [NSMutableDictionary new];
  NSString *name = [siteInfo objectForKey:loggedinUsername];
  if(name != nil) {
    [username setObject:[siteInfo objectForKey:loggedinUsername] forKey:@"value"];
  } else {
    [username setObject:@"" forKey:@"value"];
  }
  [username setObject:@"value" forKey:@"type"];
  [username setObject:@"0" forKey:@"selectable"];
  [username setObject:@"Username" forKey:@"label"];
  [settingsOptions addObject: username];
  [username release];

  NSString *content = [cache objectForKey:keepLogin];
  if(content == nil) {
    content = @"1";
  }
  NSMutableDictionary *loggedIn = [NSMutableDictionary new];
  [loggedIn setObject:content forKey:@"value"];
  [loggedIn setObject:@"switch" forKey:@"type"];
  [loggedIn setObject:@"0" forKey:@"selectable"];
  [loggedIn setObject:@"Keep me logged in" forKey:@"label"];
  [settingsOptions addObject: loggedIn];
  [loggedIn release];

  NSString *imageSizeCache = [cache objectForKey:imageSizeKey];
  if(imageSizeCache == nil) {
    imageSizeCache = @"Large";
  }
  NSMutableDictionary *imageSize = [NSMutableDictionary new];
  [imageSize setObject:imageSizeCache forKey:@"value"];
  [imageSize setObject:@"select" forKey:@"type"];
  [imageSize setObject:@"1" forKey:@"selectable"];
  [imageSize setObject:@"Image size" forKey:@"label"];
  [settingsOptions addObject: imageSize];
  [imageSize release];
  
  CreateMetaOptions = [NSMutableArray new];
//  NSMutableDictionary *rateit = [NSMutableDictionary new];
//  [rateit setObject:@"" forKey:@"value"];
//  [rateit setObject:@"value" forKey:@"type"];
//  [rateit setObject:@"1" forKey:@"selectable"];
//  [rateit setObject:@"Rate it!" forKey:@"label"];
//  [CreateMetaOptions addObject:rateit];
//  [rateit release];
//  
//  NSMutableDictionary *aboutus = [NSMutableDictionary new];
//  [aboutus setObject:@"" forKey:@"value"];
//  [aboutus setObject:@"value" forKey:@"type"];
//  [aboutus setObject:@"1" forKey:@"selectable"];
//  [aboutus setObject:@"About us" forKey:@"label"];
//  [CreateMetaOptions addObject:aboutus];
//  [aboutus release];
//
//  NSMutableDictionary *help = [NSMutableDictionary new];
//  [help setObject:@"" forKey:@"value"];
//  [help setObject:@"value" forKey:@"type"];
//  [help setObject:@"1" forKey:@"selectable"];
//  [help setObject:@"Help" forKey:@"label"];
//  [CreateMetaOptions addObject:help];
//  [help release];
//
//  NSMutableDictionary *privacy = [NSMutableDictionary new];
//  [privacy setObject:@"" forKey:@"value"];
//  [privacy setObject:@"value" forKey:@"type"];
//  [privacy setObject:@"1" forKey:@"selectable"];
//  [privacy setObject:@"Privacy policy" forKey:@"label"];
//  [CreateMetaOptions addObject:privacy];
//  [privacy release];
//
//  NSMutableDictionary *terms = [NSMutableDictionary new];
//  [terms setObject:@"" forKey:@"value"];
//  [terms setObject:@"value" forKey:@"type"];
//  [terms setObject:@"1" forKey:@"selectable"];
//  [terms setObject:@"Terms & conditions" forKey:@"label"];
//  [CreateMetaOptions addObject:terms];
//  [terms release];
  versionNumber.text = [NSString stringWithFormat:@"Version %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
  //  NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] objectForKey:sitesKey];
}
- (void)back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

-(NSMutableArray*)getImageSizeOptions {
  NSMutableArray *imageSizeOptions = [NSMutableArray new];
  NSMutableDictionary *small = [NSMutableDictionary new];
  [small setObject:@"0" forKey:@"value"];
  [small setObject:@"1" forKey:@"selectable"];
  [small setObject:@"Small" forKey:@"label"];
  [imageSizeOptions addObject:small];
  [small release];

  NSMutableDictionary *medium = [NSMutableDictionary new];
  [medium setObject:@"1" forKey:@"value"];
  [medium setObject:@"1" forKey:@"selectable"];
  [medium setObject:@"Medium" forKey:@"label"];
  [imageSizeOptions addObject:medium];
  [medium release];

  NSMutableDictionary *large = [NSMutableDictionary new];
  [large setObject:@"2" forKey:@"value"];
  [large setObject:@"1" forKey:@"selectable"];
  [large setObject:@"Large" forKey:@"label"];
  [imageSizeOptions addObject:large];
  [large release];
  return imageSizeOptions;
}
- (void)updateImageSize {
  NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  NSMutableArray *imageSizeOptions = [self getImageSizeOptions];
  NSString *imageSizeCache = [cache objectForKey:imageSizeKey];
  NSMutableDictionary *cell = [settingsOptions objectAtIndex:3];
  for (NSDictionary *dict in imageSizeOptions) {
    if ([[dict objectForKey:@"value"] isEqualToString:imageSizeCache]) {
      [cell setObject:[dict objectForKey:@"label"] forKey:@"value"];
    }
  }
  [SiteSettings reloadData];
}
- (void)updateDefaultAuthor:(NSMutableDictionary*)data {
  NSMutableDictionary *cell = [settingsOptions objectAtIndex:0];
  [cell setObject:[data objectForKey:@"value"] forKey:@"value"];
  [SiteSettings reloadData];
  NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  [cache setObject:data forKey:authorDataKey];
  [AppDelegate saveCache:cache ForKey:contentCachekey];
  [authorPickerViewController setDefaultAuthor:[authorData objectForKey:@"default"]];
}
- (void)viewWillAppear:(BOOL)animated {
  [self updateImageSize];
}
- (void)viewDidUnload
{
  [self setSiteSettings:nil];
  [self setCreateMetaInfo:nil];
  [self setMainScrollVIew:nil];
  [self setSettingsOptions:nil];
  [self setCreateMetaOptions:nil];
  [faviconImg release];
  faviconImg = nil;
  [dropShadow release];
  dropShadow = nil;
  [siteName release];
  siteName = nil;
  [signoutButton release];
  signoutButton = nil;
  [versionNumber release];
  versionNumber = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 46;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger ret;
  if (tableView == SiteSettings) {
    ret = 4;
  } else {
    ret = 5;
  }
  return ret;
}

-(NSString *) cellIdentifierforIndexPath:(NSIndexPath*)indexPath {
  NSString *cellIdentifier = @"cell";
  return cellIdentifier;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIImage *rowBackground = nil;
  UIImageView *rowBackGroundImageView = nil;
  
  DGCustomSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierforIndexPath:indexPath]];
  if(!cell) {
    	cell = [[DGCustomSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIdentifierforIndexPath:indexPath]];
  }
  if (tableView == SiteSettings) {
    [cell.textLabel setText:@"test"];
    [cell.textLabel setHidden:YES];
    NSDictionary *cellData = [settingsOptions objectAtIndex:indexPath.row];
    int y = 0;
    if (indexPath.row == 0) {
      y = 3;
    } else {
      y = 2;
    }
    [cell.label setText:[cellData objectForKey:@"label"]];
    
    if ([[cellData objectForKey:@"type"] isEqualToString:@"switch"]) {
      UISwitch *loggedInSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 30, 30)];
      [loggedInSwitch addTarget:self action:@selector(switchSelected:) forControlEvents:UIControlEventTouchUpInside];
      if ([[cellData objectForKey:@"value"] isEqualToString:@"1"]) {
        [loggedInSwitch setOn:YES];
      } else {
        [loggedInSwitch setOn:NO];
      }
      [cell addSubview:loggedInSwitch];
    } else if ([[cellData objectForKey:@"type"] isEqualToString:@"value"]) {
      [cell.cellText setText:[cellData objectForKey:@"value"]];
    } else if ([[cellData objectForKey:@"type"] isEqualToString:@"autocomplete"]) {
      [cell.cellText setText:[cellData objectForKey:@"value"]];
    } else if ([[cellData objectForKey:@"type"] isEqualToString:@"select"]) {
      [cell.cellText setText:[cellData objectForKey:@"value"]];
    }
    rowBackground = [UIImage imageNamed:@"table_row_bkg.png"];
    if (indexPath.row == 3) {
      [cell.sep setHidden:YES];
    }
    if ([[cellData objectForKey:@"selectable"] isEqualToString:@"1"]) {
      [cell.rightArrow setHidden:NO];
    }
    if([[cellData objectForKey:@"label"] isEqualToString:@"Username"]) {
      [cell.cellText setTextColor:[AppDelegate colorWithHexString:@"666666"]];
    }
    if([[cellData objectForKey:@"label"] isEqualToString:@"Author"]) {
      if ([[cellData objectForKey:@"selectable"] isEqualToString:@"0"]) {
        [cell.cellText setTextColor:[AppDelegate colorWithHexString:@"666666"]];
      }
    }
  } else if(tableView == CreateMetaInfo) {
    [cell.textLabel setText:@"test"];
    [cell.textLabel setHidden:YES];
    NSDictionary *cellData = [CreateMetaOptions objectAtIndex:indexPath.row];
    [cell.label setText:[cellData objectForKey:@"label"]];
    rowBackground = [UIImage imageNamed:@"table_row_bkg.png"];
    if (indexPath.row == 4) {
      [cell.sep setHidden:YES];
    }
    if ([[cellData objectForKey:@"selectable"] isEqualToString:@"1"]) {
      [cell.rightArrow setHidden:NO];
    }

  }
  rowBackGroundImageView = [[UIImageView alloc] initWithImage:rowBackground];
  [cell setBackgroundView:rowBackGroundImageView];
  [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  

  
  return cell;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // rows in section 0 should not be selectable
  NSDictionary *cellData = nil;
  if(tableView == SiteSettings) {
    cellData = [settingsOptions objectAtIndex:indexPath.row];
  } else if (tableView == CreateMetaInfo) {
    cellData = [CreateMetaOptions objectAtIndex:indexPath.row];
  }
  if ([[cellData objectForKey:@"selectable"] isEqualToString:@"0"]) {
    return nil;
  }
  return indexPath;
}
- (void) switchSelected:(UISwitch*)sender {
  NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  NSString *content = [cache objectForKey:keepLogin];
  if (content == nil) {
    [cache setObject:@"1" forKey:keepLogin];
  } else {
    if ([sender isOn]) {
      [cache setObject:@"1" forKey:keepLogin];
    } else {
      [cache setObject:@"0" forKey:keepLogin];
    }
  }
  [AppDelegate saveCache:cache ForKey:contentCachekey];
}
- (void) buildSectionLabel:(UITableViewCell *)cell withText:(NSString *)text andFrame:(CGRect) frame{
  [cell.textLabel setText:@""];
  UILabel *label = [[UILabel alloc] initWithFrame:frame];
  [label setText:text];
  [label setBackgroundColor:[UIColor clearColor]];
  [label setFont:[UIFont boldSystemFontOfSize:17.0f]];
  [label setTextColor:[UIColor grayColor]];
  [cell addSubview:label];
  [label release];
}
- (void) buildNormalLabel:(UITableViewCell *)cell withText:(NSString *)text andFrame:(CGRect) frame{
  [cell.textLabel setText:@""];
  UILabel *label = [[UILabel alloc] initWithFrame:frame];
  [label setText:text];
  [label setBackgroundColor:[UIColor clearColor]];
  [label setFont:[UIFont boldSystemFontOfSize:16.0f]];
  [cell addSubview:label];
  [label release];
}
- (void) buildSignoutCellUI:(UITableViewCell*) cell {
  UIButton *signout = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 310, 50)];
  [signout addTarget:self action:@selector(signout:) forControlEvents:UIControlEventTouchUpInside];
  [signout setTitle:@"Signout" forState:UIControlStateNormal];
  [signout setBackgroundImage:[UIImage imageNamed:@"sign_in_btn.png"] forState:UIControlStateNormal];
  [signout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [signout.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
  [cell addSubview:signout];
  [signout release];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

  DGImageSizeViewController *imageSizeViewController;
  if(tableView == SiteSettings) {
    switch (indexPath.row) {
      case 0:
        [self.navigationController pushViewController:authorPickerViewController animated:YES];
        break;
      case 3:
        imageSizeViewController = [[DGImageSizeViewController alloc] initWithNibName:@"DGImageSizeViewController" bundle:nil];
        [imageSizeViewController setImageSizeOptions:[self getImageSizeOptions]];
        [imageSizeViewController setSiteInfo:siteInfo];
        [self.navigationController pushViewController:imageSizeViewController animated:YES];
        [imageSizeViewController release];
        break;
      default:
        break;
    }
  } else if (tableView == CreateMetaInfo) {
    switch (indexPath.row) {
      case 0:
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/drupal-Create/id561249662?ls=1&mt=8"]];
        break;
      case 1:
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://drupalCreate.com"]];
        break;
      case 2:
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mobileapp.drupalCreate.com"]];
        break;
      case 3:
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.drupalCreate.com/content/drupal-Create-privacy"]];
        break;
      case 4:
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.drupalCreate.com/tos"]];
        break;
      default:
        break;
    }
  }
}

- (void)dealloc {
  [SiteSettings release];
  [CreateMetaInfo release];
  [mainScrollVIew release];
  [CreateMetaOptions release];
  [settingsOptions release];
  [authorPickerViewController release];
  [faviconImg release];
  [dropShadow release];
  [siteName release];
  [signoutButton release];
  [versionNumber release];
  [super dealloc];
}
- (IBAction)signout:(id)sender {
  NSString *textToDisplay = [NSString stringWithFormat:@"Logging out of \"%@\"", [siteInfo objectForKey:siteLabelKey]];
  [[AppDelegate customStatusBar] showWithStatusMessage:textToDisplay hide:YES showLoadingIndicator:YES];
  [AppDelegate logoutOfSiteWithURL:[siteInfo objectForKey:siteURLKey] shouldForceLogout:YES];
  [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
