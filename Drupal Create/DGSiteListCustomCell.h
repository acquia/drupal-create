//
//  DGSiteListCustomCell.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGSiteListCustomCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *siteLabel;
@property (retain, nonatomic) IBOutlet UIImageView *faviconImg;
@property (retain, nonatomic) IBOutlet UIView *dropShadow;
@property (retain, nonatomic) IBOutlet UIImageView *sep;
- (void) hideEverything;
- (void) showEverything;
@end
