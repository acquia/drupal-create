//
//  DGMasterViewController.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGMasterViewController.h"
#import "DGSiteListViewController.h"
#import "DGAppDelegate.h"
#import "DGArticleListMainViewController.h"
#import "DGCameraOverlayViewController.h"
@interface DGMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation DGMasterViewController
@synthesize login, siteListViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.title = NSLocalizedString(@"Master", @"Master");
      siteListViewController = [[DGSiteListViewController alloc] initWithNibName:@"DGSiteListViewController" bundle:nil];
    }
    return self;
}
- (IBAction)login:(id)sender {
//  [[NSBundle mainBundle] loadNibNamed:@"DGCustomNormalNavBar" owner:self options:nil];
//  UINavigationController *navController = self.customNavigationController;
//  navController.viewControllers = [NSArray arrayWithObject:siteListViewController];
//  [siteListViewController setModalPresentationStyle:UIModalPresentationCurrentContext];
//  [self presentModalViewController:navController animated:YES];
  DGCameraOverlayViewController *vc = [[DGCameraOverlayViewController alloc] initWithNibName:@"DGCameraOverlayViewController" bundle:nil];
  [self presentModalViewController:vc animated:YES];
}
- (UINavigationController*) customNavigationController
{
  UINavigationController *nav = [[[NSBundle mainBundle] loadNibNamed:@"DGCustomNormalNavBar" owner:self options:nil] objectAtIndex:0];
  nav.viewControllers = [NSArray arrayWithObject:siteListViewController];
  return nav;
}
- (void)dealloc
{
  [_detailViewController release];
  [siteListViewController release];
  [_objects release];
  [login release];
  [_backgroundView release];
  [_dgLogo release];
  [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  if( IS_IPHONE_5) {
    [self.backgroundView setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    [self.backgroundView setFrame:CGRectMake(0, -20, 320, 568)];
  }
}

- (void) showSites {
  UINavigationController  *navigationController = [[[UINavigationController alloc] initWithRootViewController:siteListViewController] autorelease];
  if([AppDelegate siteCount] == 1) {
    [siteListViewController setSelectedIndex:0];
    [siteListViewController setShouldSelectRow:YES];
  }
  if([AppDelegate siteCount] == 0) {
    [siteListViewController setAddSiteView:YES];
  }
  [siteListViewController setModalPresentationStyle:UIModalPresentationCurrentContext];
  [self presentModalViewController:navigationController animated:YES];
}
- (void) viewDidAppear:(BOOL)animated {
  [UIView animateWithDuration:0.5
                        delay:1
                      options: UIViewAnimationCurveEaseOut
                   animations:^{
                     _dgLogo.frame = CGRectMake(0, 96, 320, 89);
                   }
                   completion:^(BOOL finished){
                     [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(showSites)
                                                    userInfo:nil
                                                     repeats:NO];
                   }];

}
- (void)viewDidUnload
{
  [self setLogin:nil];
  [self setBackgroundView:nil];
  [self setDgLogo:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
//    }
//    [_objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
