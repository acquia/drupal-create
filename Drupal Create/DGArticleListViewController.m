//
//  DGArticleListViewController.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGArticleListViewController.h"
#import "DGDClient.h"
#import "DGAppDelegate.h"
#import "DGAddArticleViewController.h"
#import "DGArticleListCustomCell.h"
#import <QuartzCore/QuartzCore.h>
#import "DGCustomMySitesButton.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+WebCache.h"
#import "DGContentViewController.h"
#define articleCacheKey @"articleCache"
@interface DGArticleListViewController ()

@end

@implementation DGArticleListViewController
@synthesize tableView = _tableView;
@synthesize content   = _content;
@synthesize siteNid   = _siteNid;
@synthesize siteInfo  = _siteInfo;
@synthesize  mainViewController;
@synthesize shouldUpdate;
@synthesize selectedSwipeRow;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}
- (void)refresh {
  [self performSelector:@selector(loadContentForUser:) withObject:self afterDelay:1.0];
  [mainViewController getFieldInfo];
  [mainViewController hideAllContentButtons];
}
- (void)loadContentForUser:(id)bypass {
  NSString *contentCachekey = [[_siteInfo objectForKey:siteURLKey] MD5];
  if([AppDelegate isCacheOutOfDate:contentCachekey expiryKey:expireTimestampKey expireTime:300] || [bypass isEqual:self]) {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@"0" forKey:@"start"];
    [params setObject:@"100" forKey:@"count"];
    [DGDClient getContentByUserWithURL:[_siteInfo objectForKey:siteURLKey] params:params accessTokens:[_siteInfo objectForKey:siteAccessTokens] success:^(AFHTTPRequestOperation *operation, id responseObject) {
      _content = [[NSMutableArray alloc] init];
      for (NSString *node in [responseObject objectForKey:@"values"]) {
        NSMutableDictionary *nodeDict = [[NSMutableDictionary alloc] initWithDictionary:[[responseObject objectForKey:@"values"] objectForKey:node]];
        [nodeDict setObject:node forKey:@"nid"];
        [_content addObject:nodeDict];
        [nodeDict release];
      }
      NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
      [_content sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
      [self setContent:[NSMutableArray arrayWithArray:_content]];
      [sortDescriptor release];
      [_tableView reloadData];
      [self stopLoading];
      NSDate *expireDate = [NSDate new];
      NSTimeInterval time = [expireDate timeIntervalSince1970];
      NSString *timeStamp = [NSString stringWithFormat:@"%f", time];
      NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
      if(cache == nil) {
        cache = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:_content, timeStamp, nil] forKeys:[NSArray arrayWithObjects:@"data", expireTimestampKey, nil]];
      } else {
        [cache setObject:_content forKey:@"data"];
        [cache setObject:timeStamp forKey:expireTimestampKey];
      }
      [AppDelegate saveCache:cache ForKey:contentCachekey expireKey:expireAuthorTimestampKey];
      [cache release];
      [expireDate release];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      if (operation.response.statusCode == 404) {
        [[AppDelegate customStatusBar] showWithStatusMessage:@"Misconfigured site. Contact the site administrator."];
      } else if (operation.response.statusCode == 401) {
        [[AppDelegate customStatusBar] showWithStatusMessage:@"Authentication failed. Logging out."];
        [AppDelegate logoutOfSiteWithURL:[_siteInfo objectForKey:siteURLKey] shouldForceLogout:YES];
      }
      else {
        [[AppDelegate customStatusBar] showWithStatusMessage:@"Failed to load content."];
      }
      [self stopLoading];
      [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideStatus) userInfo:nil repeats:NO];
    }];
  } else {
    NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
    [self setContent:[NSMutableArray arrayWithArray:[cache objectForKey:@"data"]]];
    [self stopLoading];
    [_tableView reloadData];
  }

}
-(void)scrollViewDidScroll: (UIScrollView*)scrollView
{
  [super scrollViewDidScroll:scrollView];
  float scrollViewHeight = scrollView.frame.size.height;
  float scrollContentSizeHeight = scrollView.contentSize.height;
  float scrollOffset = scrollView.contentOffset.y;
  
  if (scrollOffset == 0) {
    // then we are at the top
  }
  else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
    // then we are at the end
  }
}
- (void)hideStatus {
  [[AppDelegate customStatusBar] hide:2.0];
}
- (void) addHeaderAndFooter
{
  UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
  v.backgroundColor = [UIColor clearColor];
  [_tableView setTableHeaderView:v];
  [_tableView setTableFooterView:v];
  [v release];
}
#pragma mark -
#pragma mark view delegate methods

- (void) internetFailed:(id)sender {
  [self stopLoading];
  [self removeSelection];
}
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setShouldUpdate:NO];
  [self.view setFrame:CGRectMake(0, 0, 320, 480)];
  UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  [_tableView setBackgroundView:bgImageView];
  [bgImageView release];
  [self addHeaderAndFooter];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(internetFailed:)
                                               name:@"internetConnectionFailed"
                                             object:nil];
  //Add a left swipe gesture recognizer
  UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(handleSwipeLeft:)];
  [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
  [self.tableView addGestureRecognizer:recognizer];
  [recognizer release];
  
  //Add a right swipe gesture recognizer
  recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                         action:@selector(handleSwipeRight:)];
  recognizer.delegate = self;
  [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
  [self.tableView addGestureRecognizer:recognizer];
  [recognizer release];
  UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 70, 0);

  [self.tableView setContentInset:insets];
  [self.tableView setScrollIndicatorInsets:insets];
}

- (void) viewWillAppear:(BOOL)animated {
  [mainViewController.navigationController setNavigationBarHidden:NO];
}
- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if ([_content count] == 0) {
    [self loadContentForUser:self];
  }
  if (shouldUpdate) {
//    [self startLoading];
//    [self.tableView scrollRectToVisible:CGRectMake(-10, 10, 10, 10) animated:YES];
  }
  //self.tableView.contentInset = UIEdgeInsetsMake(52.0, 0, 0, 0);
  [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

}
- (void)viewDidUnload
{
  [tableView release];
  tableView = nil;
  [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Swipe handling
- (void)removeSelection {
  for (int section = 0; section < [self.tableView numberOfSections]; section++) {
    for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
      NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
      DGArticleListCustomCell* cell = (DGArticleListCustomCell*)[self.tableView cellForRowAtIndexPath:cellPath];
      [cell hideSelection];
    }
  }
}
- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
  //Get location of the swipe
  CGPoint location = [gestureRecognizer locationInView:self.tableView];
  
  //Get the corresponding index path within the table view
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
  //Check if index path is valid
  if(indexPath) {
    //Get the cell out of the table view
    DGArticleListCustomCell *cell = (DGArticleListCustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self setSelectedSwipeRow:indexPath];
    CGRect imageFrame =  CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    if([cell selectionView].hidden) {
      [self removeSelection];
      [cell showSelection];
      [cell.selectionView setFrame:CGRectMake(320, 0, cell.frame.size.width, cell.frame.size.height)];
      [UIView animateWithDuration:0.2
                            delay:0.0
                          options: UIViewAnimationOptionCurveLinear
                       animations:^{
                         cell.selectionView.frame = imageFrame;
                       }
                       completion:^(BOOL finished){
                       }];
    } else {
      imageFrame =  CGRectMake(-320, 0, cell.frame.size.width, cell.frame.size.height);
      [UIView animateWithDuration:0.2
                            delay:0.0
                          options: UIViewAnimationOptionCurveLinear
                       animations:^{
                         cell.selectionView.frame = imageFrame;
                       }
                       completion:^(BOOL finished){
                         if(finished)
                           [cell hideSelection];
                       }];
    }
  }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{

  //Get location of the swipe
  CGPoint location = [gestureRecognizer locationInView:self.tableView];
  
  //Get the corresponding index path within the table view
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
  
  //Check if index path is valid
  if(indexPath) {
    //Get the cell out of the table view
    DGArticleListCustomCell *cell = (DGArticleListCustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self setSelectedSwipeRow:indexPath];
    CGRect imageFrame =  CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    if([cell selectionView].hidden) {
      [self removeSelection];
      [cell showSelection];
      [cell.selectionView setFrame:CGRectMake(-320, 0, cell.frame.size.width, cell.frame.size.height)];
      [UIView animateWithDuration:0.2
                            delay:0.0
                          options: UIViewAnimationOptionCurveLinear
                       animations:^{
                         cell.selectionView.frame = imageFrame;
                       }
                       completion:^(BOOL finished){
                       }];
    } else {
      imageFrame =  CGRectMake(320, 0, cell.frame.size.width, cell.frame.size.height);
      [UIView animateWithDuration:0.2
                            delay:0.0
                          options: UIViewAnimationOptionCurveLinear
                       animations:^{
                         cell.selectionView.frame = imageFrame;
                       }
                       completion:^(BOOL finished){
                         if(finished)
                         [cell hideSelection];
                       }];
    }
  }
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
    return [_content count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 80;
}

- (DGArticleListCustomCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"articlelistcustomcell";
  DGArticleListCustomCell *cell = (DGArticleListCustomCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if(!cell) {
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DGArticleListCustomCell" owner:nil options:nil];
    for(id currentObject in topLevelObjects) {
      if([currentObject isKindOfClass:[DGArticleListCustomCell class]]) {
        cell = (DGArticleListCustomCell *)currentObject;
        break;
      }
    }
    //cell.dropShadow.backgroundColor = [UIColor clearColor];
    cell.contentImg.layer.masksToBounds = YES;
    cell.contentImg.layer.cornerRadius = 3.0f;
    [cell setVc:self];

  }
  [cell.selectionView setHidden:YES];
  // Configure the cell...
  NSDictionary *data = [_content objectAtIndex:indexPath.row];

  NSString *imageURL = [data objectForKey:@"image"];

  NSURL *myURL = [NSURL URLWithString:imageURL];
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"h:mm a, MMM dd"];
  [cell.titleLabel setText:[[_content objectAtIndex:indexPath.row] objectForKey:@"title"]];
  NSString *timeString = [[_content objectAtIndex:indexPath.row] objectForKey:@"timestamp"];
  
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeString intValue]];
  NSString *stringLabelDate = [dateFormatter stringFromDate:date];
  [cell.timeLabel setText:stringLabelDate];
  [cell.bodyLabel setText:[data objectForKey:@"teaser"]];
  [cell.contentImg setImageWithURL:myURL];
  
  [dateFormatter release];
  return cell;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)atableView heightForHeaderInSection:(NSInteger)section {
  if ([self tableView:atableView titleForHeaderInSection:section] != nil) {
    return 30;
  }
  else {
    // If no section header title, no section header needed
    return 0;
  }
}


- (UIView *)tableView:(UITableView *)atableView viewForHeaderInSection:(NSInteger)section {
  NSString *sectionTitle = [self tableView:atableView titleForHeaderInSection:section];
  if (sectionTitle == nil) {
    return nil;
  }
  
  // Create label with section title
  UILabel *label = [[[UILabel alloc] init] autorelease];
  label.frame = CGRectMake(5, 2, 320, 26);
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [UIColor blackColor];
  label.shadowOffset = CGSizeMake(0.0, 1.0);
  label.font = [UIFont boldSystemFontOfSize:12];
  label.text = sectionTitle;
  
  // Create header view and add label as a subview
  UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_posts_header.png"]];
  [view autorelease];
  [view addSubview:label];
  
  return view;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return @"My Posts";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self setSelectedSwipeRow:indexPath];
  DGArticleListCustomCell *cell = (DGArticleListCustomCell*)[self.tableView cellForRowAtIndexPath:indexPath];
  if(cell.selectionView.hidden) {
    [self removeSelection];
    [self showArticle];
  } else {
    [cell hideSelection];
    [cell setSelected:NO animated:YES];
  }
}
#pragma mark -
#pragma mark sharing methods


- (void) showShareDialog {
  UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@"Share" delegate: self cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle: nil
                                                 otherButtonTitles: @"Open in Safari", @"Copy link", @"Mail link", nil, nil];
  
  [styleAlert showInView:self.view];
  shareActionSheet = styleAlert;
}
- (NSString *) getNodePath {
  NSDictionary *selectedContent =  [_content objectAtIndex:selectedSwipeRow.row];
  NSString *url = [_siteInfo objectForKey:siteURLKey];
  url = [url stringByAppendingFormat:@"/%@", [selectedContent objectForKey:@"path"]];
  return url;
}

- (NSString *) getNodeNid{
  NSDictionary *selectedContent =  [_content objectAtIndex:selectedSwipeRow.row];
  return [selectedContent objectForKey:@"nid"];
}
- (NSString *) getNodeTitle{
  NSDictionary *selectedContent =  [_content objectAtIndex:selectedSwipeRow.row];
  return [selectedContent objectForKey:@"title"];
}
- (void) deleteRowAtIndexPath:(NSIndexPath*)indexPath {
  [self setSelectedSwipeRow:indexPath];
  [self deleteNode];
}
- (void) deleteNode {
  [[AppDelegate customStatusBar] showWithStatusMessage:@"Deleting..." showLoadingIndicator:YES];
  [self removeSelection];
  NSIndexPath *indexPath = [selectedSwipeRow copy];
  [DGDClient deleteNid:[self getNodeNid] withUrl:[_siteInfo objectForKey:siteURLKey] accessTokens:[_siteInfo objectForKey:siteAccessTokens] success:^(AFHTTPRequestOperation *operation, id responseObject) {
    [_content removeObjectAtIndex:indexPath.row];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    NSDate *expireDate = [NSDate new];
    NSTimeInterval time = [expireDate timeIntervalSince1970];
    NSString *timeStamp = [NSString stringWithFormat:@"%f", time];
    NSString *contentCachekey = [[_siteInfo objectForKey:siteURLKey] MD5];
    NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
    [cache setObject:_content forKey:@"data"];
    [cache setObject:timeStamp forKey:expireTimestampKey];
    [AppDelegate saveCache:cache ForKey:contentCachekey expireKey:expireTimestampKey];
    [[AppDelegate customStatusBar] hide];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [[AppDelegate customStatusBar] hide];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
  }];
}

- (void)shareViaMail {
  if([MFMailComposeViewController canSendMail]) {

    NSString *body = [self getNodePath];
    NSString *title = [self getNodeTitle];
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *mailtoURLString = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@", title, [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoURLString]];
  } else {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error"
                          message: @"It appears you have no mail accounts setup. Please set one up and try again."
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  switch (result)
    {
      case MFMailComposeResultCancelled:
        NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
        break;
      case MFMailComposeResultSaved:
        NSLog(@"Mail saved: you saved the email message in the drafts folder.");
        break;
      case MFMailComposeResultSent:
        NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
        break;
      case MFMailComposeResultFailed:
        NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
        break;
      default:
        NSLog(@"Mail not sent.");
        break;
    }
  
  // Remove the mail view
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if(actionSheet == shareActionSheet) {
    UIPasteboard *pb;
    switch (buttonIndex) {
      case 0:
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self getNodePath]]];
        break;
      case 1:
        pb = [UIPasteboard generalPasteboard];
        [pb setString: [self getNodePath]];
        [[AppDelegate customStatusBar] showWithStatusMessage:@"Copied to clipboard"];
        [self removeSelection];
        [[AppDelegate customStatusBar] hide];;
        break;
      case 2:
        //Mail
        [self shareViaMail];
        break;
      default:
        break;
    }
    [shareActionSheet release];
  } else if(deleteActionSheet == actionSheet) {
    switch (buttonIndex) {
      case 0:
        [self deleteNode];
        break;
      case 1:
        [self.tableView deselectRowAtIndexPath:selectedSwipeRow animated:YES];
    }
  }
}
- (void) showArticle {
  DGContentViewController *webView = [[DGContentViewController alloc] initWithNibName:@"DGContentViewController" bundle:nil];
  NSString *url = [self getNodePath];
  [webView setUrlToLoad:url];
  [webView setCustomTitle:[self getNodeTitle]];
  [webView setArticleListViewController:self];
  [webView setSelectedIndexPath:selectedSwipeRow];
  [mainViewController.navigationController pushViewController:webView animated:YES];
  [webView loadWebView];
  [webView release];
}
- (void) showDeleteDialog {
  UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate: self cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle: @"Delete"
                                                 otherButtonTitles: nil];
  
  [styleAlert showInView:self.view];
  deleteActionSheet = styleAlert;
}
- (void)dealloc {
  [tableView release];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}
@end
