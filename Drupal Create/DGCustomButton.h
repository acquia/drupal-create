//
//  DGCustomButton.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/23/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGCustomButton : UIButton {
  NSString *fieldKey;
  NSNumber *index;
}
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSString *fieldKey;
@end
