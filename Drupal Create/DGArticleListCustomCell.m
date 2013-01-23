//
//  DGArticleListCustomCell.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGArticleListCustomCell.h"
#import "DGAppDelegate.h"
@implementation DGArticleListCustomCell

@synthesize contentImg;
@synthesize bodyLabel;
@synthesize timeLabel;
@synthesize titleLabel;
@synthesize selectionView;
@synthesize vc;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      // Initialization code
      contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(40, 40, 30, 30)];
      [contentImg setBackgroundColor:[UIColor redColor]];
      [self addSubview:contentImg];
      [self setSelectionStyle:UITableViewCellEditingStyleNone];
//      self.contentImg.layer.masksToBounds = YES;
//      self.contentImg.layer.cornerRadius = 3.0f;
      
    }
    return self;
}
-(void)showSelection {
  [selectionView setHidden:NO];
}

-(void)hideSelection {
  [selectionView setHidden:YES];
}
- (IBAction)viewArticle:(id)sender {
  [vc showArticle];
}

- (IBAction)deleteArticle:(id)sender {
  [vc showDeleteDialog];
}

- (IBAction)shareArticle:(id)sender {
  [vc showShareDialog];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [self setSelectionStyle:UITableViewCellEditingStyleNone];
  [super setSelected:selected animated:animated];
  if (selected) {
    [self setBackgroundColor:[AppDelegate colorWithHexString:@"619dcf"]];
    [bodyLabel setTextColor:[UIColor whiteColor]];
    [timeLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
  } else {
    [self setBackgroundColor:[UIColor clearColor]];
    [bodyLabel setTextColor:[UIColor blackColor]];
    [timeLabel setTextColor:[UIColor blackColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
  }


    // Configure the view for the selected state
}

- (void)dealloc {
  [contentImg release];
  [bodyLabel release];
  [timeLabel release];
  [titleLabel release];
  [selectionView release];
  [vc release];
  [super dealloc];
}
@end
