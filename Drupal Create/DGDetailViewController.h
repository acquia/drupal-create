//
//  DGDetailViewController.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
