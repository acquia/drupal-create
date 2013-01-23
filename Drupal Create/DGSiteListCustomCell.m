//
//  DGSiteListCustomCell.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGSiteListCustomCell.h"
#import "UIImageView+WebCache.h"

@implementation DGSiteListCustomCell
@synthesize siteLabel;
@synthesize faviconImg;
@synthesize dropShadow;
@synthesize sep;

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
- (void)layoutSubviews
{
  [super layoutSubviews];
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationDuration:0.0f];
  
  for (UIView *subview in self.subviews) {
    
    
    if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
      CGRect newFrame = subview.frame;
      newFrame.origin.x = 235;
      subview.frame = newFrame;
    }
    else if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellEditControl"]) {
      CGRect newFrame = subview.frame;
      newFrame.origin.x = 10;
      subview.frame = newFrame;
    }
    else if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellReorderControl"]) {
      CGRect newFrame = subview.frame;
      newFrame.origin.x = 275;
      subview.frame = newFrame;
    }
  }
  [UIView commitAnimations];
}
//- (void)setFrame:(CGRect)frame {
//  //frame.origin.x += 30;
//  frame.size.width -= 2 * 20;
//  [super setFrame:frame];
//}
- (void) hideEverything {
  [siteLabel setHidden:YES];
  [faviconImg setHidden:YES];
  [dropShadow setHidden:YES];
}
- (void) showEverything {
  [siteLabel setHidden:NO];
  [faviconImg setHidden:NO];
  [dropShadow setHidden:NO];
}
- (void)dealloc {
  [siteLabel release];
  [faviconImg release];
  [dropShadow release];
  [sep release];
  [super dealloc];
}

@end
