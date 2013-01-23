//
//  UIImage+orientationFix.m
//  Drupal Create
//
//  Created by Kyle Browning on 8/8/12.
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "UIImage+orientationFix.h"

@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {
  if (self.imageOrientation == UIImageOrientationUp) return self; 
  
  UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
  [self drawInRect:(CGRect){0, 0, self.size}];
  UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return normalizedImage;
} 

@end