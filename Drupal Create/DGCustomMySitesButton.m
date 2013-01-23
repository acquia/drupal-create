//
//  DGCustomMySitesButton.m
//  Drupal Create
//
//  Created by Kyle Browning on 7/18/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGCustomMySitesButton.h"

@implementation DGCustomMySitesButton

- (id)initWithText:(NSString *)text
{
	self = [DGCustomMySitesButton buttonWithType:UIButtonTypeCustom];
	[self setTitle:text forState:UIControlStateNormal];
	[self setFrame:CGRectMake(0, 0, 100, 100)];	
  return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];	
	UILabel *titleLabel = [self titleLabel];
	CGRect fr = [titleLabel frame];
	fr.origin.x = 12;
	fr.origin.y = 8;
	[[self titleLabel] setFrame:fr];
}

@end