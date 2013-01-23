//
//  DGCustomPreviewWindow.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/23/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGCustomPreviewWindow.h"
#import "DGAppDelegate.h"
@implementation DGCustomPreviewWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)makeKeyAndVisible
{
  self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
  self.alpha = 0;
  
  [UIView beginAnimations: @"fade-in" context: nil];
  
  [super makeKeyAndVisible];
  
  self.alpha = 1;
  
  [UIView commitAnimations];
}

- (void)resignKeyWindow
{
  self.alpha = 1;
  
  [UIView beginAnimations: @"fade-out" context: nil];
  
  [super resignKeyWindow];
  
  self.alpha = 0;
  
  [UIView commitAnimations];
  [[AppDelegate window] makeKeyAndVisible];
}
@end
