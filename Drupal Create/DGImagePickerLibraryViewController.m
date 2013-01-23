//
//  DGImagePickerLibraryViewController.m
//  Drupal Create
//
//  Created by Kyle Browning on 7/18/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGImagePickerLibraryViewController.h"

@interface DGImagePickerLibraryViewController ()

@end

@implementation DGImagePickerLibraryViewController

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
  [self.navigationItem setTitle:@"test"];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Photo" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed:)];
  [self.navigationItem setRightBarButtonItem:btn];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
  UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Photo" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed:)];
  self.navigationItem.leftBarButtonItem = btn; // or rightBarButtonItem

  for (UIView *subview in self.view.subviews) {
    NSString *className = [NSString stringWithFormat:@"%@", [subview class]];
    if ([className isEqualToString:@"UINavigationBar"]) {
      //[[(UINavigationBar *)subview topItem] setRightBarButtonItem:btn];
    }
  }
    [btn release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
