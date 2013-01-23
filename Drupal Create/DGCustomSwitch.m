//
//  DGCUstomSwitch.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/27/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGCustomSwitch.h"

@implementation DGCustomSwitch
@synthesize fieldKey;
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

-(void)dealloc {
  [super dealloc];
  [fieldKey release];
  fieldKey = nil;
}
@end
