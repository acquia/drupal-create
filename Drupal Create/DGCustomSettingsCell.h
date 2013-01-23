//
//  DGCustomSettingsCell.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/28/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGCustomSettingsCell : UITableViewCell {
  UIImageView *sep;
  UILabel *cellText;
  UILabel *label;
  UIImageView *rightArrow;
}
@property (retain, nonatomic) UIImageView *sep;
@property (retain, nonatomic) UILabel *cellText;
@property (retain, nonatomic) UILabel *label;
@property (retain, nonatomic) UIImageView *rightArrow;
@end
