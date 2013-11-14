//
//  DGAddArticleViewController.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGAddArticleViewController.h"
#import "DGDClient.h"
#import "DIOSFile.h"
#import "DGAddArticleSettingsViewController.h"
#import "DGAppDelegate.h"
#import "DGImagePickerLibraryViewController.h"
#import "UIImage+Scale.h"
#import "DGAddTagsViewController.h"
#import "UIImage+orientationFix.h"
#import "DGCustomButton.h"
#import "DGCustomSwitch.h"
#import "DGAuthorPickerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DGCameraOverlayViewController.h"
#import "UIPlaceHolderTextView.h"
@interface DGAddArticleViewController ()

@end

@implementation DGAddArticleViewController
@synthesize articleSiteNid;
@synthesize imgPicker;
@synthesize fileData;
@synthesize files;
@synthesize listViewController;
@synthesize siteInfo;
@synthesize siteFields;
@synthesize contentType;
@synthesize tagData, tagButtons, fieldsSorted, textViews, selectedTags, createTags, nodeSubmissionData, mediaFieldKeys, currentFileKey, secondaryLabelsPerFields, imageData, mediaFieldScrollViews, userButtons, overlay;
@synthesize mediaFieldImages, fieldsByKeys, optionsForTags, usersData, requiredFieldNames, machineName, primaryLabelsPerFields, socialMediaFields;
@synthesize socialMediaViews, currentMediaTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  //Create our Post Button for posting content
  postButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [postButton addTarget:self action:@selector(postArticle:) forControlEvents:UIControlEventTouchUpInside];
  [postButton setTitle:@"Post" forState:UIControlStateNormal];
  postButton.frame = CGRectMake(postButton.frame.origin.x, postButton.frame.origin.y, 62.0, 30.0);
  [postButton setBackgroundImage:[UIImage imageNamed:@"content_type_btn.png"] forState:UIControlStateNormal];
  [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [postButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:postButton]];
  [postButton setEnabled:YES];

  //Create our cancel button.
  UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
  [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
  cancelButton.frame = CGRectMake(cancelButton.frame.origin.x, cancelButton.frame.origin.y, 62.0, 30.0);
  [cancelButton setBackgroundImage:[UIImage imageNamed:@"secondary_btn.png"] forState:UIControlStateNormal];
  [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
  [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease]];

  //Add our toolbars to the view
  [self makeToolBars];
 
  
  //Define our initial arrays with blank data
  textViews = [NSMutableArray new];
  tagButtons = [NSMutableArray new];
  usersData = [NSMutableArray new];
  tagData = [NSMutableArray new];
  imageData = [NSMutableArray new];
  mediaFieldKeys = [NSMutableArray new];
  mediaFieldScrollViews = [NSMutableArray new];
  mediaFieldImages = [NSMutableArray new];
  requiredFieldNames = [NSMutableArray new];
  socialMediaFields = [NSMutableArray new];
  fieldsSorted = [NSMutableArray new];
  
  //Define our initial blank values for our Dictionary Data
  socialMediaViews = [NSMutableDictionary new];
  files = [NSMutableDictionary new];
  optionsForTags = [NSMutableDictionary new];
  selectedTags = [NSMutableDictionary new];
  createTags = [NSMutableDictionary new];
  nodeSubmissionData = [NSMutableDictionary new];
  secondaryLabelsPerFields = [NSMutableDictionary new];
  primaryLabelsPerFields = [NSMutableDictionary new];
  fieldsByKeys = [NSMutableDictionary new];


  count = 0;
  offset = 0;
  tagCountTag = 0;
  usersCountTag = 0;

  //Build our site fields data with machine names.
  for (NSString *field in siteFields) {
    for (NSString *aContentType in [siteFields objectForKey:field]) {
      if ([aContentType isEqualToString:machineName]) {
        [self setSiteFields:[[[siteFields objectForKey:field] objectForKey:machineName] objectForKey:@"fields"]];
      }
    }
  }
  //Loop through and clean up the array structure to have key=>values and use the name for the key
  for (NSString *field in siteFields) {
    NSMutableDictionary *aField = [[NSMutableDictionary alloc] initWithDictionary:[siteFields objectForKey:field]];
    if ([[aField objectForKey:@"type"] isEqualToString:@"social_publish_toggle"]) {
      [aField setObject:[NSNumber numberWithInt:999] forKey:@"weight"];
    }
    [aField setObject:field forKey:@"name"];
    [fieldsSorted addObject:aField];
    [aField release];
  }

  //Our Tap recognizer so that 
  UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePopover)];
  tapped.numberOfTapsRequired = 1;
  tapped.cancelsTouchesInView = NO;
  [mainScrollView addGestureRecognizer:tapped];

  //Memory Cleanup
  [tapped release];
  NSSortDescriptor * descriptor =
  [NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES comparator: ^NSComparisonResult(id obj1, id obj2) {
    int v1 = [obj1 intValue];
    int v2 = [obj2 intValue];
    if (v1 < v2)
      return NSOrderedAscending;
    else if (v1 > v2)
      return NSOrderedDescending;
    else
      return NSOrderedSame;
   }];

  NSArray *tempSortedArray = [fieldsSorted sortedArrayUsingDescriptors: [NSArray arrayWithObject: descriptor]];
  [self setFieldsSorted:[NSMutableArray arrayWithArray:tempSortedArray]];
  
  NSEnumerator *e = [fieldsSorted objectEnumerator];
  id object;
  while (object = [e nextObject]) {
    UIView *fieldView = [self getViewForFieldType:object];
    [mainScrollView addSubview:fieldView];
    [fieldView release];
    count++;
  }
  [mainScrollView setUserInteractionEnabled:YES];
  [mainScrollView bringSubviewToFront:popover];

    // Do any additional setup after loading the view from its nib.
  if ([contentType isEqualToString:@""] || contentType == nil) {
    [self setTitle:machineName];
  } else {
    [self setTitle:contentType];
  }

}
- (void)hidePopover {
  [popover setHidden:YES];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
  svos = mainScrollView.contentOffset;
  CGPoint pt;
  CGRect rc = [textField bounds];
  [popover setHidden:YES];
    currentResponder = textField;
  rc = [textField convertRect:rc toView:mainScrollView];
  if(rc.origin.y <= 50) {
    return;
  }
  pt = rc.origin;
  pt.x = 0;
  pt.y -= 60;
  [mainScrollView setContentOffset:pt animated:YES];
  if(!addedSpace) {
    CGSize size = [mainScrollView contentSize];
    size.height += 200;
    [mainScrollView setContentSize:size];
    addedSpace = YES;
  }
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
  svos = mainScrollView.contentOffset;
  currentResponder = textView;
  [popover setHidden:YES];
  CGPoint pt;
  CGRect rc = [textView bounds];
  rc = [textView convertRect:rc toView:mainScrollView];
  pt = rc.origin;
  pt.x = 0;
  pt.y -= 10;
  [mainScrollView setContentOffset:pt animated:YES];

}
- (void) updateFieldDisplayForTags:(UILabel*)label {
  
}
- (void)textViewDidEndEditing:(UITextView *)textView {
  [mainScrollView setContentOffset:svos animated:YES];
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
  if(addedSpace) {
    CGSize size = [mainScrollView contentSize];
    size.height -= 200;
    [mainScrollView setContentSize:size];
    addedSpace = NO;
  }
  [mainScrollView setContentOffset:svos animated:YES];
  [textField resignFirstResponder];
  return YES;
}

- (UIView*)getViewForFieldType:(NSMutableDictionary*)fieldData {
  [fieldData setObject:[[NSMutableArray new] autorelease] forKey:@"images"];
  [fieldData setObject:[[NSMutableArray new] autorelease] forKey:@"buttons"];
  [fieldData setObject:[[NSMutableArray new] autorelease] forKey:@"files"];
  UIView *fieldView = [[UIView alloc] initWithFrame:CGRectZero];
  NSDictionary *defaultValue = [fieldData objectForKey:@"default"];
  if ([[fieldData objectForKey:@"type"] isEqualToString:@"text"]) {
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 295, 30)];
    [textField setUserInteractionEnabled:YES];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_title_bkg.png"]];
    [textField setEnabled:YES];
    [fieldView setFrame:CGRectMake(0, offset, 300, 50)];
    NSString *requiredText = @"";
    if ([[fieldData objectForKey:@"required"] boolValue]) {
      [requiredFieldNames addObject:[fieldData objectForKey:@"name"]];
      requiredText = @"*";
    }
    [textField setPlaceholder:[NSString stringWithFormat:@"%@%@", [fieldData objectForKey:@"label"], requiredText]];
    [fieldView addSubview:imageView];
    [fieldView addSubview:textField];
    [fieldView bringSubviewToFront:textField];
    [textField setReturnKeyType:UIReturnKeyDone];
    [fieldData setObject:textField forKey:@"object"];
    if (![[defaultValue objectForKey:@"value"] isEqualToString:@""]) {
      [textField setText:[defaultValue objectForKey:@"value"]];
    } else {
      [textField setText:[defaultValue objectForKey:@"key"]];
    }
    [nodeSubmissionData setObject:textField forKey:[fieldData objectForKey:@"name"]];
    offset = offset + 50;
    [textField setDelegate:self];
    [textField release];
    [imageView release];
  } else if ([[fieldData objectForKey:@"type"] isEqualToString:@"number_integer"]) {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 295, 30)];
    [textField setUserInteractionEnabled:YES];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_title_bkg.png"]];
    [textField setEnabled:YES];
    [fieldView setFrame:CGRectMake(0, offset, 300, 50)];
    NSString *requiredText = @"";
    if ([[fieldData objectForKey:@"required"] boolValue]) {
      [requiredFieldNames addObject:[fieldData objectForKey:@"name"]];
      requiredText = @"*";
    }
    [textViews addObject:textField];
    [self makeToolBars];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setPlaceholder:[NSString stringWithFormat:@"%@%@", [fieldData objectForKey:@"label"], requiredText]];
    [fieldView addSubview:imageView];
    [fieldView addSubview:textField];
    [fieldView bringSubviewToFront:textField];
    [fieldData setObject:textField forKey:@"object"];
    if (![[defaultValue objectForKey:@"value"] isEqualToString:@""]) {
      [textField setText:[defaultValue objectForKey:@"value"]];
    } else {
      [textField setText:[defaultValue objectForKey:@"key"]];
    }
    [nodeSubmissionData setObject:textField forKey:[fieldData objectForKey:@"name"]];
    offset = offset + 50;
    [textField setDelegate:self];
    [textField release];
    [imageView release];
  } else if ([[fieldData objectForKey:@"type"] isEqualToString:@"number_float"]) {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 295, 30)];
    [textField setUserInteractionEnabled:YES];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_title_bkg.png"]];
    [textField setEnabled:YES];
    [fieldView setFrame:CGRectMake(0, offset, 300, 50)];
    NSString *requiredText = @"";
    if ([[fieldData objectForKey:@"required"] boolValue]) {
      [requiredFieldNames addObject:[fieldData objectForKey:@"name"]];
      requiredText = @"*";
    }
    [textViews addObject:textField];
    [self makeToolBars];
    [textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setPlaceholder:[NSString stringWithFormat:@"%@%@", [fieldData objectForKey:@"label"], requiredText]];
    [fieldView addSubview:imageView];
    [fieldView addSubview:textField];
    [fieldView bringSubviewToFront:textField];
    [fieldData setObject:textField forKey:@"object"];
    if (![[defaultValue objectForKey:@"value"] isEqualToString:@""]) {
      [textField setText:[defaultValue objectForKey:@"value"]];
    } else {
      [textField setText:[defaultValue objectForKey:@"key"]];
    }
    [nodeSubmissionData setObject:textField forKey:[fieldData objectForKey:@"name"]];
    offset = offset + 50;
    [textField setDelegate:self];
    [textField release];
    [imageView release];
  }  else if ([[fieldData objectForKey:@"type"] isEqualToString:@"number_decimal"]) {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 295, 30)];
    [textField setUserInteractionEnabled:YES];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_title_bkg.png"]];
    [textField setEnabled:YES];
    [fieldView setFrame:CGRectMake(0, offset, 300, 50)];
    NSString *requiredText = @"";
    if ([[fieldData objectForKey:@"required"] boolValue]) {
      [requiredFieldNames addObject:[fieldData objectForKey:@"name"]];
      requiredText = @"*";
    }
    [textViews addObject:textField];
    [self makeToolBars];
    [textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setPlaceholder:[NSString stringWithFormat:@"%@%@", [fieldData objectForKey:@"label"], requiredText]];
    [fieldView addSubview:imageView];
    [fieldView addSubview:textField];
    [fieldView bringSubviewToFront:textField];
    [fieldData setObject:textField forKey:@"object"];
    if (![[defaultValue objectForKey:@"value"] isEqualToString:@""]) {
      [textField setText:[defaultValue objectForKey:@"value"]];
    } else {
      [textField setText:[defaultValue objectForKey:@"key"]];
    }
    [nodeSubmissionData setObject:textField forKey:[fieldData objectForKey:@"name"]];
    offset = offset + 50;
    [textField setDelegate:self];
    [textField release];
    [imageView release];
  } else if ([[fieldData objectForKey:@"type"] isEqualToString:@"user_reference"]) {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normal_field_bkg.png"]];
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_arrow.png"]];
    [arrow setFrame:CGRectMake(290, 15, 9, 13)];
    [imageView setFrame:CGRectMake(8, 0, imageView.frame.size.width, imageView.frame.size.height)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13, 1, 100, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont boldSystemFontOfSize:12.0]];
    [label setTextColor:[UIColor grayColor]];
    [label setText:[fieldData objectForKey:@"label"]];
    UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 20, 280, 20)];
    [secondaryLabel setBackgroundColor:[UIColor clearColor]];
    [secondaryLabel setFont:[UIFont systemFontOfSize:11.0]];
    [secondaryLabel setTextColor:[UIColor grayColor]];
    NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
    NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
    NSMutableDictionary *authorData = [cache objectForKey:authorDataKey];
    if(authorData != nil) {
      [secondaryLabel setText:[authorData objectForKey:@"value"]];
    } else  {
      [secondaryLabel setText:[[fieldData objectForKey:@"default"]  objectForKey:@"value"]];
    }
    [secondaryLabelsPerFields setObject:secondaryLabel forKey:[fieldData objectForKey:@"name"]];
    UIButton *userButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, 320, 40)];
    [userButton addTarget:self action:@selector(showUsers:) forControlEvents:UIControlEventTouchUpInside];
    [userButtons addObject:userButton];
    [usersData addObject:fieldData];
    usersCountTag++;
    [userButton setTag:usersCountTag];
    [userButton setBackgroundColor:[UIColor clearColor]];
    [fieldView addSubview:imageView];
    [fieldView addSubview:label];
    [fieldView addSubview:userButton];
    [fieldView addSubview:arrow];
    [fieldView addSubview:secondaryLabel];
    [fieldData setObject:userButton forKey:@"object"];
    [fieldView setFrame:CGRectMake(0, offset+5, 300, 50)];
    [nodeSubmissionData setObject:[[NSMutableDictionary new] autorelease] forKey:[fieldData objectForKey:@"name"]];
    offset = offset + 50;

  } else if ([[fieldData objectForKey:@"type"] isEqualToString:@"text_with_summary"]) {
    UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(8, 8, 308, 160)];
    [textView setDelegate:self];
    [textView setBackgroundColor:[UIColor clearColor]];
    NSString *requiredText = @"";
    if ([[fieldData objectForKey:@"required"] boolValue]) {
      [requiredFieldNames addObject:[fieldData objectForKey:@"name"]];
      requiredText = @"*";
    }
    [textView setPlaceholder:[NSString stringWithFormat:@"%@%@", [fieldData objectForKey:@"label"], requiredText]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_body_bkg.png"]];
    [imageView setFrame:CGRectMake(0, -5, imageView.frame.size.width, imageView.frame.size.height)];
    [textView setReturnKeyType:UIReturnKeyDefault];
    [fieldView setFrame:CGRectMake(0, offset, 300, 180)];
    if (![[defaultValue objectForKey:@"value"] isEqualToString:@""]) {
      [textView setText:[defaultValue objectForKey:@"value"]];
    }
    
    [textView setFont:[UIFont systemFontOfSize:16.0]];
    [textViews addObject:textView];
    [fieldView addSubview:imageView];
    [fieldView addSubview:textView];
    [fieldData setObject:textView forKey:@"object"];
    [nodeSubmissionData setObject:textView forKey:[fieldData objectForKey:@"name"]];
    [textView release];
    [imageView release];
    offset = offset + 188 - 5;
    [self makeToolBars];
  } else if ([[fieldData objectForKey:@"type"] isEqualToString:@"taxonomy_term_reference"] || [[fieldData objectForKey:@"type"] isEqualToString:@"list_text"] || [[fieldData objectForKey:@"type"] isEqualToString:@"list_integer"] || [[fieldData objectForKey:@"type"] isEqualToString:@"list_float"]) {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normal_field_bkg.png"]];
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_arrow.png"]];
    [arrow setFrame:CGRectMake(290, 20, 9, 13)];
    [imageView setFrame:CGRectMake(8, 5, imageView.frame.size.width, imageView.frame.size.height)];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13, 2, 100, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 300, 50)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont boldSystemFontOfSize:12.0]];
    [label setTextColor:[UIColor grayColor]];
    [label setText:[fieldData objectForKey:@"label"]];
    NSString *requiredText = @"";
    if ([[fieldData objectForKey:@"required"] boolValue]) {
      [requiredFieldNames addObject:[fieldData objectForKey:@"name"]];
      requiredText = @"*";
    }
    [label setText:[NSString stringWithFormat:@"%@%@", [fieldData objectForKey:@"label"], requiredText]];
    [primaryLabelsPerFields setObject:label forKey:[fieldData objectForKey:@"name"]];

    UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 20, 280, 30)];
    [secondaryLabel setBackgroundColor:[UIColor clearColor]];
    [secondaryLabel setFont:[UIFont systemFontOfSize:11.0]];
    [secondaryLabel setTextColor:[UIColor grayColor]];
    [secondaryLabelsPerFields setObject:secondaryLabel forKey:[fieldData objectForKey:@"name"]];
    UIButton *tagsbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, 320, 40)];
    [tagsbutton addTarget:self action:@selector(showTags:) forControlEvents:UIControlEventTouchUpInside];
    [tagButtons addObject:tagsbutton];
    [tagsbutton setBackgroundColor:[UIColor clearColor]];
    [fieldView addSubview:imageView];
    [fieldView addSubview:label];
    [fieldView addSubview:tagsbutton];
    [fieldView addSubview:arrow];
    [fieldView addSubview:secondaryLabel];
    [fieldData setObject:tagsbutton forKey:@"object"];
    [fieldView setFrame:CGRectMake(0, offset, 300, 50)];
    [nodeSubmissionData setObject:[[NSMutableArray new] autorelease] forKey:[fieldData objectForKey:@"name"]];
    tagCountTag++;
    [tagsbutton setTag:tagCountTag];
    [selectedTags setObject:[NSMutableArray new] forKey:[fieldData objectForKey:@"name"]];
    [createTags setObject:[NSMutableArray new] forKey:[fieldData objectForKey:@"name"]];
    [tagData addObject:fieldData];
    offset = offset + 50;
    NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
    NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
    NSString *fieldInfoKey = [[NSString stringWithFormat:@"%@%@", machineName, [fieldData objectForKey:@"name"]] MD5];
    NSMutableDictionary *content = [cache objectForKey:fieldInfoKey];
    NSString *fieldExpire = [NSString stringWithFormat:@"%@%@", [fieldData objectForKey:@"name"], expireOptionsTimestampKey];
    if (content == nil || [AppDelegate isCacheOutOfDate:contentCachekey expiryKey:fieldExpire expireTime:300]) {
      [DGDClient getOptions:[siteInfo objectForKey:siteURLKey]
               accessTokens:[siteInfo objectForKey:siteAccessTokens]
                     bundle:machineName
                  fieldName:[fieldData objectForKey:@"name"]
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSDictionary *dict = [responseObject objectForKey:@"values"];
                      NSMutableDictionary *allTagKeys = [[NSMutableDictionary alloc] initWithDictionary:dict];
                      [optionsForTags setObject:allTagKeys forKey:[fieldData objectForKey:@"name"]];
                      [cache setObject:allTagKeys forKey:fieldInfoKey];
                      [AppDelegate saveCache:cache ForKey:contentCachekey expireKey:fieldExpire];
                      if ([[optionsForTags objectForKey:[fieldData objectForKey:@"name"]] objectForKey:[defaultValue objectForKey:@"key"]]) {
                        [self addTagToSendWithNode:[defaultValue objectForKey:@"key"] forField:[fieldData objectForKey:@"name"] withName:[[optionsForTags objectForKey:[fieldData objectForKey:@"name"]] objectForKey:[defaultValue objectForKey:@"key"]]];
                      }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (operation.response.statusCode == CONTENT_TYPE_ERROR_CODE) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DrupalCreateContentTypesChanged" object:nil];
                        NSString *text = [NSString stringWithFormat:@"%@ is disabled, reloading settings...", contentType];
                        [[AppDelegate customStatusBar] showWithStatusMessage:text hide:NO];
                        [[AppDelegate customStatusBar] hide:3.0f];
                      }
                    }
       ];
    } else {
      NSMutableDictionary *allTagKeys = [[NSMutableDictionary alloc] initWithDictionary:content];
      [optionsForTags setObject:allTagKeys forKey:[fieldData objectForKey:@"name"]];
      if ([[optionsForTags objectForKey:[fieldData objectForKey:@"name"]] objectForKey:[defaultValue objectForKey:@"key"]]) {
        [self addTagToSendWithNode:[defaultValue objectForKey:@"key"] forField:[fieldData objectForKey:@"name"] withName:[[optionsForTags objectForKey:[fieldData objectForKey:@"name"]] objectForKey:[defaultValue objectForKey:@"key"]]];
      }
    }
    [fieldData release];
    [imageView release];
    [arrow release];
    [secondaryLabel release];
    [tagsbutton release];
    [label release];
    
  } else if ([[fieldData objectForKey:@"type"] isEqualToString:@"image"] || [[fieldData objectForKey:@"type"] isEqualToString:@"media"] || [[fieldData objectForKey:@"type"] isEqualToString:@"file"]) {
    DGCustomButton *addImageButton = [[DGCustomButton alloc] initWithFrame:CGRectMake(8, 5, 302, 229)];
    [addImageButton setFieldKey:[fieldData objectForKey:@"name"]];
    [addImageButton setImage:[UIImage imageNamed:@"media_field_empty.png"] forState:UIControlStateNormal];
    [addImageButton addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
    [fieldView setFrame:CGRectMake(0, offset, 320, addImageButton.frame.size.height + 100)];
    imageCountTag++;
    [fieldData setObject:addImageButton forKey:@"object"];
    [addImageButton setTag:imageCountTag];
    [[fieldData objectForKey:@"buttons"] addObject:addImageButton];
    [mediaFieldKeys addObject:[fieldData objectForKey:@"name"]];
    [fieldView addSubview:addImageButton];
    [nodeSubmissionData setObject:[NSMutableArray new] forKey:[fieldData objectForKey:@"name"]];
    offset = offset + 229;
    NSString *cardinality = [fieldData valueForKey:@"cardinality"];
    UIImageView *filmStripRow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"media_field_multiple.png"]];
    [filmStripRow setFrame:CGRectMake(0, 229+5, 319, 59)];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 240, 300, 50)];
    if ([cardinality integerValue] >= 2) {
      offset = offset + 60;
      [fieldView addSubview:filmStripRow];
      [fieldView addSubview:scrollView];
      [fieldView bringSubviewToFront:scrollView];
      [mediaFieldScrollViews addObject:scrollView];
    } else {
      //we add a blank object always so that we can consistantly find the UIScrollView we need to attach to
      [mediaFieldScrollViews addObject:@""];
            offset = offset + 10;
    }
    if ([[fieldData objectForKey:@"required"] boolValue]) {
      [requiredFieldNames addObject:[fieldData objectForKey:@"name"]];
    }
    [addImageButton release];
    [filmStripRow release];
  } else if ([[fieldData objectForKey:@"type"] isEqualToString:@"social_publish_toggle"]) {
    if ([self countofSocialPublishFields] == 2 && [socialMediaFields count] == 1) {
      UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normal_field_bkg.png"]];
      UIButton *aSocialToggle = [[UIButton alloc] initWithFrame:CGRectMake(260, 0, 44, 41)];
      NSDictionary *defaults = [fieldData objectForKey:@"default"];
      NSDictionary *secondDefault = [[socialMediaFields objectAtIndex:0] objectForKey:@"default"];
      UILabel *yourNetworks = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 100, 10)];
      [yourNetworks setBackgroundColor:[UIColor clearColor]];
      [yourNetworks setFont:[UIFont systemFontOfSize:10.0]];
      [yourNetworks setText:[fieldData objectForKey:@"label"]];
      [yourNetworks setTextColor:[UIColor grayColor]];
      UILabel *secondNetworks = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 10)];
      [secondNetworks setBackgroundColor:[UIColor clearColor]];
      [secondNetworks setFont:[UIFont systemFontOfSize:10.0]];
      [secondNetworks setText:[[socialMediaFields objectAtIndex:0] objectForKey:@"label"]];
      [secondNetworks setTextColor:[UIColor grayColor]];
      if ([[defaults allValues] containsObject:@"On"] || [[secondDefault allValues] containsObject:@"On"]) {
        socialPublishValue = YES;
        [aSocialToggle setImage:[UIImage imageNamed:@"share_button_on.png"] forState:UIControlStateNormal];
      } else {
        socialPublishValue = NO;
        [aSocialToggle setImage:[UIImage imageNamed:@"share_button_off.png"] forState:UIControlStateNormal];
      }
      NSNumber *socialPublishNumber = [[NSNumber alloc] initWithBool:socialPublishValue];
      [nodeSubmissionData setObject:socialPublishNumber forKey:[fieldData objectForKey:@"name"]];
      [aSocialToggle addTarget:self action:@selector(socialPublishShowPopover:) forControlEvents:UIControlEventTouchUpInside];
      [fieldView addSubview:imageView];
      [fieldView addSubview:aSocialToggle];
      [fieldView addSubview:yourNetworks];
      [fieldView addSubview:secondNetworks];

      NSArray *options = [[fieldData objectForKey:@"options"] objectForKey:@"icons"];
      int socialIconOffset = 0;
      for (NSString *icon in options) {
        UIImageView *socialIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
        [socialIcon setFrame:CGRectMake(100+socialIconOffset, 18, 21, 21)];
        socialIconOffset += 21 + 5;
        [fieldView addSubview:socialIcon];
      }

      NSArray *firstOptions = [[[socialMediaFields objectAtIndex:0] objectForKey:@"options"] objectForKey:@"icons"];
      socialIconOffset = 0;
      for (NSString *icon in firstOptions) {
        UIImageView *socialIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
        [socialIcon setFrame:CGRectMake(5+socialIconOffset, 18, 21, 21)];
        socialIconOffset += 21 + 5;
        [fieldView addSubview:socialIcon];
      }
      [fieldView setFrame:CGRectMake(8, offset +5, 300, 50)];

      [self setupPopoverViewWithField:fieldData buildSecondData:YES withOffset:offset];
      offset = offset + 50;

    } else {
      if ([self countofSocialPublishFields] != 2) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normal_field_bkg.png"]];
        socialtoggle = [[UIButton alloc] initWithFrame:CGRectMake(260, 0, 44, 41)];
        NSDictionary *defaults = [fieldData objectForKey:@"default"];
        UILabel *yourNetworks = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 10)];
        [yourNetworks setBackgroundColor:[UIColor clearColor]];
        [yourNetworks setFont:[UIFont systemFontOfSize:10.0]];
        [yourNetworks setText:[fieldData objectForKey:@"label"]];
        [yourNetworks setTextColor:[UIColor grayColor]];
        if ([[defaults allValues] containsObject:@"On"]) {
          socialPublishValue = YES;
          [socialtoggle setImage:[UIImage imageNamed:@"share_button_on.png"] forState:UIControlStateNormal];
        } else {
          socialPublishValue = NO;
          [socialtoggle setImage:[UIImage imageNamed:@"share_button_off.png"] forState:UIControlStateNormal];
        }
        NSNumber *socialPublishNumber = [[NSNumber alloc] initWithBool:socialPublishValue];
        [nodeSubmissionData setObject:socialPublishNumber forKey:[fieldData objectForKey:@"name"]];
        [socialtoggle addTarget:self action:@selector(socialPublishShowPopover:) forControlEvents:UIControlEventTouchUpInside];
        [fieldView addSubview:imageView];
        [fieldView addSubview:socialtoggle];
        [fieldView addSubview:yourNetworks];
        NSArray *options = [[fieldData objectForKey:@"options"] objectForKey:@"icons"];
        int socialIconOffset = 0;
        for (NSString *icon in options) {
          UIImageView *socialIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
          [socialIcon setFrame:CGRectMake(5+socialIconOffset, 18, 21, 21)];
          socialIconOffset += 21 + 5;
          [fieldView addSubview:socialIcon];
        }
        [fieldView setFrame:CGRectMake(8, offset +5, 300, 50)];

        [self setupPopoverViewWithField:fieldData buildSecondData:NO withOffset:offset];
        offset = offset + 50;
      }
    }
    [socialMediaFields addObject:fieldData];
    [socialMediaViews setObject:fieldView forKey:[fieldData objectForKey:@"name"]];
  } else if ([[fieldData objectForKey:@"type"] isEqualToString:@"list_boolean"]) {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normal_field_bkg.png"]];
    DGCustomSwitch *toggle = [[DGCustomSwitch alloc] initWithFrame:CGRectMake(220, 8, 44, 41)];
    [toggle addTarget:self action:@selector(listBooleanToggle:) forControlEvents:UIControlEventTouchUpInside];
    [toggle setFieldKey:[fieldData objectForKey:@"name"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7, 10, 100, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont boldSystemFontOfSize:12.0]];
    [label setText:[fieldData objectForKey:@"label"]];
    NSString *requiredText = @"";
    if ([[fieldData objectForKey:@"required"] boolValue]) {
      [requiredFieldNames addObject:[fieldData objectForKey:@"name"]];
      requiredText = @"*";
    }
    [label setText:[NSString stringWithFormat:@"%@%@", [fieldData objectForKey:@"label"], requiredText]];

    [label setTextColor:[UIColor grayColor]];
    NSDictionary *defaults = [fieldData objectForKey:@"default"];
    if ([[defaults allValues] containsObject:@"No"]) {
      [toggle setOn:NO];
      [nodeSubmissionData setObject:@"0" forKey:[fieldData objectForKey:@"name"]];
    } else {
      [toggle setOn:YES];
      [nodeSubmissionData setObject:@"1" forKey:[fieldData objectForKey:@"name"]];
    }
    [fieldView addSubview:imageView];
    [fieldView addSubview:label];
    [fieldView addSubview:toggle];
    [fieldView setFrame:CGRectMake(8, offset+5, 300, 50)];
    offset = offset + 50;
  }
  [mainScrollView setContentSize:CGSizeMake(320, offset+50)];
  [fieldView setUserInteractionEnabled:YES];
  [fieldView sizeToFit];

  [fieldsByKeys setObject:fieldData forKey:[fieldData objectForKey:@"name"]];
  return fieldView;
}

- (void) showCamera:(id)sender {
  [currentResponder resignFirstResponder];
  NSDictionary *field = [fieldsByKeys objectForKey:currentFileKey];
  NSMutableArray *arrayOfFiles = [nodeSubmissionData objectForKey:currentFileKey];
  NSString *stringInt = [NSString stringWithFormat:@"%d", [arrayOfFiles count]];
  if([[field objectForKey:@"cardinality"] integerValue] != 1) {
    if([[field objectForKey:@"cardinality"] isEqualToString:stringInt]) {
      [[AppDelegate customStatusBar] showWithStatusMessage:@"You have reached the limit for this field." hide:YES];
      return;
    }
  }
  if (self.imgPicker != nil) {
    [self.imgPicker release];
  }
  self.imgPicker = [[UIImagePickerController alloc] init];
  self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  self.imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
  self.imgPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
  self.imgPicker.showsCameraControls = NO;
  self.imgPicker.navigationBarHidden = NO;
  self.imgPicker.toolbarHidden = YES;
  currentMediaTag = [[sender index] integerValue];
  currentFileKey = [sender fieldKey];
  self.overlay = [[DGCameraOverlayViewController alloc] initWithNibName:@"DGCameraOverlayViewController" bundle:nil];
  self.overlay.pickerReference = self.imgPicker;
  self.imgPicker.cameraOverlayView = self.overlay.view;
  self.imgPicker.delegate = self.overlay;
  [self.overlay setAddArticleVC:self];

  [self presentViewController:self.imgPicker animated:NO completion:nil];
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void) listBooleanToggle:(id)sender {
  if([sender isOn]) {
    [nodeSubmissionData setObject:@"1" forKey:[sender fieldKey]];
  } else {

    [nodeSubmissionData setObject:@"0" forKey:[sender fieldKey]];
  }
  if ([socialMediaFields count] >= 1) {
    if (socialPublishOptionOne.isOn || socialPublishOptionTwo.isOn) {
        [socialtoggle setImage:[UIImage imageNamed:@"share_button_on.png"] forState:UIControlStateNormal];
      } else {
        [socialtoggle setImage:[UIImage imageNamed:@"share_button_off.png"] forState:UIControlStateNormal];
    }
  }
}

- (void)socialPublishShowPopover:(id)sender {
  if (popover.hidden == YES) {
    popover.hidden = NO;
  } else {
    popover.hidden = YES;
  }
}
- (void)socialPublishToggle:(id)sender {
  if(socialPublishValue) {
    socialPublishValue = NO;
    [sender setImage:[UIImage imageNamed:@"slider_off.png"] forState:UIControlStateNormal];
  } else {
    socialPublishValue = YES;
    [sender setImage:[UIImage imageNamed:@"slider_on.png"] forState:UIControlStateNormal];
  }
  NSNumber *socialPublishNumber = [[NSNumber alloc] initWithBool:socialPublishValue];
  [nodeSubmissionData setObject:socialPublishNumber forKey:@"rpx_user_publish"];
}

- (int) countofSocialPublishFields {
  int socialPublishCount = 0;
  for (NSString *key in siteFields) {
    NSDictionary *fieldData = [siteFields objectForKey:key];
    if ([[fieldData objectForKey:@"type"] isEqualToString:@"social_publish_toggle"]) {
      socialPublishCount++;
    }
  }
  return socialPublishCount;
}
- (void)setupPopoverViewWithField:(NSDictionary *)fieldData buildSecondData:(BOOL)buildSecondData withOffset:(int)anOffset{
  popover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popover_bkg.png"]];
  //      [popover setFrame:CGRectMake(8, -73, popover.frame.size.width, popover.frame.size.height)];
  [popover setFrame:CGRectMake(8, anOffset-172, popover.frame.size.width, popover.frame.size.height)];

  UILabel *popoverLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 300, 30)];
  [popoverLabel setBackgroundColor:[UIColor clearColor]];
  [popoverLabel setText:@"Share With Social Networks"];
  [popoverLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
  [popoverLabel setTextColor:[UIColor whiteColor]];
  [popover addSubview:popoverLabel];


  UILabel *yourNetworks = [[UILabel alloc] initWithFrame:CGRectMake(20, 105, 200, 10)];
  [yourNetworks setBackgroundColor:[UIColor clearColor]];
  [yourNetworks setFont:[UIFont systemFontOfSize:13.0]];
  if (buildSecondData) {
    [yourNetworks setText:[[socialMediaFields objectAtIndex:0] objectForKey:@"label"]];
  }
  [yourNetworks setTextColor:[UIColor blackColor]];
  [popover addSubview:yourNetworks];


  UILabel *secondNetworks = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 200, 10)];

  if (!buildSecondData) {
    [secondNetworks setFrame:CGRectMake(20, 80, 200, 10)];
  }
  [secondNetworks setBackgroundColor:[UIColor clearColor]];
  [secondNetworks setFont:[UIFont systemFontOfSize:13.0]];

  [secondNetworks setText:[fieldData objectForKey:@"label"]];
  [secondNetworks setTextColor:[UIColor blackColor]];
  [popover addSubview:secondNetworks];

  socialPublishOptionOne = [[DGCustomSwitch alloc] initWithFrame:CGRectMake(210, 60, 50, 50)];
    if (!buildSecondData) {
      [socialPublishOptionOne setFrame:CGRectMake(210, 80, 50, 50)];
    }
  [socialPublishOptionOne setFieldKey:[fieldData objectForKey:@"name"]];
  [socialPublishOptionOne addTarget:self action:@selector(listBooleanToggle:) forControlEvents:UIControlEventTouchUpInside];
  [popover addSubview:socialPublishOptionOne];
  socialPublishOptionTwo = [[DGCustomSwitch alloc] initWithFrame:CGRectMake(210, 110, 50, 50)];
  if (buildSecondData) {
    [socialPublishOptionTwo addTarget:self action:@selector(listBooleanToggle:) forControlEvents:UIControlEventTouchUpInside];
    [socialPublishOptionTwo setFieldKey:[[socialMediaFields objectAtIndex:0] objectForKey:@"name"]];
    [popover addSubview:socialPublishOptionTwo];
  }
  NSDictionary *defaults = [fieldData objectForKey:@"default"];
  if ([[defaults allValues] containsObject:@"On"]) {
    [socialPublishOptionOne setOn:YES];
  } else {
    [socialPublishOptionOne setOn:NO];
  }
  [self listBooleanToggle:socialPublishOptionOne];
  if (buildSecondData) {
    NSDictionary *secondDefaults = [[socialMediaFields objectAtIndex:0] objectForKey:@"default"];
    if ([[secondDefaults allValues] containsObject:@"On"]) {
      [socialPublishOptionTwo setOn:YES];
    } else {
      [socialPublishOptionTwo setOn:NO];
    }
      [self listBooleanToggle:socialPublishOptionTwo];
  }

  int socialIconOffset = 0;
  if (buildSecondData) {
    NSArray *options = [[[socialMediaFields objectAtIndex:0] objectForKey:@"options"] objectForKey:@"icons"];
    for (NSString *icon in options) {
      UIImageView *socialIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
      [socialIcon setFrame:CGRectMake(20+socialIconOffset, 125, 21, 21)];
      socialIconOffset += 21 + 5;
      [popover addSubview:socialIcon];
    }
  }

  NSArray *secondOptions = [[fieldData objectForKey:@"options"] objectForKey:@"icons"];
  socialIconOffset = 0;
  for (NSString *icon in secondOptions) {
    UIImageView *socialIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    [socialIcon setFrame:CGRectMake(20+socialIconOffset, 70, 21, 21)];
    if (!buildSecondData) {
      [socialIcon setFrame:CGRectMake(20+socialIconOffset, 95, 21, 21)];
    }
    socialIconOffset += 21 + 5;
    [popover addSubview:socialIcon];

  }
  [popover setHidden:YES];
  [popover setUserInteractionEnabled:YES];
  [mainScrollView addSubview:popover];
}
#pragma mark -
#pragma mark User related stuff

- (void)showUsers:(id)sender {
  [popover setHidden:YES];
    [currentResponder resignFirstResponder];
  int tag = [sender tag];
  NSDictionary *fieldInfo = [usersData objectAtIndex:tag-1];
  NSString *fieldName = [fieldInfo objectForKey:@"name"];
  DGAuthorPickerViewController *vc = [[DGAuthorPickerViewController alloc] initWithNibName:@"DGAuthorPickerViewController" bundle:nil];
  [vc setAddArticleViewController:self];
  [vc setFieldInfo:fieldInfo];
  NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  NSMutableDictionary *savedAuthorData = [cache objectForKey:authorDataKey];
  if (savedAuthorData != nil) {
    [vc setDefaultAuthor:savedAuthorData];
  } else {
    [cache setObject:[fieldInfo objectForKey:@"default"] forKey:authorDataKey];
    [AppDelegate saveCache:cache ForKey:contentCachekey];
    [vc setDefaultAuthor:[fieldInfo objectForKey:@"default"]];
  }

  if ([[nodeSubmissionData objectForKey:fieldName] objectForKey:@"value"] != nil) {
    [vc setDefaultAuthor:[nodeSubmissionData objectForKey:fieldName]];
  }

  NSMutableDictionary *optionsForAuthor = [cache objectForKey:authorOptions];
  if(optionsForAuthor == nil  || [AppDelegate isCacheOutOfDate:authorOptions expiryKey:expireAuthorTimestampKey expireTime:300]) {
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:machineName, fieldName, @"100", nil]
                                                         forKeys:[NSArray arrayWithObjects:@"bundle", @"field_name", @"count", nil]];
    [DGDClient getOptions:[siteInfo objectForKey:siteURLKey] accessTokens:[siteInfo objectForKey:siteAccessTokens] bundle:machineName params:params fieldName:fieldName success:^(AFHTTPRequestOperation *operation, id responseObject) {

      [vc setOptions:[responseObject objectForKey:@"values"]];
      NSMutableDictionary *oldOptions = [NSMutableDictionary dictionaryWithDictionary:[responseObject objectForKey:@"values"]];
      [vc setOldOptions:oldOptions];
      [cache setObject:[responseObject objectForKey:@"values"] forKey:authorOptions];
      [AppDelegate saveCache:cache ForKey:contentCachekey expireKey:expireAuthorTimestampKey];
      [self.navigationController pushViewController:vc animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      if (operation.response.statusCode == CONTENT_TYPE_ERROR_CODE) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DrupalCreateContentTypesChanged" object:nil];
        NSString *text = [NSString stringWithFormat:@"%@ is disabled, reloading settings...", contentType];
        [[AppDelegate customStatusBar] showWithStatusMessage:text hide:NO];
        [[AppDelegate customStatusBar] hide:3.0f];
      }
    }];
  } else {
    [vc setOptions:optionsForAuthor];
    NSMutableDictionary *oldOptions = [NSMutableDictionary dictionaryWithDictionary:optionsForAuthor];
    [vc setOldOptions:oldOptions];
    [self.navigationController pushViewController:vc animated:YES];
  }

}

- (void)buildUserForField:(NSString*)fieldName withUserName:(NSString*)userName {
  UILabel *secondaryLabel = [secondaryLabelsPerFields objectForKey:fieldName];
  [secondaryLabel setText:userName];
}
- (void) addUserName:(NSString*)userName forField:(NSString*)fieldName andKey:(NSString*)key {
  NSMutableDictionary *dict = [NSMutableDictionary new];
  [dict setObject:userName forKey:@"value"];
  [dict setObject:key forKey:@"key"];
  [nodeSubmissionData setObject:dict forKey:fieldName];
  [dict release];
  [self buildUserForField:fieldName withUserName:userName];
}

#pragma mark -
#pragma mark Tag related stuff
- (IBAction)addTags:(id)sender {
  DGAddTagsViewController *vc = [[DGAddTagsViewController alloc] initWithNibName:@"DGAddTagsViewController" bundle:nil];
  UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:navVC animated:YES completion:nil];
  [vc release];
  [navVC release];
}

- (void)showTags:(id)sender {
  int tag = [sender tag];
    [popover setHidden:YES];
  [currentResponder resignFirstResponder];
  NSDictionary *fieldInfo = [tagData objectAtIndex:tag-1];
  DGAddTagsViewController *vc = [[DGAddTagsViewController alloc] initWithNibName:@"DGAddTagsViewController" bundle:nil];
  [vc setFieldInfo:fieldInfo];
  [vc setSiteInfo:siteInfo];
  [vc setSelectedTags:selectedTags];
  [vc setAddArticleViewController:self];
  [vc setContentType:machineName];
  NSMutableArray *selectedCreateTags = [NSMutableArray arrayWithArray:[createTags objectForKey:[fieldInfo objectForKey:@"name"]]];
  [vc setCreatedTags:selectedCreateTags];
  [self.navigationController pushViewController:vc animated:YES];
  [vc release];
}
- (void)removeLastAddedTagForField:(NSString*)fieldName {
  NSMutableArray *tags = [nodeSubmissionData objectForKey:fieldName];
  [tags removeLastObject];
  NSMutableArray *tagNames = [selectedTags objectForKey:fieldName];
  [tagNames removeLastObject];
  [self buildTagForField:fieldName];
}
- (void)removeAllTagsForField:(NSString*)fieldName {
  NSMutableArray *tags = [nodeSubmissionData objectForKey:fieldName];
  [tags removeAllObjects];
  NSMutableArray *tagNames = [selectedTags objectForKey:fieldName];
  [tagNames removeAllObjects];
  [self buildTagForField:fieldName];
}
- (void)buildTagForField:(NSString*)fieldName {
  UILabel *secondaryLabel = [secondaryLabelsPerFields objectForKey:fieldName];
  NSMutableArray *tagNames = [selectedTags objectForKey:fieldName];
  NSString *labelText = [tagNames componentsJoinedByString:@", "];
  [secondaryLabel setText:labelText];
}

- (void) createTagToSendWithNode:(NSString*)tagToAdd forField:(NSString*)fieldName withName:(NSString*)tagName {
  NSMutableArray *tags = [nodeSubmissionData objectForKey:fieldName];
  NSMutableArray *createdTags = [createTags objectForKey:fieldName];
  NSUInteger objIdx = [tags indexOfObject: tagToAdd];
  if (objIdx != NSNotFound) {
    return;
  }
  objIdx = 0;
  objIdx = [createdTags indexOfObject: tagToAdd];
  if (objIdx != NSNotFound) {
    return;
  }
  [tags addObject:tagToAdd];
  [createdTags addObject:tagToAdd];
  [nodeSubmissionData setObject:tags forKey:fieldName];
  NSMutableArray *tagNames = [selectedTags objectForKey:fieldName];
  [tagNames addObject:tagName];
  UILabel *tagLabel = [primaryLabelsPerFields objectForKey:fieldName];
  [tagLabel setFrame:CGRectMake(13, 2, 100, 30)];
  [self buildTagForField:fieldName];
}

- (void) addTagToSendWithNode:(NSString*)tagToAdd forField:(NSString*)fieldName withName:(NSString*)tagName {
  NSMutableArray *tags = [nodeSubmissionData objectForKey:fieldName];
  NSUInteger objIdx = [tags indexOfObject: tagToAdd];
  if (objIdx != NSNotFound) {
    return;
  }
  [tags addObject:tagToAdd];
  [nodeSubmissionData setObject:tags forKey:fieldName];
  NSMutableArray *tagNames = [selectedTags objectForKey:fieldName];
  [tagNames addObject:tagName];
  UILabel *tagLabel = [primaryLabelsPerFields objectForKey:fieldName];
  [tagLabel setFrame:CGRectMake(13, 2, 100, 30)];
  [self buildTagForField:fieldName];
}

- (void) removeTagToSendWithNode:(NSString*)tagToRemove forField:(NSString*)fieldName tagName:(NSString*)tagName {
  NSMutableArray *tags = [nodeSubmissionData objectForKey:fieldName];
  [tags removeObject:tagToRemove];
  if ([tags count] == 0) {
    UILabel *tagLabel = [primaryLabelsPerFields objectForKey:fieldName];
    [tagLabel setFrame:CGRectMake(13, 0, 300, 50)];
  }
  NSMutableArray *tagNames = [selectedTags objectForKey:fieldName];
  [tagNames removeObject:tagName];
  [self buildTagForField:fieldName];
}

- (void) removeCreateTagToSendWithNode:(NSString*)tagToRemove forField:(NSString*)fieldName tagName:(NSString*)tagName {
  NSMutableArray *tags = [nodeSubmissionData objectForKey:fieldName];
  [tags removeObject:tagToRemove];
  NSMutableArray *tagNames = [selectedTags objectForKey:fieldName];
  [tagNames removeObject:tagName];
  NSMutableArray *createdTagNames = [createTags objectForKey:fieldName];
  [createdTagNames removeObject:tagName];
  [self buildTagForField:fieldName];
}

- (void)cancel:(id)sender {
  [[AppDelegate customStatusBar] hide:0.0f];
  [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark -
# pragma mark image related methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [self dismissViewControllerAnimated:YES completion:nil];
  if ([[[fieldsByKeys objectForKey:currentFileKey] objectForKey:@"cardinality"] isEqualToString:@"1"]) {
    [self removeImage:self];
  }
  UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
  img = [img fixOrientation];
  [postButton setEnabled:NO];
  [[AppDelegate customStatusBar] showWithStatusMessage:@"Uploading..." showLoadingIndicator:YES];
  picker = nil;
  NSString *contentCachekey = [[siteInfo objectForKey:siteURLKey] MD5];
  NSMutableDictionary *cache = [AppDelegate getCachedData:contentCachekey];
  NSString *imageSize = [cache objectForKey:imageSizeKey];
  
  NSData *imgData;
  if([imageSize isEqualToString:@"0"]) {
    imgData = UIImageJPEGRepresentation(img, 0.2);
  } else if ([imageSize isEqualToString:@"1"]) {
    imgData = UIImageJPEGRepresentation(img, 0.5);
  } else if ([imageSize isEqualToString:@"2"]) {
    imgData = UIImageJPEGRepresentation(img, 0.8);
  } else {
    imgData = UIImageJPEGRepresentation(img, 0.7);
  }
  
  NSMutableDictionary *file = [[NSMutableDictionary alloc] init];
  [file setObject:imgData forKey:@"file"];
  
	NSString *timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
  NSString *imageTitle = @"test";//[[articleTitle text] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
  if ([imageTitle isEqualToString:@""]) {
    imageTitle = @"temp";
  }
  NSString *filePath = [NSString stringWithFormat:@"%@%@.jpg",@"public://", imageTitle];
  NSString *fileName = [NSString stringWithFormat:@"%@.jpg", imageTitle];
  [file setObject:filePath forKey:@"filepath"];
  [file setObject:fileName forKey:@"filename"];
  [file setObject:timestamp forKey:@"timestamp"];
  NSString *fileSize = [NSString stringWithFormat:@"%d", [imgData length]];
  [file setObject:fileSize forKey:@"filesize"];
  [file setObject:machineName forKey:@"bundle"];
  [file setObject:currentFileKey forKey:@"field_name"];
  [DGDClient uploadFileWithURL:[siteInfo objectForKey:siteURLKey] params:file accessTokens:[siteInfo objectForKey:siteAccessTokens] success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString *text = [NSString stringWithFormat:@"Successfully uploaded picture."];
    [[[AppDelegate customStatusBar] statusLabel] setText:text];
    [file setObject:[responseObject objectForKey:@"fid"] forKey:@"fid"];
    [file removeObjectForKey:@"file"];
    [file setObject:img forKey:@"image"];
    [self setFileData:file];
    [self addFileToFiles:file forKey:currentFileKey];
    [file release];
    [[AppDelegate customStatusBar] hide];
    [postButton setEnabled:YES];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSString *text = [NSString stringWithFormat:@"Failed to POST:%d", operation.response.statusCode];
    [[[AppDelegate customStatusBar] statusLabel] setText:text];
    [[AppDelegate customStatusBar] hide];
    [postButton setEnabled:YES];
    if (operation.response.statusCode == CONTENT_TYPE_ERROR_CODE) {
      [self dismissViewControllerAnimated:YES completion:nil];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DrupalCreateContentTypesChanged" object:nil];
      NSString *text = [NSString stringWithFormat:@"%@ is disabled, reloading settings...", contentType];
      [[AppDelegate customStatusBar] showWithStatusMessage:text hide:NO];
      [[AppDelegate customStatusBar] hide:3.0f];
    }
  }];

}

-(void)addFileToFiles:(NSDictionary*)file forKey:(NSString*)key {
  NSMutableArray *arrayOfFiles = [nodeSubmissionData objectForKey:key];

  NSMutableDictionary *dict = [fieldsByKeys objectForKey:key];
  NSMutableArray *images = [dict objectForKey:@"images"];
  NSMutableArray *buttons = [dict objectForKey:@"buttons"];
  NSMutableArray *fieldFiles = [dict objectForKey:@"files"];

  [fieldFiles addObject:file];
  [images addObject:[file objectForKey:@"image"]];
  DGCustomButton *imageButton = [buttons objectAtIndex:currentMediaTag];
  [self setCurrentMediaTag:[arrayOfFiles count]];
  UIImage *image = [[[fieldsByKeys objectForKey:key] objectForKey:@"images"] objectAtIndex:currentMediaTag];
  if (largeImage != nil) {
    [largeImage setImage:image];
  } else {
    largeImage = [[UIImageView alloc] initWithImage:image];
  }
  if (currentMediaTag == 0) {
    border = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"media_field_border.png"]];
    
    largeImage.contentMode = UIViewContentModeScaleAspectFill;
    [largeImage setFrame:CGRectMake(0, 0, imageButton.frame.size.width, imageButton.frame.size.height)];
    [border setFrame:CGRectMake(0, 0, imageButton.frame.size.width, imageButton.frame.size.height)];
    [imageData addObject:imageButton];
    camerIcon = [[DGCustomButton alloc] initWithFrame:CGRectMake(257, 2, 43, 43)];
    [camerIcon setImage:[UIImage imageNamed:@"media_field_camera.png"] forState:UIControlStateNormal];
    [camerIcon setTag:currentMediaTag];
    [camerIcon setIndex:[NSNumber numberWithInt:currentMediaTag]];
    [camerIcon setFieldKey:key];
    [imageButton setTag:currentMediaTag];
    NSNumber *newNumber = [NSNumber numberWithInt:currentMediaTag];
    [imageButton setIndex:newNumber];
    [camerIcon addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
    [imageButton removeTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
    [imageButton addTarget:self action:@selector(showImagePreview:) forControlEvents:UIControlEventTouchUpInside];
    [imageButton addSubview:camerIcon];

    [imageButton setImage:nil forState:UIControlStateNormal];
    [imageButton addSubview:border];
    [imageButton addSubview:largeImage];
    [imageButton bringSubviewToFront:camerIcon];
    [imageButton bringSubviewToFront:largeImage];
    [imageButton bringSubviewToFront:border];
    [camerIcon release];
    CALayer * l = [largeImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    [border release];
    //[largeImage release];
  }
  
  [arrayOfFiles addObject:[file objectForKey:@"fid"]];

  DGCustomButton *imageView = [[DGCustomButton alloc] initWithFrame:CGRectMake(0, 5, 35, 35)];
  [imageView setFieldKey:key];
  DGCustomButton *tempButton = [imageData objectAtIndex:0];
  NSNumber *newNumber = [NSNumber numberWithInt:currentMediaTag];
  [tempButton setIndex:newNumber];
  [tempButton setTag:currentMediaTag];
  [imageView setIndex:newNumber];
  [imageView setTag:currentMediaTag];
  [imageView setImage:image forState:UIControlStateNormal];
  [imageView addTarget:self action:@selector(changeLargeImage:) forControlEvents:UIControlEventTouchUpInside];
  [buttons addObject:imageView];
  int padding = 5;
  if([arrayOfFiles count] == 1) {
    padding = 0;
  } else {
    padding = (([arrayOfFiles count] - 1) * 35) + (([arrayOfFiles count] - 1) * 5);
  }

  [imageView setFrame:CGRectMake(5 + padding, 7, 35, 35)];
  multipleImageView = [mediaFieldScrollViews objectAtIndex:0];
  if ([multipleImageView isKindOfClass:[UIImageView class]]) {

    [multipleImageView addSubview:imageView];
    [multipleImageView setHidden:NO];
    [multipleImageView setScrollEnabled:YES];
    [multipleImageView setPagingEnabled:YES];
    [multipleImageView setContentSize:CGSizeMake(padding+50, [multipleImageView bounds].size.height)];
  }
  if(currentMediaTag != 0) {
    [imageData addObject:imageView];
  }

  [imageView release];
  [self reorderImages:key];
}
- (void) reorderImages:(NSString*)key {
  NSMutableDictionary *dict = [fieldsByKeys objectForKey:key];
  NSMutableArray *buttons = [dict objectForKey:@"buttons"];
  int padding = 5;
  int aCount = 1;
  for (int i = [buttons count]-1; i>0; i--) {
    DGCustomButton *button = [buttons objectAtIndex:i];
    padding = ((aCount - 1) * 35) + ((aCount - 1) * 5);
    [button setFrame:CGRectMake(5 + padding, 7, 35, 35)];
    aCount++;
  }
}
- (void) changeLargeImage:(id)sender {
  currentMediaTag = [[sender index] integerValue];
  currentFileKey = [sender fieldKey];
  //load our Main Image to update its tags
  DGCustomButton *tempButton = [imageData objectAtIndex:0];
  NSDictionary *field = [fieldsByKeys objectForKey:currentFileKey];
  NSMutableArray *images = [field objectForKey:@"images"];
  [largeImage setImage:[images objectAtIndex:currentMediaTag]];
  NSNumber *newNumber = [NSNumber numberWithInt:currentMediaTag];
  [tempButton setIndex:newNumber];
  [tempButton setTag:currentMediaTag];
}
- (CGPoint)getTargetPointForImageView:(UIImageView*)imageView {
  CGPoint targetPoint = imageView.frame.origin;
  CGSize  targetSize  = imageView.bounds.size;
  CGSize  sourceSize = imageView.image.size;
  CGFloat ratioX = targetSize.width / sourceSize.width;
  CGFloat ratioY = targetSize.height / sourceSize.height;

  if (imageView.contentMode == UIViewContentModeScaleToFill) {
    targetPoint.x *= ratioX;
    targetPoint.y *= ratioY;
  }
  else if(imageView.contentMode == UIViewContentModeScaleAspectFit) {
    CGFloat scale = MIN(ratioX, ratioY);

    targetPoint.x *= scale;
    targetPoint.y *= scale;

    targetPoint.x += (imageView.frame.size.width - sourceSize.width * scale) / 2.0f;
    targetPoint.y += (imageView.frame.size.height - sourceSize.height * scale) / 2.0f;
  }
  else if(imageView.contentMode == UIViewContentModeScaleAspectFill) {
    CGFloat scale = MAX(ratioX, ratioY);

    targetPoint.x *= scale;
    targetPoint.y *= scale;

    targetPoint.x += (imageView.frame.size.width - sourceSize.width * scale) / 2.0f;
    targetPoint.y += (imageView.frame.size.height - sourceSize.height * scale) / 2.0f;
  }

  return targetPoint;
}
- (void)showImagePreview:(id)sender {
    [popover setHidden:YES];
    [currentResponder resignFirstResponder];
  currentMediaTag = [[sender index] integerValue];
  currentFileKey = [sender fieldKey];
  previewWindow = [[DGCustomPreviewWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  previewWindow.windowLevel = UIWindowLevelStatusBar;
  previewWindow.hidden = NO;
  previewWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1];
  if (IS_IPHONE_5) {
    [previewWindow addSubview:imagePreviewView];
    [previewWindow makeKeyAndVisible];
    UIImage *image = [[[fieldsByKeys objectForKey:[sender fieldKey]] objectForKey:@"images"] objectAtIndex:[[sender index] integerValue]];
    [imagePreviewImageView setImage:image];
    imagePreviewImageView.contentMode = UIViewContentModeScaleAspectFit;

    CGFloat sx = imagePreviewImageView.frame.size.width / imagePreviewImageView.image.size.width;
    CGFloat sy = imagePreviewImageView.frame.size.height / imagePreviewImageView.image.size.height;
    CGSize temp =  CGSizeMake(sx, sy);

    CGFloat width = temp.width * imagePreviewImageView.image.size.width;
    CGFloat height = temp.width * imagePreviewImageView.image.size.height;
    CGPoint tempPoint = [self getTargetPointForImageView:imagePreviewImageView];
    imagePreviewWhiteOverlay.layer.cornerRadius = 5;
    imagePreviewWhiteOverlay.layer.masksToBounds = YES;
    [imagePreviewWhiteOverlay setFrame:CGRectMake(tempPoint.x+13, tempPoint.y+13, width +10, height+10)];
  } else {
    [previewWindow addSubview:imagePreviewViewThreeInch];
    [previewWindow makeKeyAndVisible];
    UIImage *image = [[[fieldsByKeys objectForKey:[sender fieldKey]] objectForKey:@"images"] objectAtIndex:[[sender index] integerValue]];
    [imagePreviewImageViewThreeInch setImage:image];
    imagePreviewImageViewThreeInch.contentMode = UIViewContentModeScaleAspectFit;

    CGFloat sx = imagePreviewImageViewThreeInch.frame.size.width / imagePreviewImageViewThreeInch.image.size.width;
    CGFloat sy = imagePreviewImageViewThreeInch.frame.size.height / imagePreviewImageViewThreeInch.image.size.height;
    CGSize temp =  CGSizeMake(sx, sy);

    CGFloat width = temp.width * imagePreviewImageViewThreeInch.image.size.width;
    CGFloat height = temp.width * imagePreviewImageViewThreeInch.image.size.height;
    CGPoint tempPoint = [self getTargetPointForImageView:imagePreviewImageViewThreeInch];
    imagePreviewWhiteOverlayThreeInch.layer.cornerRadius = 5;
    imagePreviewWhiteOverlayThreeInch.layer.masksToBounds = YES;
    [imagePreviewWhiteOverlayThreeInch setFrame:CGRectMake(tempPoint.x+13, tempPoint.y+13, width +10, height+10)];
  }

}

- (IBAction)removeImage:(id)sender {
  NSDictionary *field = [fieldsByKeys objectForKey:currentFileKey];
  DGCustomButton *imageButton = [field objectForKey:@"object"];
  NSInteger index = currentMediaTag;
  NSMutableArray *arrayOfFiles = [nodeSubmissionData objectForKey:[imageButton fieldKey]];
  if([arrayOfFiles count] == 0) {
    return;
  }
  NSMutableArray *images = [field objectForKey:@"images"];
  NSMutableArray *buttons = [field objectForKey:@"buttons"];
  NSMutableArray *fieldFiles = [field objectForKey:@"files"];
  [arrayOfFiles removeObjectAtIndex:index];
  [images removeObjectAtIndex:index];
  [fieldFiles removeObjectAtIndex:index];
  
  if (index != 0) {
    [[imageData objectAtIndex:index] removeFromSuperview];
    [buttons removeObjectAtIndex:index];
  }
  NSMutableArray *tempFiles = [[NSMutableArray alloc] initWithArray:fieldFiles];
  NSMutableArray *tempButtons = [[NSMutableArray alloc] initWithArray:buttons];
  [arrayOfFiles removeAllObjects];
  [images removeAllObjects];
  [fieldFiles removeAllObjects];

  int buttonCount = 0;
  for (DGCustomButton *aButton in tempButtons) {
    if (buttonCount == 0) {
      [imageButton removeTarget:self action:@selector(showImagePreview:) forControlEvents:UIControlEventTouchUpInside];
      [aButton addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
      [camerIcon removeFromSuperview];
      [border removeFromSuperview];
      [largeImage removeFromSuperview];
      [aButton setImage:[UIImage imageNamed:@"media_field_empty.png"] forState:UIControlStateNormal];
    } else {
      [aButton removeFromSuperview];
      [aButton release];
    }
    buttonCount++;
  }
  currentMediaTag = 0;
  for (NSDictionary *aFile in tempFiles) {
    [self addFileToFiles:aFile forKey:currentFileKey];
    currentMediaTag++;
  }
  if(previewWindow != nil) {
    [previewWindow resignKeyWindow];
    [previewWindow release];
  }
  return;
}

- (IBAction)cancelImagePreview:(id)sender {
  [previewWindow resignKeyWindow];
  [previewWindow release];
  previewWindow = nil;
}


- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSDictionary *field = [fieldsByKeys objectForKey:currentFileKey];
  NSMutableArray *arrayOfFiles = [nodeSubmissionData objectForKey:currentFileKey];
  NSString *stringInt = [NSString stringWithFormat:@"%d", [arrayOfFiles count]];
  if([[field objectForKey:@"cardinality"] integerValue] != 1 && buttonIndex != 2) {
    if([[field objectForKey:@"cardinality"] isEqualToString:stringInt]) {
      [[AppDelegate customStatusBar] showWithStatusMessage:@"You have reached the limit for this field." hide:YES];
      return;
    }
  }
  switch (buttonIndex) {
    case 0:
      if (removeOldImage) {
        [self removeImage:self];
      }
      self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      [self presentViewController:self.imgPicker animated:YES completion:nil];
      break;
    case 1:
      if (removeOldImage) {
        [self removeImage:self];
      }
      self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
      [self presentViewController:self.imgPicker animated:YES completion:nil];
      break;
      
    default:
      break;
  }
}

-(void) makeToolBars
{
  UIToolbar *toolbar1 = [[[UIToolbar alloc] init] autorelease];
  [toolbar1 setBarStyle:UIBarStyleBlackTranslucent];
  [toolbar1 sizeToFit];
  
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Done"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(hideKeyboard:)];
  
  UIBarButtonItem *flexButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
  
  NSArray *itemsArray1 = [NSArray arrayWithObjects: flexButton1, doneButton, nil];
  
  [flexButton1 release];
  [doneButton release];
  [toolbar1 setItems:itemsArray1];
  NSEnumerator *e = [textViews objectEnumerator];
  id object;
  while (object = [e nextObject]) {
    [object setInputAccessoryView:toolbar1];
  }
  
}
- (void) hideKeyboard:(id)sender {
  NSEnumerator *e = [textViews objectEnumerator];
  id object;
  while (object = [e nextObject]) {
    [object resignFirstResponder];
  }
}
- (void)viewDidUnload
{
  [self setArticleSiteNid:nil];
  [self setImgPicker:nil];

  [multipleImageView release];
   multipleImageView = nil;

  [addTagsButton release];
  addTagsButton = nil;
  [mainScrollView release];
  mainScrollView = nil;
  [imagePreviewView release];
  imagePreviewView = nil;
  [imagePreviewImageView release];
  imagePreviewImageView = nil;
  [imagePreviewWhiteOverlay release];
  imagePreviewWhiteOverlay = nil;
  [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)postArticle:(id)sender {
  [mainScrollView setContentOffset:CGPointZero animated:YES];
  [postButton setEnabled:NO];
  [popover setHidden:YES];
  [currentResponder resignFirstResponder];
  NSMutableDictionary *nodeData = [NSMutableDictionary new];
  [nodeData setValue:machineName forKey:@"type"];
  NSEnumerator *e = [files objectEnumerator];
  BOOL earlyReturn = NO;
  for (NSDictionary *field in fieldsSorted) {
    id value = [nodeSubmissionData objectForKey:[field objectForKey:@"name"]];
    if ([value isKindOfClass:[UITextField class]] || [value isKindOfClass:[UITextView class]]) {
      if(![[value text] isEqualToString:@""] && [value text]) {
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [[value text] stringByTrimmingCharactersInSet:whitespace];
        if ([trimmed length] == 0) {
          NSString *requiredField = [NSString stringWithFormat:@"Field cannot contain only spaces: %@", [field objectForKey:@"name"]];
          [[AppDelegate customStatusBar] showWithStatusMessage:requiredField hide:YES];
          earlyReturn = YES;
        } else {
          [nodeData setObject:[value text] forKey:[field objectForKey:@"name"]];
        }
      } else {
        if ([requiredFieldNames containsObject:[field objectForKey:@"name"]]) {
          NSString *requiredField = [NSString stringWithFormat:@"Missing required field: %@", [field objectForKey:@"name"]];
          [[AppDelegate customStatusBar] showWithStatusMessage:requiredField hide:YES];
          earlyReturn = YES;
        }
      }
    } else if ([value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSDictionary class]]) {
      if([[value allKeys] count] == 0) {
        if ([requiredFieldNames containsObject:[field objectForKey:@"name"]]) {
          NSString *requiredField = [NSString stringWithFormat:@"Missing required field: %@", [field objectForKey:@"name"]];
          [[AppDelegate customStatusBar] showWithStatusMessage:requiredField hide:YES];
          earlyReturn = YES;
        }
      } else {
        [nodeData setObject:[value objectForKey:@"key"] forKey:[field objectForKey:@"name"]];
      }
    } else if ([value isKindOfClass:[NSMutableArray class]] || [value isKindOfClass:[NSMutableArray class]]) {
      if ([value count] == 0) {
        if ([requiredFieldNames containsObject:[field objectForKey:@"name"]]) {
          NSString *requiredField = [NSString stringWithFormat:@"Missing required field: %@", [field objectForKey:@"name"]];
          [[AppDelegate customStatusBar] showWithStatusMessage:requiredField hide:YES];
          earlyReturn = YES;
        }
      } else {
        NSMutableDictionary *newDict = [NSMutableDictionary new];
        if ([[[field objectForKey:@"options"] objectForKey:@"create"] boolValue]) {
          NSMutableArray *newCreatedArray = [NSMutableArray new];
          for (NSString *newTag in [createTags objectForKey:[field objectForKey:@"name"]]) {
            [newCreatedArray addObject:newTag];
            [value removeObjectAtIndex:[value indexOfObject:newTag]];
          }
          if ([newCreatedArray count] != 0 ) {
            [newDict setObject:newCreatedArray forKey:@"create"];
          }
        }
        [newDict setObject:value forKey:@"values"];
        [nodeData setObject:newDict forKey:[field objectForKey:@"name"]];
        [newDict release];
      }
    } else {
      if(value != nil) {
        [nodeData setObject:value forKey:[field objectForKey:@"name"]];
      } else {
        if ([requiredFieldNames containsObject:[field objectForKey:@"name"]]) {
          NSString *requiredField = [NSString stringWithFormat:@"Missing required field: %@", [field objectForKey:@"name"]];
          [[AppDelegate customStatusBar] showWithStatusMessage:requiredField hide:YES];
          earlyReturn = YES;
        }
      }

    }
  }
  if(earlyReturn) {
    [postButton setEnabled:YES];
    return;
  }
  id object;
  while (object = [e nextObject]) {
    [object removeObjectForKey:@"image"];
  }
  [[AppDelegate customStatusBar] showWithStatusMessage:@"Posting..." showLoadingIndicator:YES];
  [DGDClient addContentWithUrl:[siteInfo objectForKey:siteURLKey]
                  accessTokens:[siteInfo objectForKey:siteAccessTokens]
                        params:nodeData
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         [listViewController setShouldUpdate:YES];
                         [[AppDelegate customStatusBar] hide];
    [self dismissViewControllerAnimated:YES completion:nil];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSString *text = [NSString stringWithFormat:@"Failed to POST:%d", operation.response.statusCode];
    [[[AppDelegate customStatusBar] statusLabel] setText:text];
    [[AppDelegate customStatusBar] hide];
    [postButton setEnabled:YES];
  }];
  [nodeData release];
}
- (void)dealloc {
  [articleSiteNid release];
  [imgPicker release];
  [fileData release];
  [files release];
  [listViewController release];
  [siteInfo release];
  [siteFields release];
  [contentType release];
  [fieldsSorted release];
  [textViews release];
  [userButtons release];
  [usersData release];
  [tagButtons release];
  [tagData release];
  [imageData release];
  [requiredFieldNames release];
  [optionsForTags release];
  [selectedTags release];
  [createTags release];
  [nodeSubmissionData release];
  [currentFileKey release];
  [mediaFieldKeys release];
  [secondaryLabelsPerFields release];
  [mediaFieldScrollViews release];
  [mediaFieldImages release];
  [imagePreviewWhiteOverlay release];
  [super dealloc];
}
@end
