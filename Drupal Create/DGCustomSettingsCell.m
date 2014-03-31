//
//  DGCustomSettingsCell.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/28/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGCustomSettingsCell.h"
#import "DGAppDelegate.h"
@implementation DGCustomSettingsCell
@synthesize  sep, cellText, label, rightArrow;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_separator.png"]];
      [sep setFrame:CGRectMake(15, 44, 290, 1)];
      cellText = [[UILabel alloc] initWithFrame:CGRectMake(120, 3, 170, 40)];
      [cellText setTextAlignment:NSTextAlignmentRight];
      [cellText setBackgroundColor:[UIColor clearColor]];
      [cellText setFont:[UIFont systemFontOfSize:14.0]];
      [cellText setTextColor:[AppDelegate colorWithHexString:@"2389C1"]];
      label = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, 250, 40)];
      [label setBackgroundColor:[UIColor clearColor]];
      [label setFont:[UIFont boldSystemFontOfSize:14.0]];
      rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_arrow"]];
      [rightArrow setFrame:CGRectMake(295, 17, 9, 13)];
      [rightArrow setHidden:YES];
      [self addSubview:label];
      [self addSubview:cellText];
      [self addSubview:sep];
      [self addSubview:rightArrow];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
