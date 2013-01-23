//
//  DGMainArticleListView.h
//  Drupal Create
//
//  Created by Kyle Browning on 8/23/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGArticleListMainViewController.h"
@interface DGMainArticleListView : UIView {
 IBOutlet DGArticleListMainViewController *mainVc;
}
@property (retain, nonatomic) IBOutlet DGArticleListMainViewController *mainVc;
@end
