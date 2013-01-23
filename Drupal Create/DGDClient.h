//
//  DGDClient.h
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DIOSSession.h"

@interface DGDClient : DIOSSession

+ (void)getAutocompleteValues:(NSString *)url
                 accessTokens:(NSDictionary *)accessTokens
                       bundle:(NSString *)bundle
                    fieldName:(NSString *)fieldName
                        match:(NSString*)match
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)getOptions:(NSString *)url
      accessTokens:(NSDictionary *)accessTokens
            bundle:(NSString *)bundle
         fieldName:(NSString *)fieldName
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)getOptions:(NSString *)url
      accessTokens:(NSDictionary *)accessTokens
            bundle:(NSString *)bundle
            params:(NSDictionary*)params
         fieldName:(NSString *)fieldName
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)getSiteAvailability:(NSString *)url
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)getSiteFields:(NSString *)url
         accessTokens:(NSDictionary*)accessTokens
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure ;

+ (void)getContentByUserWithURL:(NSString *)url
                         params:(NSDictionary *)params
                   accessTokens:(NSDictionary*)accessTokens
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)deleteNid:(NSString*)nid
          withUrl:(NSString*)url
     accessTokens:(NSDictionary*)accessTokens
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure ;

+ (void)addContentWithUrl:(NSString*)url
             accessTokens:(NSDictionary*)accessTokens
                   params:(NSDictionary*)params
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

+ (void) sendRequestWithURL:(NSString*)url
                       path:(NSString*)path
                     method:(NSString*)method
                     params:(NSDictionary*)params
               accessTokens:(NSDictionary*)accessTokens
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void) uploadFileWithURL:(NSString*)url
                    params:(NSDictionary*)params
              accessTokens:(NSDictionary*)accessTokens
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)getSiteMeta:(NSString*)url
               meta:(NSString*)meta
       accessTokens:(NSDictionary*)accessTokens
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)getSiteMetaUserInfoWithUrl:(NSString*)url
                      accessTokens:(NSDictionary*)accessTokens
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)getSiteMetaSiteInfoWithUrl:(NSString*)url
                      accessTokens:(NSDictionary*)accessTokens
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)logoutUserWithUrl:(NSString *)url
             accessTokens:(NSDictionary*)accessTokens
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
@end

