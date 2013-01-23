//
//  DGCameraOverlayViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 9/20/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGAddArticleViewController.h"
@class DGCameraOverlayViewController;
@class DGAddArticleViewController;
@interface DGCameraOverlayViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
  UIImagePickerController *pickerReference;
  DGAddArticleViewController *addArticleVC;
  UIViewController *imgVC;
  IBOutlet UIButton *showLibraryButton;
  IBOutlet UIImageView *cameraButtonView;
  IBOutlet UIButton *takePictureButton;
}
- (IBAction)cancel:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
- (IBAction)showLibrary:(id)sender;
@property (nonatomic, retain) UIImagePickerController *pickerReference;
@property (nonatomic, retain) DGAddArticleViewController *addArticleVC;
@end
