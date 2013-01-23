//
//  DGAddArticleSettingsViewController.m
//  Drupal Create
//
//  Created by Kyle Browning on 7/10/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGAddArticleSettingsViewController.h"
#import "DGAddArticleSettingsCell.h"

@interface DGAddArticleSettingsViewController ()

@end


@implementation DGAddArticleSettingsViewController
@synthesize content;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
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
  [backButton setTitle:@"Back" forState:UIControlStateNormal];
  backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, 62.0, 30.0);
  [backButton setBackgroundImage:[UIImage imageNamed:@"toolbar_back_btn.png"] forState:UIControlStateNormal];
  [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
  [backButton release];
  [self.view setFrame:CGRectMake(0, 0, 320, 480)];
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [self.tableView setRowHeight:55.0f];
  UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  [self.tableView setBackgroundView:bgImageView];
  [self addHeaderAndFooter];
  [self.tableView setScrollEnabled:NO];
}
- (void) addHeaderAndFooter
{
  UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
  v.backgroundColor = [UIColor clearColor];
  [self.tableView setTableHeaderView:v];
  [self.tableView setTableFooterView:v];
  [v release];
}
- (void)back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
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
    return [content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"addarticlesettingscell";
  DGAddArticleSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if(!cell) {
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DGAddArticleSettingsCell" owner:nil options:nil];
    for(id currentObject in topLevelObjects) {
      if([currentObject isKindOfClass:[DGAddArticleSettingsCell class]]) {
        cell = (DGAddArticleSettingsCell *)currentObject;
        break;
      }
    }

  }
  [cell.rowName setText:[[content objectAtIndex:indexPath.row] objectForKey:@"row_name"]];
  [cell.rowValue setText:[[content objectAtIndex:indexPath.row] objectForKey:@"value"]];
  [cell setBackgroundColor:[UIColor redColor]];
  UIImageView *imageView;
  if (indexPath.row == 0) {
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_row_top_bkg.png"]];
  } else {
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bottom_row_bkg.png"]];
  }
  [cell setBackgroundView:imageView];
  [imageView release];
  [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
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

}

@end
