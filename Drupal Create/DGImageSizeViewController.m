//
//  DGImageSizeViewController.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/28/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGImageSizeViewController.h"
#import "DGImageSizeCell.h"
#import "DGAppDelegate.h"

@interface DGImageSizeViewController ()

@end

@implementation DGImageSizeViewController
@synthesize ImageSizeSettings, imageSizeOptions, siteInfo;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setTitle:@"Image Size"];
  UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  [self.tableView setBackgroundView:bgImageView];
  UIImageView *optionsTableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_top_bkg.png"]];
  UIImageView *optionsTableFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bottom_bkg.png"]];
  [ImageSizeSettings setTableHeaderView:optionsTableHeader];
  [ImageSizeSettings setTableFooterView:optionsTableFooter];
  [ImageSizeSettings setBackgroundColor:[UIColor clearColor]];
  [ImageSizeSettings setSeparatorStyle:UITableViewCellSelectionStyleNone];
  UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  [backButton setTitle:@"Back" forState:UIControlStateNormal];
  backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, 62.0, 30.0);
  [backButton setBackgroundImage:[UIImage imageNamed:@"toolbar_back_btn.png"] forState:UIControlStateNormal];
  [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
  [backButton release];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 3;
}

-(NSString *) cellIdentifierforIndexPath:(NSIndexPath*)indexPath
{
  NSString *cellIdentifier = @"cell";
  return cellIdentifier;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIImage *rowBackground = nil;
  UIImageView *rowBackGroundImageView = nil;
  
  
  
  DGImageSizeCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierforIndexPath:indexPath]];
  if(!cell) {
    cell = [[DGImageSizeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIdentifierforIndexPath:indexPath]];
    rowBackground = [UIImage imageNamed:@"table_row_bkg.png"];
    rowBackGroundImageView = [[UIImageView alloc] initWithImage:rowBackground];
    [cell setBackgroundView:rowBackGroundImageView];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
    NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
    NSString *content = [cache objectForKey:imageSizeKey];
     NSDictionary *cellData = [imageSizeOptions objectAtIndex:indexPath.row];
    if (content != nil) {
      if ([[cellData valueForKey:@"value"] isEqualToString: content]) {
        [[cell checkMark] setHidden:NO];
      }
    } else {
      if([[cellData objectForKey:@"label"] isEqualToString:@"Large"]) {
        [[cell checkMark] setHidden:NO];
      }
    }
  }

  [cell.textLabel setHidden:YES];
  NSDictionary *cellData = [imageSizeOptions objectAtIndex:indexPath.row];
  [cell.label setText:[cellData objectForKey:@"label"]];
  if(indexPath.row == 2) {
    [[cell sep] setHidden:YES];
  }
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *cellData = [imageSizeOptions objectAtIndex:indexPath.row];
  NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  [cache setObject:[cellData valueForKey:@"value"] forKey:imageSizeKey];
  [AppDelegate saveCache:cache ForKey:contentCachekey];
  
  [self removeSelection];
  DGImageSizeCell* cell = (DGImageSizeCell*)[self.tableView cellForRowAtIndexPath:indexPath];
  [[cell checkMark] setHidden:NO];
}

- (void)removeSelection {
  for (int section = 0; section < [self.tableView numberOfSections]; section++) {
    for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
      NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
      DGImageSizeCell* cell = (DGImageSizeCell*)[self.tableView cellForRowAtIndexPath:cellPath];
      [[cell checkMark] setHidden:YES];
    }
  }
}

- (void)viewDidAppear:(BOOL)animated {

}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // rows in section 0 should not be selectable
  NSDictionary *cellData = [imageSizeOptions objectAtIndex:indexPath.row];
  if ([cellData objectForKey:@"selectable"] == 0) {
    return nil;
  }
  return indexPath;
}

- (void)dealloc {
  [ImageSizeSettings release];
  [super dealloc];
}

@end
