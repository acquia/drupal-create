//
//  DGCustomNormalNavBar.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/21/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGCustomNormalNavBar.h"

@implementation DGCustomNormalNavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Set the navigation bar background
- (UIImage *)barBackground{
  return [UIImage imageNamed:@"title_bar_bkg.png"];
}

- (void)didMoveToSuperview{
  // Applies to iOS 5
  if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
    [self setBackgroundImage:[self barBackground] forBarMetrics:UIBarMetricsDefault];
  }
}

// This doesn't work on iOS5 but is needed for iOS4 and earlier
- (void)drawRect:(CGRect)rect
{
  // Draw the image
  [[self barBackground] drawInRect:rect];
}
@end
