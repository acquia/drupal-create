//
//  DGAddTagsViewController.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGAddTagsViewController.h"
#import "DGDClient.h"
#import "DGAppDelegate.h"
#import "DGAutocompleteCell.h"
#import "AFHTTPRequestOperation.h"
@interface DGAddTagsViewController ()

@end

@implementation DGAddTagsViewController
@synthesize fieldInfo;
@synthesize contentType;
@synthesize siteInfo, results, options, selectedTags, searchresults, oldOptions, addArticleViewController, allTagKeys, maxSelectCount, selectedCount, createdTags;
@synthesize  originalTagsResponse;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}
- (void) viewWillAppear:(BOOL)animated {
  if ([[[fieldInfo objectForKey:@"options"] objectForKey:@"create"] boolValue]) {
    [searchFieldUIView setHidden:NO];
  } else {
    [searchFieldUIView setHidden:YES];
    nonCreateTableViewFrame = CGRectMake(0, 0, 320, self.view.bounds.size.height);
    [optionsTableView setFrame:nonCreateTableViewFrame];
  }
}
- (void)viewDidLoad
{
  [super viewDidLoad];
  //Set Title
  [self setTitle:[fieldInfo objectForKey:@"label"]];
  options = [NSMutableArray new];
  results = [NSMutableArray new];
  if(createdTags == nil) {
    createdTags = [NSMutableArray new];
  }
  nonCreateTableViewFrame = CGRectMake(0, 50, 320, self.view.bounds.size.height);
  [self setSelectedCount:0];
  
  [resultsTableView setHidden:YES];
  [optionsTableView setHidden:YES];
  
  //Build and add cancel button
  UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
  [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
  cancelButton.frame = CGRectMake(cancelButton.frame.origin.x, cancelButton.frame.origin.y, 62.0, 30.0);
  [cancelButton setBackgroundImage:[UIImage imageNamed:@"secondary_btn.png"] forState:UIControlStateNormal];
  [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:cancelButton]];
  [cancelButton release];
  
  //Build and Add Done Button
  UIButton *uiDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [uiDoneButton addTarget:self action:@selector(doneTagging:) forControlEvents:UIControlEventTouchUpInside];
  [uiDoneButton setTitle:@"Done" forState:UIControlStateNormal];
  uiDoneButton.frame = CGRectMake(uiDoneButton.frame.origin.x, uiDoneButton.frame.origin.y, 62.0, 30.0);
  [uiDoneButton setBackgroundImage:[UIImage imageNamed:@"content_type_btn.png"] forState:UIControlStateNormal];
  [uiDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [uiDoneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:uiDoneButton];
  [self.navigationItem setRightBarButtonItem:doneButtonItem];
  [doneButtonItem release];
  
  //Build our search textField;
  [searchField setDelegate:self];
  [searchField addTarget:self action:@selector(searchFieldKeystroke) forControlEvents:UIControlEventEditingChanged];
  [searchField setPlaceholder:@"Find or Create Tags"];
  [searchField setReturnKeyType:UIReturnKeyDone];
  //Add our backgroundImageView;
  UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  [bgImageView release];
  NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  NSString *fieldInfoKey = [[NSString stringWithFormat:@"%@%@", contentType, [fieldInfo objectForKey:@"name"]] MD5];
//  NSMutableDictionary *content = [cache objectForKey:fieldInfoKey];
  NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:contentType, [fieldInfo objectForKey:@"name"], @"400", nil]
                                                       forKeys:[NSArray arrayWithObjects:@"bundle", @"field_name", @"count", nil]];
  NSMutableDictionary *content = [cache objectForKey:fieldInfoKey];
  NSString *fieldExpire = [NSString stringWithFormat:@"%@%@", [fieldInfo objectForKey:@"name"], expireOptionsTimestampKey];
  if (content == nil || [AppDelegate isCacheOutOfDate:contentCachekey expiryKey:fieldExpire expireTime:300]) {
    [[AppDelegate customStatusBar] showWithStatusMessage:@"Loading options..." showLoadingIndicator:YES];
    [DGDClient getOptions:[siteInfo objectForKey:siteURLKey]
             accessTokens:[siteInfo objectForKey:siteAccessTokens]
                   bundle:contentType params:params
                fieldName:[fieldInfo objectForKey:@"name"]
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSDictionary *dict = [responseObject objectForKey:@"values"];
                      allTagKeys = [[NSMutableDictionary alloc] initWithDictionary:dict];
                      originalTagsResponse = [[NSMutableDictionary alloc] initWithDictionary:dict];
                      [self setOptions:[NSMutableArray arrayWithArray:[allTagKeys allValues]]];
                      [optionsTableView setHidden:NO];
                      [optionsTableView reloadData];
                      [self addCreatedTagsToOptions ];
                      [cache setObject:allTagKeys forKey:fieldInfoKey];
                      [AppDelegate saveCache:cache ForKey:contentCachekey expireKey:fieldExpire];
                      [[AppDelegate customStatusBar] hide];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (operation.response.statusCode == CONTENT_TYPE_ERROR_CODE) {
                        [self dismissModalViewControllerAnimated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DrupalCreateContentTypesChanged" object:nil];
                        NSString *text = [NSString stringWithFormat:@"%@ is disabled, reloading settings...", contentType];
                        [[AppDelegate customStatusBar] showWithStatusMessage:text hide:NO];
                        [[AppDelegate customStatusBar] hide:3.0f];
                      }
                    }
       ];
  } else {
    allTagKeys = [[NSMutableDictionary alloc] initWithDictionary:content];
    originalTagsResponse = [[NSMutableDictionary alloc] initWithDictionary:content];
    [self setOptions:[NSMutableArray arrayWithArray:[allTagKeys allValues]]];
    [optionsTableView setHidden:NO];
    [optionsTableView reloadData];
    [self addCreatedTagsToOptions ];
  }
  UIImageView *optionsTableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_top_bkg.png"]];
  UIImageView *optionsTableFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bottom_bkg.png"]];
  UIImageView *resultsTableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_top_bkg.png"]];
  UIImageView *resultsTableFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_bottom_bkg.png"]];
  [optionsTableView setTableHeaderView:optionsTableHeader];
  [optionsTableView setTableFooterView:optionsTableFooter];
  [optionsTableView setBackgroundColor:[UIColor clearColor]];
  [optionsTableView setSeparatorStyle:UITableViewCellSelectionStyleNone];
  [resultsTableView setTableHeaderView:resultsTableHeader];
  [resultsTableView setTableFooterView:resultsTableFooter];
  [resultsTableView setBackgroundColor:[UIColor clearColor]];
  [resultsTableView setSeparatorStyle:UITableViewCellSelectionStyleNone];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  if (oldOptions != nil) {
    [self setOptions:oldOptions];
    [optionsTableView reloadData];
  }
  return YES;
}
-(void)positionTableViews {
  //[tagSearchResultsViewController.tableView setHidden:YES];
  //[addedTagsListTableViewController.tableView setHidden:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  CGFloat size = 0.0;
  if (tableView == resultsTableView) {
    if (indexPath.row == 0 || indexPath.row == [results count] - 1) {
      size = 42.0;
    }
  } else if(tableView == optionsTableView) {
    if (indexPath.row == 0) {
      size = 40.0;
    } else if(indexPath.row == [options count] - 1) {
      size = 40.0;
    } else {
      size = 44.0;
    }
  }
  return size;
}
-(void)searchFieldKeystroke {

  if (![searchField text] || [[searchField text] length] <= 2) {
    allTagKeys = originalTagsResponse;
    [self setOptions:[NSMutableArray arrayWithArray:[allTagKeys allValues]]];
    [optionsTableView reloadData];
    [self addCreatedTagsToOptions ];
    return;
  }
  
  [DGDClient getAutocompleteValues:[siteInfo objectForKey:siteURLKey]
                      accessTokens:[siteInfo objectForKey:siteAccessTokens]
                            bundle:contentType
                         fieldName:[fieldInfo objectForKey:@"name"]
                             match:[searchField text]
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                    [optionsTableView setHidden:NO];
                     allTagKeys = [NSMutableDictionary new];
                    [optionsTableView reloadData];
                    [self showCreateTagButton];
                  } else {
                    allTagKeys = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
                    [self setOptions:[NSMutableArray arrayWithArray:[allTagKeys allValues]]];
                    [optionsTableView setHidden:NO];
                    [optionsTableView reloadData];
                    [self hideCreateTagButton];
                    [self addCreatedTagsToOptions ];
                    if (![[allTagKeys allValues] containsObject:[searchField text]]) {
                      [self showCreateTagButton];
                    }
                  }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  if (operation.response.statusCode == CONTENT_TYPE_ERROR_CODE) {
                    [self dismissModalViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DrupalCreateContentTypesChanged" object:nil];
                    NSString *text = [NSString stringWithFormat:@"%@ is disabled, reloading settings...", contentType];
                    [[AppDelegate customStatusBar] showWithStatusMessage:text hide:NO];
                    [[AppDelegate customStatusBar] hide:3.0f];
                  }
                }
   ];
}
- (void) addCreatedTagsToOptions {
  for (NSString *tag in createdTags) {
    [options insertObject:tag atIndex:0];
    [optionsTableView reloadData];
  }
}
- (void) showCreateTagButton {
  [addTagButton setHidden:NO];
}
- (void) hideCreateTagButton {
  [addTagButton setHidden:YES];
}
- (void)viewDidUnload
{
  [optionsTableView release];
  optionsTableView = nil;
  [resultsTableView release];
  resultsTableView = nil;
  [searchFieldUIView release];
  searchFieldUIView = nil;
  [addTagButton release];
  addTagButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  [searchField release];
  searchField = nil;
}
- (void) cancel:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}
- (void) doneTagging:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
  [optionsTableView release];
  [resultsTableView release];
  [searchFieldUIView release];
  [addTagButton release];
  [super dealloc];
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
  if (tableView == optionsTableView) {
    if([allTagKeys respondsToSelector:@selector(allValues)]) {
      [[optionsTableView tableFooterView] setHidden:NO];
      [[optionsTableView tableHeaderView] setHidden:NO];
      if([[allTagKeys allValues]count] == 0) {
        [[optionsTableView tableFooterView] setHidden:YES];
        [[optionsTableView tableHeaderView] setHidden:YES];
      }
      return [[allTagKeys allValues] count];
    } else {
      [[optionsTableView tableFooterView] setHidden:YES];
      [[optionsTableView tableHeaderView] setHidden:YES];
      return 0;
    }
  } else if(tableView == resultsTableView) {
    return [results count];
  }
  [[optionsTableView tableFooterView] setHidden:YES];
  [[optionsTableView tableHeaderView] setHidden:YES];
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  static NSString *CellIdentifier = @"Cell";
  DGAutocompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  UIImage *rowBackground = nil;
  UIImageView *rowBackGroundImageView = nil;

  // Configure the cell...
  if (!cell) {
    cell = [[DGAutocompleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  [cell setIndexPath:indexPath];
  if(tableView == optionsTableView) {
    [cell.title setText:[options objectAtIndex:indexPath.row]];
    if([[selectedTags objectForKey:[fieldInfo objectForKey:@"name"]] containsObject:[options objectAtIndex:indexPath.row]]) {
      [cell.arrow setHidden:NO];
    }
    rowBackground = [UIImage imageNamed:@"table_row_bkg.png"];
  }

  rowBackGroundImageView = [[UIImageView alloc] initWithImage:rowBackground];
  [cell setBackgroundView:rowBackGroundImageView];
  [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(DGAutocompleteCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == resultsTableView) {
    if (indexPath.row == [results count] - 1 || (indexPath.row == 0 && [results count] == 1)) {
      [cell.separator setHidden:YES];
    }
  } else if(tableView == optionsTableView) {
    if (indexPath.row == [[allTagKeys allValues] count] - 1 || (indexPath.row == 0 && [[allTagKeys allValues] count] == 1)) {
      [cell.separator setHidden:YES];
    }
  }
  if(cell.createdTag) {
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
  }
}
- (NSString*)keyForObject:(NSString*)value {
  NSArray *temp = [allTagKeys allKeysForObject:value];
  if([temp count]) {
      return [temp objectAtIndex:0];
  }
  return @"";
}
#pragma mark - Table view delegate
- (void) hideAllCheckMarks {
  for (int section = 0; section < [optionsTableView numberOfSections]; section++) {
    for (int row = 0; row < [optionsTableView numberOfRowsInSection:section]; row++) {
      NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
      DGAutocompleteCell* cell = (DGAutocompleteCell*)[optionsTableView cellForRowAtIndexPath:cellPath];
      [[cell arrow] setHidden:YES];
    }
  }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSLog(@"%@", [NSNumber numberWithInt:[[fieldInfo objectForKey:@"cardinality"] integerValue]]);
  NSLog(@"%@", [NSNumber numberWithInt:[[selectedTags objectForKey:[fieldInfo objectForKey:@"name"]] count] +1]);
  if (tableView == optionsTableView) {
    if([[fieldInfo objectForKey:@"cardinality"] isEqualToString:@"1"] && [[selectedTags objectForKey:[fieldInfo objectForKey:@"name"]] count]+1 <= 1) {
      [addArticleViewController removeAllTagsForField:[fieldInfo objectForKey:@"name"]];
    } else if ([NSNumber numberWithInt:[[fieldInfo objectForKey:@"cardinality"] integerValue]] < [NSNumber numberWithInt:[[selectedTags objectForKey:[fieldInfo objectForKey:@"name"]] count] +1]) {
      [addArticleViewController removeLastAddedTagForField:[fieldInfo objectForKey:@"name"]];
      [optionsTableView reloadData];
    }
//    } else if ([[fieldInfo objectForKey:@"cardinality"] isEqualToString:[[NSNumber numberWithInt:[[selectedTags objectForKey:[fieldInfo objectForKey:@"name"]] count] +1] stringValue]]) {
//      [addArticleViewController removeLastAddedTagForField:[fieldInfo objectForKey:@"name"]];
//    }
    DGAutocompleteCell *cell = (DGAutocompleteCell*)[optionsTableView cellForRowAtIndexPath:indexPath];
    NSString *title = [options objectAtIndex:indexPath.row];
    if (cell.arrow.hidden) {
      if ([createdTags containsObject:title]) {
        [addArticleViewController createTagToSendWithNode:[self keyForObject:title] forField:[fieldInfo objectForKey:@"name"] withName:title];
      } else {
        [addArticleViewController addTagToSendWithNode:[self keyForObject:title] forField:[fieldInfo objectForKey:@"name"] withName:title];
      }
      
      [cell.arrow setHidden:NO];
      selectedCount++;
    } else {
      [cell.arrow setHidden:YES];

      if ([createdTags containsObject:title]) {
        [addArticleViewController removeCreateTagToSendWithNode:title forField:[fieldInfo objectForKey:@"name"] tagName:title];
      } else {
        NSString *keyToremove = [self keyForObject:title];
        [addArticleViewController removeTagToSendWithNode:keyToremove forField:[fieldInfo objectForKey:@"name"] tagName:title];
      }
      [createdTags removeObject:title];
      selectedCount--;
    }
  } else if(tableView == resultsTableView) {
    //
  }

}
- (IBAction)createTag:(id)sender {
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *trimmed = [[searchField text] stringByTrimmingCharactersInSet:whitespace];
  if ([createdTags containsObject:trimmed]) {
    [[AppDelegate customStatusBar] showWithStatusMessage:@"That tag has already been added." hide:YES];
    return;
  }
  if ([trimmed length] == 0) {
    NSString *requiredField = [NSString stringWithFormat:@"Tags cannot contain only spaces."];
    [[AppDelegate customStatusBar] showWithStatusMessage:requiredField hide:YES];
    return;
  }
  [createdTags addObject:trimmed];
  [allTagKeys setObject:trimmed forKey:trimmed];
  [options insertObject:trimmed atIndex:0];
  [optionsTableView reloadData];
  NSUInteger newIndex[]   = {0, 0};
  [self tableView:optionsTableView didSelectRowAtIndexPath:[[NSIndexPath alloc] initWithIndexes:newIndex length:2]];
}
@end
