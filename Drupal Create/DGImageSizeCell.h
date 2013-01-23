//
//  DGImageSizeCell.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/28/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGImageSizeCell : UITableViewCell {
  UIImageView *sep;
  UIImageView *checkMark;
  UILabel *label;
}
@property (retain, nonatomic) UIImageView *sep;
@property (retain, nonatomic) UILabel *label;
@property (retain, nonatomic) UIImageView *checkMark;
@end
