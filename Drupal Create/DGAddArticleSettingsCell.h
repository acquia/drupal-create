//
//  DGAddArticleSettingsCell.h
//  Drupal Create
//
//  Created by Kyle Browning on 7/10/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGAddArticleSettingsCell : UITableViewCell {
  IBOutlet UILabel *rowName;
  IBOutlet UILabel *rowValue;
}
@property (nonatomic, retain) IBOutlet UILabel *rowName;
@property (nonatomic, retain) IBOutlet UILabel *rowValue;
@end
