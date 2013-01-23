//
//  DGAutocompleteCell.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGAutocompleteCell.h"

@implementation DGAutocompleteCell
@synthesize title, arrow, separator, indexPath, createdTag;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
      [arrow setBackgroundColor:[UIColor clearColor]];
      [arrow setHidden:YES];
      
      title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 280, 20)];
      [title setBackgroundColor:[UIColor clearColor]];
      
      separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_separator.png"]];
      [separator setFrame:CGRectMake(15, self.frame.size.height-2, 290, 1)];
      [separator setHidden:NO];
      [self addSubview:arrow];
      [self addSubview:title];
      [self addSubview:separator];
   }
    return self;
}

- (void) layoutViews {
//
//
//  [arrow setFrame:CGRectMake(280, 15, 18, 19)];
  if (indexPath.row == 0) {
    [title setFrame:CGRectMake(15, 0, 280, 30)];
    [separator setFrame:CGRectMake(15, 36, 290, 1)];
  } else {
    [title setFrame:CGRectMake(15, 0, 280, 44)];
  }
}
- (void) layoutSubviews {
  [super layoutSubviews];
  CGFloat height = 1.0f;
  [separator setFrame:CGRectMake(15, self.frame.size.height - height, 290, 1)];
  if (indexPath.row == 0) {
    [title setFrame:CGRectMake(15, 0, 280, self.frame.size.height-5)];
    [arrow setFrame:CGRectMake(280, 8, 18, 19)];
  } else {
    [title setFrame:CGRectMake(15, 0, 280, self.frame.size.height)];
    [arrow setFrame:CGRectMake(280, 14, 18, 19)];
  }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)prepareForReuse {
  [self.arrow setHidden:YES];
  [separator setHidden:NO];
  createdTag = NO;
}
@end
