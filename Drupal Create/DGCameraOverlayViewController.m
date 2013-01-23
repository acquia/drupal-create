//
//  DGCameraOverlayViewController.m
//  Drupal Create
//
//  Created by Kyle Browning on 9/20/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGCameraOverlayViewController.h"
#import "UIImage+orientationFix.h"
#import "DGAddArticleViewController.h"
#import "DGAppDelegate.h"
@interface DGCameraOverlayViewController ()

@end

@implementation DGCameraOverlayViewController
@synthesize pickerReference, addArticleVC;
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
[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    // Do any additional setup after loading the view from its nib.
  if (IS_IPHONE_5) {
    [cameraButtonView setImage:[UIImage imageNamed:@"iphone5_bottom_camera_bar.png"]];
    [cameraButtonView setFrame:CGRectMake(0, 382, 320, 98)];
    [self.view setFrame:CGRectMake(0, 0, 320, 548)];
    [takePictureButton setFrame:CGRectMake(110, 500, takePictureButton.frame.size.width, takePictureButton.frame.size.height)];
    [showLibraryButton setFrame:CGRectMake(10, 505, showLibraryButton.frame.size.width, showLibraryButton.frame.size.height)];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [cameraButtonView release];
  [takePictureButton release];
  [showLibraryButton release];
    [super dealloc];
}
- (void)viewDidUnload {

    [cameraButtonView release];
    cameraButtonView = nil;
  [takePictureButton release];
  takePictureButton = nil;
  [showLibraryButton release];
  showLibraryButton = nil;
    [super viewDidUnload];
  [pickerReference release];
  [addArticleVC release];
}
- (IBAction)cancel:(id)sender {
  [addArticleVC dismissModalViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
  [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
  cancelButton.frame = CGRectMake(cancelButton.frame.origin.x, cancelButton.frame.origin.y, 62.0, 30.0);
  [cancelButton setBackgroundImage:[UIImage imageNamed:@"secondary_btn.png"] forState:UIControlStateNormal];
  [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  //  [navigationController.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:cancelButton]];
  viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
  [cancelButton release];
  UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  [backButton setTitle:@"Back" forState:UIControlStateNormal];
  backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, 62.0, 30.0);
  [backButton setBackgroundImage:[UIImage imageNamed:@"toolbar_back_btn.png"] forState:UIControlStateNormal];
  [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  if(animated) {
    imgVC = viewController;
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton release];
  }
  UINavigationBar *bar = navigationController.navigationBar;
  [bar setHidden:NO];
}
- (void)back:(id)sender {
  [imgVC.navigationController popViewControllerAnimated:YES];
  imgVC.navigationItem.leftBarButtonItem = nil;
}

- (IBAction)cameraButtonTapped:(id)sender {
  [self.pickerReference takePicture];
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [addArticleVC imagePickerController:picker didFinishPickingMediaWithInfo:info];
}
- (IBAction)showLibrary:(id)sender {
  pickerReference.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;;
}
@end
