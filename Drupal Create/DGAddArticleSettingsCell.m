//
//  DGAddArticleSettingsCell.m
//  Drupal Create
//
//  Created by Kyle Browning on 7/10/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGAddArticleSettingsCell.h"

@implementation DGAddArticleSettingsCell

@synthesize rowName;
@synthesize rowValue;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
