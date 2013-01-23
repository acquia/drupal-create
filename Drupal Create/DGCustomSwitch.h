//
//  DGCUstomSwitch.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/27/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGCustomSwitch : UISwitch {
  NSString *fieldKey;
}
@property (nonatomic, retain) NSString *fieldKey;
@end
