//
//  DGAddTagsListTableViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/8/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGAddTagsListTableViewController : UITableViewController {
  NSMutableArray *tags;
}
@property(nonatomic, retain) NSMutableArray *tags;
@end
