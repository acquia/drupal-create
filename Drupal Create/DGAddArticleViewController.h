//
//  DGAddArticleViewController.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGArticleListViewController.h"
#import "DGCustomPreviewWindow.h"

@class DGCustomSwitch, DGCameraOverlayViewController, DGCustomButton;
@interface DGAddArticleViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate> {
  NSString *articleSiteNid;
  UIImagePickerController *imgPicker;

  IBOutlet UIImageView *imagePreviewImageView;
  IBOutlet UIView *imagePreviewView;
  IBOutlet UIView *imagePreviewWhiteOverlay;
  IBOutlet UIView *imagePreviewWhiteOverlayThreeInch;
  IBOutlet UIImageView *imagePreviewImageViewThreeInch;
  IBOutlet UIView *imagePreviewViewThreeInch;
  UIImageView *border;
  UIImageView *largeImage;
  NSDictionary *fileData;
  UIViewController *imgVC;
  IBOutlet UIScrollView *multipleImageView;
  NSMutableDictionary *files;
  IBOutlet UIButton *addTagsButton;
  UIButton *postButton;
  NSDictionary *siteInfo;
  NSDictionary *siteFields;
  NSString *contentType;
  IBOutlet UIScrollView *mainScrollView;
  NSMutableArray *fieldsSorted;
  NSMutableArray *textViews;
  NSMutableArray *tagButtons;
  NSMutableArray *userButtons;
  NSMutableArray *usersData;
  NSMutableArray *tagData;
  NSMutableArray *requiredFieldNames;

  NSMutableDictionary *socialMediaViews;
  NSMutableDictionary *optionsForTags;
  NSMutableDictionary *selectedTags;
  NSMutableDictionary *createTags;
  NSMutableDictionary *nodeSubmissionData;
  NSMutableDictionary *primaryLabelsPerFields;
  NSMutableDictionary *secondaryLabelsPerFields;
  NSMutableDictionary *fieldsByKeys;
  NSString *currentFileKey;
  NSMutableArray *imageData;
  NSMutableArray *mediaFieldKeys;
  NSMutableArray *mediaFieldScrollViews;
  NSMutableArray *mediaFieldImages;
  NSMutableArray *socialMediaFields;
  id currentResponder;
  DGCustomSwitch *socialPublishOptionOne;
  DGCustomSwitch *socialPublishOptionTwo;
  DGCustomButton *camerIcon;
  DGCustomPreviewWindow *previewWindow;
  DGArticleListViewController *listViewController;
  DGCameraOverlayViewController *overlay;
  UIImageView *popover;
  UIButton *socialtoggle;
  CGPoint svos;
  int count;
  int offset;
  int tagCountTag;
  int usersCountTag;
  int imageCountTag;
  int currentMediaTag;
  int currentScrollViewTag;
  BOOL removeOldImage;
  BOOL socialPublishValue;
  BOOL addedSpace;
  UIButton *numberPadKeyboardDone;
}

@property (retain, nonatomic) NSString *articleSiteNid;
@property (nonatomic, retain) UIImagePickerController *imgPicker;
@property (nonatomic, retain) NSDictionary *fileData;
@property (nonatomic, retain) NSMutableDictionary *files;
@property (nonatomic, retain) DGCameraOverlayViewController *overlay;
@property (nonatomic, retain) DGArticleListViewController *listViewController;
@property (nonatomic, retain) NSDictionary *siteInfo;
@property (nonatomic, retain) NSDictionary *siteFields;
@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) NSString *machineName;
@property (nonatomic, retain) NSMutableArray *fieldsSorted;
@property (nonatomic, retain) NSMutableArray *textViews;
@property (nonatomic, retain) NSMutableArray *userButtons;
@property (nonatomic, retain) NSMutableArray *usersData;
@property (nonatomic, retain) NSMutableArray *tagButtons;
@property (nonatomic, retain) NSMutableArray *tagData;
@property (nonatomic, retain) NSMutableArray *imageData;
@property (nonatomic, retain) NSMutableArray *requiredFieldNames;
@property (nonatomic, retain) NSMutableArray *socialMediaFields;


@property (nonatomic, retain) NSMutableDictionary *socialMediaViews;
@property (nonatomic, retain) NSMutableDictionary *optionsForTags;
@property (nonatomic, retain) NSMutableDictionary *selectedTags;
@property (nonatomic, retain) NSMutableDictionary *createTags;
@property (nonatomic, retain) NSMutableDictionary *nodeSubmissionData;
@property (nonatomic, retain) NSMutableDictionary *fieldsByKeys;
@property (nonatomic, retain) NSString *currentFileKey;
@property (nonatomic, retain) NSMutableArray *mediaFieldKeys;
@property (nonatomic, retain) NSMutableDictionary *primaryLabelsPerFields;
@property (nonatomic, retain) NSMutableDictionary *secondaryLabelsPerFields;
@property (nonatomic, retain) NSMutableArray *mediaFieldScrollViews;
@property (nonatomic, retain) NSMutableArray *mediaFieldImages;
@property (nonatomic, assign) int currentMediaTag;
- (IBAction)removeImage:(id)sender;
- (IBAction)cancelImagePreview:(id)sender;

- (IBAction)addTags:(id)sender;
- (IBAction)postArticle:(id)sender;

- (void) createTagToSendWithNode:(NSString*)tagToAdd forField:(NSString*)fieldName withName:(NSString*)tagName;
- (void) removeCreateTagToSendWithNode:(NSString*)tagToRemove forField:(NSString*)fieldName tagName:(NSString*)tagName;
- (void) addTagToSendWithNode:(NSString*)tagToAdd forField:(NSString*)fieldName withName:(NSString*)tagName;
- (void) removeTagToSendWithNode:(NSString*)tagToRemove forField:(NSString*)fieldName tagName:(NSString*)tagName;
- (void)removeLastAddedTagForField:(NSString*)fieldName;
- (void)removeAllTagsForField:(NSString*)fieldName;
- (void) addUserName:(NSString*)userName forField:(NSString*)fieldName andKey:(NSString*)key;
@end
