//
//  DGAddArticleSettingsViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 7/10/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGAddArticleSettingsViewController : UITableViewController <UITabBarControllerDelegate>{
  NSMutableArray *content;
}
@property (nonatomic, retain) NSMutableArray *content;
@end
