//
//  DGArticleListCustomCell.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGArticleListViewController.h"

@interface DGArticleListCustomCell : UITableViewCell {
  IBOutlet UILabel *timeLabel;
  IBOutlet UILabel *titleLabel;
  IBOutlet UILabel *bodyLabel;
  IBOutlet UIImageView *contentImg;
  IBOutlet UIView *selectionView;
  DGArticleListViewController *vc;
}
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *bodyLabel;
@property (nonatomic, retain) IBOutlet UIImageView *contentImg;
@property (nonatomic, retain) IBOutlet UIView *selectionView;
@property (nonatomic, retain) IBOutlet DGArticleListViewController *vc;
- (void)showSelection;
- (void)hideSelection;
- (IBAction)viewArticle:(id)sender;
- (IBAction)deleteArticle:(id)sender;
- (IBAction)shareArticle:(id)sender;
@end
