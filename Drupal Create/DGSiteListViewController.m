//
//  DGSiteListViewController.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGSiteListViewController.h"
#import "DGDClient.h"
#import "DIOSSession.h"
#import "DGArticleListViewController.h"
#import "DIOSView.h"
#import "DGSiteListCustomCell.h"
#import "DGArticleListMainViewController.h"
#import "DGAppDelegate.h"
#import "DGAddSiteViewController.h"
#import "UIImageView+WebCache.h"
#import "DGSiteOauthViewController.h"
#import <UIKit/UITableView.h>
@interface DGSiteListViewController () {

}
@end

@implementation DGSiteListViewController
@synthesize tableView = _tableView;
@synthesize _sites;
@synthesize  editButton;
@synthesize savedSourceCell = _savedSourceCell;
@synthesize doneButton;
@synthesize selectedIndex;
@synthesize  shouldSelectRow;
@synthesize addSiteView;
@synthesize addButton;
@synthesize showNavigation;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
  [_tableView release];
  [super dealloc];
  [_sites release];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}
- (void) viewWillAppear:(BOOL)animated {
  [_sites release];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [self set_sites:[[NSMutableArray alloc] initWithArray:[defaults objectForKey:sitesKey]]];
  [self.tableView reloadData];
  if ([_sites count] == 0) {
    [[self.tableView tableFooterView] setHidden:YES];
    [[self.tableView tableHeaderView] setHidden:YES];
  } else {
    [[self.tableView tableFooterView] setHidden:NO];
    [[self.tableView tableHeaderView] setHidden:NO];
  }
  [self addNormalBar];
  if(shouldSelectRow) {
    if([_sites count] == 1) {
      NSUInteger newIndex[]   = {0, 0};
      selectedIndex = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];;
          [self tableView:self.tableView didSelectRowAtIndexPath:selectedIndex];
    } else {
      [self tableView:self.tableView didSelectRowAtIndexPath:selectedIndex];
    }
  }
}

- (void) addAltBar {
      float version = [[[UIDevice currentDevice] systemVersion] floatValue];
      UIImage *backgroundImage = [UIImage imageNamed:@"title_alt_bar_bkg.png"];
      if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
      } else {
        [self.navigationController.navigationBar insertSubview:[[[UIImageView alloc] initWithImage:backgroundImage] autorelease] atIndex:1];
      }
}
- (void) addNormalBar {
      float version = [[[UIDevice currentDevice] systemVersion] floatValue];
      UIImage *backgroundImage = [UIImage imageNamed:@"title_bar_bkg.png"];
      if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
      } else {
        [self.navigationController.navigationBar insertSubview:[[[UIImageView alloc] initWithImage:backgroundImage] autorelease] atIndex:1];
      }
}
- (void) viewDidAppear:(BOOL)animated {
  if (addSiteView) {
    [self addSite:self];
    addSiteView = NO;
    return;
  }
  [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
  [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  [self.navigationItem setLeftBarButtonItem:self.addButton];
}
-(void) updateStuff {

  if ([AppDelegate isLoggedOutofSiteURL:[AppDelegate currentSiteID]]) {
   [self.navigationController popToRootViewControllerAnimated:NO];
  }

}
- (void)viewDidLoad
{
  [super viewDidLoad];
  [AppDelegate logoutOfSites];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateStuff)
                                               name:@"appDidBecomeEnterForeground"
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(openSiteUrl:)
                                               name:@"appDidOpenSiteUrl"
                                             object:nil];
  [AppDelegate normalNavigationBar];
  //Set our background view
  UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  [_tableView setBackgroundView:bgImageView];
  [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  //[_tableView setRowHeight:56];
  [self setTitle:@"My sites"];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [self set_sites:[[NSMutableArray alloc] initWithArray:[defaults objectForKey:sitesKey]]];
  //Build our Edit Button
  UIButton *uiEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [uiEditButton addTarget:self action:@selector(startEditing) forControlEvents:UIControlEventTouchUpInside];
  [uiEditButton setTitle:@"Edit" forState:UIControlStateNormal];
  uiEditButton.frame = CGRectMake(uiEditButton.frame.origin.x, uiEditButton.frame.origin.y, 62.0, 30.0);
  [uiEditButton setBackgroundImage:[UIImage imageNamed:@"secondary_btn.png"] forState:UIControlStateNormal];
  [uiEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [uiEditButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  self.editButton = [[UIBarButtonItem alloc] initWithCustomView:uiEditButton];
  
  UIButton *uiDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [uiDoneButton addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
  [uiDoneButton setTitle:@"Done" forState:UIControlStateNormal];
  uiDoneButton.frame = CGRectMake(uiDoneButton.frame.origin.x, uiDoneButton.frame.origin.y, 62.0, 30.0);
  [uiDoneButton setBackgroundImage:[UIImage imageNamed:@"content_type_btn.png"] forState:UIControlStateNormal];
  [uiDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [uiDoneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  
  self.doneButton = [[UIBarButtonItem alloc] initWithCustomView:uiDoneButton];
  
  UIButton *addSitesButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [addSitesButton addTarget:self action:@selector(addSite:) forControlEvents:UIControlEventTouchUpInside];
  [addSitesButton setTitle:@"Add Site" forState:UIControlStateNormal];
  addSitesButton.frame = CGRectMake(addSitesButton.frame.origin.x, addSitesButton.frame.origin.y, 62.0, 30.0);
  [addSitesButton setBackgroundImage:[UIImage imageNamed:@"toolbar_add_sites_btn.png"] forState:UIControlStateNormal];
  [addSitesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [addSitesButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];

  self.addButton = [[UIBarButtonItem alloc] initWithCustomView:addSitesButton];
  
  UIImageView *tableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_top_bkg.png"]];
  UIImageView *tableFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bottom_bkg.png"]];
  
  [self.tableView setTableFooterView:tableFooter];
  [self.tableView setTableHeaderView:tableHeader];
  [tableFooter release];
  [tableHeader release];
  [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
  [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  [self.navigationItem setLeftBarButtonItem:self.addButton];
}
- (void) openSiteUrl:(id)url {
  NSString *query = [url object];
  NSArray *tempArrayOne = [query componentsSeparatedByCharactersInSet:
                  [NSCharacterSet characterSetWithCharactersInString:@"="]];
  NSString *tempSite = [tempArrayOne objectAtIndex:1];
  NSArray *tempArrayTwo = [tempSite componentsSeparatedByCharactersInSet:
                  [NSCharacterSet characterSetWithCharactersInString:@"&"]];
  NSString *siteUrl = [tempArrayTwo objectAtIndex:0];
  if ([tempArrayOne count] == 3) {
    contentType = [tempArrayOne objectAtIndex:2];
  }

  int index = [_sites indexOfObject:[AppDelegate siteForUrl:siteUrl]];
  if (index != NSNotFound) {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
  }
}
- (void) addSite:(id)sender {
  DGAddSiteViewController *addsite = [[DGAddSiteViewController alloc] initWithNibName:@"DGAddSiteViewController" bundle:nil];
  [addsite setSiteListViewController:self];
  [AppDelegate addSiteNavigationBar];
  UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:addsite];
  if (sender == self) {
      [self presentViewController:naviController animated:NO completion:nil];
  } else {
    [self presentViewController:naviController animated:YES completion:nil];
  }

  [addsite release];
  newCells = YES;
  [naviController release];
}
- (void)startEditing {
  [self setEditing:YES animated:YES];
  [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
  self.navigationItem.leftBarButtonItem = nil;
}
- (void)doneEditing {
  [self setEditing:NO animated:YES];
  [NSTimer scheduledTimerWithTimeInterval:2 target:_tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
  [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
  self.navigationItem.leftBarButtonItem = addButton;
}

- (void)viewDidUnload
{
  [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  return [_sites count];
    
}

- (DGSiteListCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sitelistcustomcell";
    DGSiteListCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  NSInteger row = [indexPath row];
  if(!cell || newCells) {    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DGSiteListCustomCell" owner:nil options:nil];
    for(id currentObject in topLevelObjects) {
      if([currentObject isKindOfClass:[DGSiteListCustomCell class]]) {
        cell = (DGSiteListCustomCell *)currentObject;
        break;
      }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.dropShadow.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.dropShadow.layer.shadowOffset = CGSizeMake(0, 1);
    cell.dropShadow.layer.shadowOpacity = 1;
    cell.dropShadow.layer.shadowRadius = 2.0f;
    cell.dropShadow.layer.cornerRadius = 3.0f;
    cell.dropShadow.clipsToBounds = NO;
    cell.faviconImg.layer.masksToBounds = YES;
    cell.faviconImg.layer.cornerRadius = 3.0f;
    //
    UIImage *rowBackground = nil;
    UIImage *selectionBackground = nil;

    NSData *imageData = [[_sites objectAtIndex:row] objectForKey:siteFaviconData];
    if (imageData != nil) {
      [cell.faviconImg setImage:[UIImage imageWithData:imageData]];
    }
    [cell showEverything];
    rowBackground = [UIImage imageNamed:@"table_row_bkg.png"];
    selectionBackground = [UIImage imageNamed:@"table_row_bkg.png"];
    [cell.siteLabel setText:[[_sites objectAtIndex:row] objectForKey:siteLabelKey]];
  
    UIImageView *rowBackGroundImageView = [[UIImageView alloc] initWithImage:rowBackground];
    [cell setBackgroundView:rowBackGroundImageView];
    [rowBackGroundImageView release];
    if (selectionBackground != nil) {
      UIImageView *rowBackGroundSelectionImageView = [[UIImageView alloc] initWithImage:selectionBackground];
      [cell setSelectedBackgroundView:rowBackGroundSelectionImageView];
    }
    if(row == [_sites count] - 1) {
      [cell.sep setHidden:YES];
    }
    if ([_sites count] == 1) {
      [cell.sep setHidden:YES];
    }
    [cell.siteLabel setHighlightedTextColor:[UIColor blackColor]];
  }

  return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // Delete the row from the data source
      [self.tableView beginUpdates];
      [_sites removeObjectAtIndex:indexPath.row];
      if([_sites count] == 0) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [defaults setObject:[NSArray new] forKey:sitesKey];
        [[self.tableView tableFooterView] setHidden:YES];
        [[self.tableView tableHeaderView] setHidden:YES];
        
      } else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [defaults setObject:_sites forKey:sitesKey];
      }
      [[NSUserDefaults standardUserDefaults] synchronize];
      [self.tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
  if (sourceIndexPath == destinationIndexPath) {
    return;
  }
  id objectToMove = [[_sites objectAtIndex:sourceIndexPath.row] retain];
  [_sites removeObjectAtIndex:sourceIndexPath.row];
  [_sites insertObject:objectToMove atIndex:destinationIndexPath.row];
  [objectToMove release];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:_sites forKey:sitesKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
  if (self.editing) {
    return UITableViewCellEditingStyleDelete;
  }
  return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}
//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
//{
//  if(proposedDestinationIndexPath.row == [_sites count]) {
//    NSIndexPath *newPath = [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row inSection:0];
//    return newPath;
//  } else if (proposedDestinationIndexPath.row == 0) {
//    NSIndexPath *newPath = [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row + 1 inSection:0];
//    return newPath;
//  }
//  else
//    return proposedDestinationIndexPath;
//}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
 
  DGArticleListMainViewController *detailViewController = [[DGArticleListMainViewController alloc] initWithNibName:@"DGArticleListMainViewController" bundle:nil];

  // ...
  // Pass the selected object to the new view controller.
  NSMutableDictionary *siteInfo = [[NSMutableDictionary alloc] initWithDictionary:[_sites objectAtIndex:indexPath.row]];

  if([AppDelegate isLoggedOutofSiteURL:[siteInfo objectForKey:siteURLKey]]) {
    [self addAltBar];
    DGSiteOauthViewController *oAuthView = [[DGSiteOauthViewController alloc] initWithNibName:@"DGSiteOauthViewController" bundle:nil];
    [oAuthView setSiteUrl:[siteInfo objectForKey:siteURLKey]];
    [oAuthView setSiteViewController:self];
    [oAuthView setSelectedRow:indexPath];
    shouldSelectRow = NO;
    selectedIndex = indexPath;
    [self.navigationController pushViewController:oAuthView animated:YES];
    [oAuthView release];
  } else {
    NSMutableDictionary *siteInfo = [[NSMutableDictionary alloc] initWithDictionary:[_sites objectAtIndex:indexPath.row]];
    [detailViewController setSiteInfo:siteInfo];
    [[detailViewController view] setHidden:NO];
    if(shouldSelectRow) {
      [self.navigationController pushViewController:detailViewController animated:NO];
    } else {
      [self.navigationController pushViewController:detailViewController animated:YES];
    }
    [siteInfo release];
    [detailViewController release];
    [AppDelegate setCurrentSiteID:[[_sites objectAtIndex:indexPath.row] objectForKey:siteURLKey]];
    shouldSelectRow = NO;
    if (contentType != nil) {
      [detailViewController setSelectedContentType:contentType];
    }
  }
  [siteInfo release];
}

@end
