//
//  DGAddTagsViewController.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/8/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGAddArticleViewController.h"
@interface DGAddTagsViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>{
 IBOutlet UITextField *searchField;
  NSDictionary *fieldInfo;
  NSString *contentType;
  NSDictionary *siteInfo;
  NSMutableArray *options;
  NSMutableArray *results;
  IBOutlet UITableView *resultsTableView;
  IBOutlet UITableView *optionsTableView;
  CGRect nonCreateTableViewFrame;
  NSMutableDictionary *selectedTags;
  NSMutableArray *oldOptions;
  NSMutableArray *searchresults;
  NSMutableDictionary *allTagKeys;
  NSMutableDictionary *originalTagsResponse;
  DGAddArticleViewController *addArticleViewController;
  NSString *lastAddedTag;
  int maxSelectCount;
  int selectedCount;
  IBOutlet UIButton *addTagButton;
  NSMutableArray *createdTags;
  IBOutlet UIView *searchFieldUIView;
}

@property (nonatomic, retain) NSString *siteURL;
@property (nonatomic, retain) NSMutableArray *createdTags;
@property (nonatomic, assign) int maxSelectCount;
@property (nonatomic, assign) int selectedCount;
@property (nonatomic, retain) NSString *bundle;
@property (nonatomic, retain) NSString *fieldName;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSDictionary *fieldInfo;
@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) NSDictionary *siteInfo;
@property (nonatomic, retain) NSMutableArray *options;
@property (nonatomic, retain) NSMutableDictionary *originalTagsResponse;
@property (nonatomic, retain) NSMutableDictionary *selectedTags;
@property (nonatomic, retain) NSMutableArray *oldOptions;
@property (nonatomic, retain) NSMutableArray *searchresults;
@property (nonatomic, retain) NSMutableDictionary *allTagKeys;
@property (nonatomic, retain) DGAddArticleViewController *addArticleViewController;

@end
