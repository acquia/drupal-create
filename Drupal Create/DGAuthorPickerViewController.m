//
//  DGAuthorPickerViewController.m
//  Drupal Create
//
//  Created by Kyle Browning on 9/3/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGAuthorPickerViewController.h"
#import "DGAutocompleteCell.h"
#import "DGAddArticleViewController.h"
@interface DGAuthorPickerViewController ()

@end

@implementation DGAuthorPickerViewController
@synthesize urlToAutoComplete, tableView, selectedIndex, defaultAuthor, siteSettingsViewController, options;
@synthesize addArticleViewController, fieldInfo, oldOptions, oldSelectedIndex;
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
    // Do any additional setup after loading the view from its nib.
  UIImageView *tableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_top_bkg.png"]];
  UIImageView *tableFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bottom_bkg.png"]];

  [self.tableView setTableFooterView:tableFooter];
  [self.tableView setTableHeaderView:tableHeader];
  [self.tableView setRowHeight:44.0];
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  //Build our search textField;
  [searchField setDelegate:self];
  [searchField addTarget:self action:@selector(searchFieldKeystroke) forControlEvents:UIControlEventEditingChanged];
  [searchField setReturnKeyType:UIReturnKeyDone];

}
-(void)back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return [[options allKeys] count];
}
//When users type in the search field, this function is called.
-(void)searchFieldKeystroke {
  if (![searchField text] || [[searchField text] length] <= 2) {
    selectedIndex = oldSelectedIndex;
    return;
  }
  //Grab the text of the search field.
  NSString *searchFieldText = [searchField text];
  //Did we hit backspace key?
  if (backspace) {
    searchFieldText = [searchFieldText substringToIndex:[searchFieldText length]-1];
    backspace = NO;
  }
  //Loop through all of the options returned fromt the server
  for (NSString *text in [options allValues]) {
    //lowercase our comparisons for case insensitive comparing.
    NSString *newLowerCaseText = [text lowercaseString];
    NSString *newLowerCaseSearchFieldText = [searchFieldText lowercaseString];
    //Find the string for the current iteration of text value.
    NSRange range = [newLowerCaseText rangeOfString:newLowerCaseSearchFieldText];
    //If we didnt find the string, remove it.
    if (range.location == NSNotFound && ([options count] >= 1)) {
      NSArray *temp = [options allKeysForObject:text];
      NSString *key = [temp objectAtIndex:0];
      [options removeObjectForKey:key];
    }
  }
  selectedIndex = nil;
  //Reload table data
  [tableView reloadData];
  //If we run out of options, we should hide the header and footer of the table.
  if ([options count]>=1) {
    [self.tableView.tableHeaderView setHidden:NO];
    [self.tableView.tableFooterView setHidden:NO];
  } else {
    [self.tableView.tableHeaderView setHidden:YES];
    [self.tableView.tableFooterView setHidden:YES];
  }
}
//Using this function to determine if the key hit is a backspace
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
  int isBackSpace = strcmp(_char, "\b");

  if (isBackSpace == -8) {
    // is backspace
    backspace = YES;
    [self setOptions:[NSMutableDictionary dictionaryWithDictionary:oldOptions]];
    [self searchFieldKeystroke];
    [tableView reloadData];
  }

  return YES;
}
- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

  static NSString *CellIdentifier = @"Cell";
  DGAutocompleteCell *cell = [atableView dequeueReusableCellWithIdentifier:CellIdentifier];
  UIImage *rowBackground = nil;
  UIImageView *rowBackGroundImageView = nil;

  // Configure the cell...
  if (!cell) {
    cell = [[DGAutocompleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    rowBackground = [UIImage imageNamed:@"table_row_bkg.png"];

    rowBackGroundImageView = [[UIImageView alloc] initWithImage:rowBackground];
    [cell setBackgroundView:rowBackGroundImageView];
  }
  [cell setIndexPath:indexPath];
  if(selectedIndex != nil) {
    if (indexPath.row == selectedIndex.row) {
      [cell.arrow setHidden:NO];
    } else {
      [cell.arrow setHidden:YES];
    }
  } else {
    NSString *defaultAuthorValue = [defaultAuthor objectForKey:@"value"];
    NSString *currentCell = [[options allValues] objectAtIndex:indexPath.row];
    if ([defaultAuthorValue isEqualToString:currentCell]) {
      [cell.arrow setHidden:NO];
      [self setSelectedIndex:indexPath];
    }
  }
  if ([options count] >= 1)
  [cell.title setText:[[options allValues] objectAtIndex:indexPath.row]];
  if (cell.indexPath.row == [options count] - 1) {
    [cell.separator setHidden:YES];
  }
  [cell setBackgroundColor:[UIColor redColor]];
  [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  return cell;
}
- (void)removeSelection {
  for (int section = 0; section < [self.tableView numberOfSections]; section++) {
    for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
      NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
      DGAutocompleteCell* cell = (DGAutocompleteCell*)[self.tableView cellForRowAtIndexPath:cellPath];
      [[cell arrow] setHidden:YES];
    }
  }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self removeSelection];
  DGAutocompleteCell *cell = (DGAutocompleteCell*)[self.tableView cellForRowAtIndexPath:indexPath];
  if (cell.arrow.hidden) {
    [self setSelectedIndex:indexPath];
    [cell.arrow setHidden:NO];
    if (siteSettingsViewController != nil) {
      NSMutableDictionary *data = [NSMutableDictionary new];
      [data setObject:[[options allKeys] objectAtIndex:indexPath.row] forKey:@"key"];
      [data setObject:[[options allValues] objectAtIndex:indexPath.row] forKey:@"value"];
      [siteSettingsViewController updateDefaultAuthor:data];
      [self back:self];
    } else if (addArticleViewController != nil) {
      NSString *username = [[options allValues] objectAtIndex:indexPath.row];
      NSString *key = [[options allKeys] objectAtIndex:indexPath.row];
      [addArticleViewController addUserName:username forField:[fieldInfo objectForKey:@"name"] andKey:key];
      [self back:self];
    }
  } else {
    [self setSelectedIndex:nil];
    [cell.arrow setHidden:YES];
  }
  [self setOldSelectedIndex:selectedIndex];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [tableView release];
  [super dealloc];
}
- (void)viewDidUnload {
  [tableView release];
  tableView = nil;
  [options release];
  options = nil;
  [defaultAuthor release];
  defaultAuthor = nil;
  [fieldInfo release];
  fieldInfo = nil;
  [self setTableView:nil];
  [super viewDidUnload];
}
@end
