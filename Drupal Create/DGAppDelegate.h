//
//  DGAppDelegate.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//
#define AppDelegate (DGAppDelegate *)[[UIApplication sharedApplication] delegate]

#define sitesKey @"sites"
#define siteLabelKey @"siteLabelKey"
#define siteURLKey @"siteURLKey"
#define siteFaviconURLKey @"siteFaviconURLKey"
#define siteFaviconData @"siteFaviconData"
#define siteAccessTokens @"accessTokens"
#define keepLogin @"keepLogin"
#define cacheKey @"cache"
#define authorOptions @"authorOptions"
#define imageSizeKey @"imageSize"
#define authorDataKey @"author"
#define expireTimestampKey @"expires"
#define expireAuthorTimestampKey @"authorExpires"
#define expireOptionsTimestampKey @"optionsExpires"
#define loggedinUsername @"loggedinname"
#define expireLoggedinUsername @"expireLoggedinUsername"
#define fieldCacheKey @"fieldCache"
#define CONSUMER_KEY @"Q29tZSBmb3IgdGhlIHNvZnR3YXJl"
#define CONSUMER_SECRET @"c3RheSBmb3IgdGhlIGNvbW11bml0eS4"
#define CONTENT_TYPE_ERROR_CODE 400
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] || [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone Simulator" ])
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

#import <UIKit/UIKit.h>
#import "CustomStatusBar.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>

#import "DGSiteListViewController.h"
@implementation NSString (numericComparison)

- (NSComparisonResult) compareNumerically:(NSString *) other
{
  float myValue = [self floatValue];
  float otherValue = [other floatValue];
  if (myValue == otherValue) return NSOrderedSame;
  return (myValue < otherValue ? NSOrderedAscending : NSOrderedDescending);
}

@end
@interface NSString(MD5)
- (NSString *)MD5;

@end

@implementation NSString(MD5)

- (NSString*)MD5
{
  // Create pointer to the string as UTF8
  const char *ptr = [self UTF8String];
  
  // Create byte array of unsigned chars
  unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
  
  // Create 16 byte MD5 hash value, store in buffer
  CC_MD5(ptr, strlen(ptr), md5Buffer);
  
  // Convert MD5 value in the buffer to NSString of hex values
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x",md5Buffer[i]];
  
  return output;
}
@end
@interface DGAppDelegate : UIResponder <UIApplicationDelegate> {
  NSString *currentSiteID;
}

@property (strong, nonatomic) NSString *currentSiteID;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CustomStatusBar *customStatusBar;
@property (strong, nonatomic) UINavigationController *navigationController;

- (NSMutableDictionary*)getCachedData:(NSString*)aCacheKey;
- (UIColor*)colorWithHexString:(NSString*)hex;
- (BOOL) hasInternet;
- (void) addSiteWithLabel:(NSString *)label andURL:(NSString *)url andAccessTokens:(NSMutableDictionary*)accessTokens andDelegate:(DGSiteListViewController*)delegate;
- (BOOL)isCacheOutOfDate:(NSString*)aCacheKey expiryKey:(NSString*)expiryKey expireTime:(int)expireTime;
- (void)saveCache:(NSMutableDictionary *)cache ForKey:(NSString*)aCacheKey;
- (void)saveCache:(NSMutableDictionary *)cache ForKey:(NSString*)aCacheKey expireKey:(NSString *)expireKey;
- (void) addSiteNavigationBar;
- (void) normalNavigationBar;
- (BOOL) hasSites;
- (int) siteCount;
- (void) logoutOfSites;
- (NSDictionary*)siteForUrl:(NSString*)siteUrl;
- (void) logoutOfSiteWithURL:(NSString*)siteUrl shouldForceLogout:(BOOL)force;
- (BOOL) isLoggedOutofSiteURL:(NSString*)siteUrl;
- (void) updateSiteAccessTokens:(NSString*)siteUrl accessToken:(NSMutableDictionary*)accessTokens;
@end
