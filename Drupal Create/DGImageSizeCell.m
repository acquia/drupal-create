//
//  DGImageSizeCell.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/28/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGImageSizeCell.h"

@implementation DGImageSizeCell
@synthesize sep, checkMark, label;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_separator.png"]];
      [sep setFrame:CGRectMake(15, 44, 290, 1)];
      [self addSubview:sep];
      
      checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
      [checkMark setFrame:CGRectMake(280, 11, 19, 18)];
      [self addSubview:checkMark];
      [checkMark setHidden:YES];
      int y = 2;
      label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 250, 40)];
      [label setBackgroundColor:[UIColor clearColor]];

      [label setFont:[UIFont boldSystemFontOfSize:14.0]];
      [self addSubview:label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  if (selected) {
    //[checkMark setHidden:NO];
  } else {
//    [checkMark setHidden:YES];
  }
}

@end
