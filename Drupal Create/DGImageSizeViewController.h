//
//  DGImageSizeViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/28/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGImageSizeViewController : UITableViewController {
  NSMutableArray *imageSizeOptions;
  NSDictionary *siteInfo;
}
@property (retain, nonatomic) IBOutlet UITableView *ImageSizeSettings;
@property (retain, nonatomic) NSMutableArray *imageSizeOptions;
@property (nonatomic, retain) NSDictionary *siteInfo;
@end
