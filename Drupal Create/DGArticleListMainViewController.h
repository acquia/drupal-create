//
//  DGArticleListMainViewController.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGArticleListViewController.h"
@class DGArticleListViewController;
@interface DGArticleListMainViewController : UIViewController {
  NSString *siteNid;
  NSMutableDictionary *siteInfo;
  UIButton *addContentButton;
  UIImageView *addOneContentImage;
  UIImageView *addTwoContentImage;
  UIImageView *addThreeContentImage;
  UIImageView *addFourContentImage;
  UIImage *blogIconImage;
  UIImage *articleIconImage;
  UIImage *photoIconImage;
  UIButton *addButtonOne;
  UIButton *addButtonTwo;
  UIButton *addButtonThree;
  UIButton *addButtonFour;
  
  NSDictionary *fields;
  UIView *addContentView;
  int count;
  NSMutableArray *contentTypes;
  NSMutableArray *machineNames;
  NSString *selectedContentType;
  int appHeight;
}
@property (retain, nonatomic) IBOutlet DGArticleListViewController *tableViewController;
@property (nonatomic, retain) NSString *siteNid;
@property (nonatomic, retain) NSMutableDictionary *siteInfo;
@property (nonatomic, retain) NSDictionary *fields;
@property (nonatomic, retain) NSString *selectedContentType;
- (void) getFieldInfo;
- (void) hideAllContentButtons;
@end
