//
//  DGAutocompleteCell.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/18/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGAutocompleteCell : UITableViewCell {
  UILabel *title;
  UIImageView *arrow;
  UIImageView *separator;
  NSIndexPath *indexPath;
  BOOL createdTag;
}
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UIImageView *arrow;
@property (nonatomic, retain) UIImageView *separator;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign)  BOOL createdTag;
- (void) layoutViews;
@end
