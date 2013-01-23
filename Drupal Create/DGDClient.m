//
//  DGDClient.m
//  Drupal Create
//
//  Copyright (c) 2012 Acquia. All rights reserved.
//

#import "DGDClient.h"
#import "DIOSView.h"
#import "DIOSNode.h"
#import "DIOSSession.h"
#import "DGAppDelegate.h"
#import "JSONKit.h"
@implementation DGDClient

+ (void)getAutocompleteValues:(NSString *)url
                 accessTokens:(NSDictionary *)accessTokens
                       bundle:(NSString *)bundle
                    fieldName:(NSString *)fieldName
                        match:(NSString*)match
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:bundle, fieldName, match, nil]
                                                       forKeys:[NSArray arrayWithObjects:@"bundle", @"field_name", @"match", nil]];

  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", url, @"mast-api", @"autocomplete"];
  [DGDClient sendRequestWithURL:url path:path method:@"GET" params:params accessTokens:accessTokens success:success failure:failure];
  [params release];
}
+ (void)getOptions:(NSString *)url
      accessTokens:(NSDictionary *)accessTokens
            bundle:(NSString *)bundle
         fieldName:(NSString *)fieldName
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:bundle, fieldName, nil]
                                                       forKeys:[NSArray arrayWithObjects:@"bundle", @"field_name", nil]];
  
  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", url, @"mast-api", @"options"];
  [DGDClient sendRequestWithURL:url path:path method:@"GET" params:params accessTokens:accessTokens success:success failure:failure];
  [params release];
}
+ (void)getOptions:(NSString *)url
      accessTokens:(NSDictionary *)accessTokens
            bundle:(NSString *)bundle
            params:(NSDictionary*)params
         fieldName:(NSString *)fieldName
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", url, @"mast-api", @"options"];
  [DGDClient sendRequestWithURL:url path:path method:@"GET" params:params accessTokens:accessTokens success:success failure:failure];
  [params release];
}
+ (void)getSiteAvailability:(NSString *)url
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  [[DIOSSession sharedSessionWithURL:url] getPath:[NSString stringWithFormat:@"%@", @"mast-api-available.json"]
                                       parameters:nil
                                          success:success
                                          failure:failure];
}
+ (void)getSiteFields:(NSString *)url
         accessTokens:(NSDictionary*)accessTokens
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", url, @"mast-api", @"fields"];
  [DGDClient sendRequestWithURL:url path:path method:@"GET" params:nil accessTokens:accessTokens success:success failure:failure];
}

+ (void)getContentByUserWithURL:(NSString *)url
                         params:(NSDictionary *)params
                   accessTokens:(NSDictionary*)accessTokens
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", url, @"mast-api", @"content-by-user"];
  [DGDClient sendRequestWithURL:url path:path method:@"GET" params:params accessTokens:accessTokens success:success failure:failure];
}
+ (void)deleteNid:(NSString*)nid
          withUrl:(NSString*)url
     accessTokens:(NSDictionary*)accessTokens
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@", url, @"mast-api", @"content", nid];
  [DGDClient sendRequestWithURL:url path:path method:@"DELETE" params:nil accessTokens:accessTokens success:success failure:failure];
}
+ (void)getSiteMetaUserInfoWithUrl:(NSString*)url
                      accessTokens:(NSDictionary*)accessTokens
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [DGDClient getSiteMeta:url meta:@"whoami" accessTokens:accessTokens success:success failure:failure];
}
+ (void)getSiteMeta:(NSString*)url
               meta:(NSString*)meta
       accessTokens:(NSDictionary*)accessTokens
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@", url, @"mast-api", @"meta", meta];
  [DGDClient sendRequestWithURL:url path:path method:@"GET" params:nil accessTokens:accessTokens success:success failure:failure];
}
+ (void)getSiteMetaSiteInfoWithUrl:(NSString*)url
                      accessTokens:(NSDictionary*)accessTokens
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [DGDClient getSiteMeta:url meta:@"site" accessTokens:accessTokens success:success failure:failure];
}
+ (void)addContentWithUrl:(NSString*)url
             accessTokens:(NSDictionary*)accessTokens
                   params:(NSDictionary*)params
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  if(![AppDelegate hasInternet]) {
    [[AppDelegate customStatusBar] showWithStatusMessage:@"Please check your Internet connection." hide:YES];
    return;
  }
  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", url, @"mast-api", @"content-by-user"];
  
  DIOSSession *client = [[DIOSSession alloc] initWithBaseURL:[NSURL URLWithString:url] consumerKey:CONSUMER_KEY secret:CONSUMER_SECRET];
  [client setAccessToken:[accessTokens objectForKey:@"oauth_token"] secret:[accessTokens objectForKey:@"oauth_token_secret"]];
  [client setParameterEncoding:AFFormURLParameterEncoding];
  
  NSString *json = [params JSONString];
  
  NSMutableDictionary *newParams = [NSMutableDictionary new];
  [newParams setObject:json forKey:@"node"];
  NSURLRequest *request = [client signedRequestWithMethod:@"POST" path:path parameters:newParams];
  [newParams release];
  AFHTTPRequestOperation *operation = [[DIOSSession sharedSessionWithURL:url] HTTPRequestOperationWithRequest:request success:success failure:failure];
  [client enqueueHTTPRequestOperation:operation];
  [client release];

  
  //[DGDClient sendRequestWithURL:url path:path method:@"POST" params:params accessTokens:accessTokens success:success failure:failure];
}

+ (void) sendRequestWithURL:(NSString*)url
                       path:(NSString*)path
                     method:(NSString*)method
                     params:(NSDictionary*)params
               accessTokens:(NSDictionary*)accessTokens
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  if(![AppDelegate hasInternet]) {
    [[AppDelegate customStatusBar] showWithStatusMessage:@"Please check your Internet connection." hide:YES];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"internetConnectionFailed"
     object:nil];
    return;
  }
  DIOSSession *client = [[DIOSSession alloc] initWithBaseURL:[NSURL URLWithString:url] consumerKey:CONSUMER_KEY secret:CONSUMER_SECRET];
  [client setAccessToken:[accessTokens objectForKey:@"oauth_token"] secret:[accessTokens objectForKey:@"oauth_token_secret"]];
  NSURLRequest *request = [client signedRequestWithMethod:method path:path parameters:params];

  AFHTTPRequestOperation *operation = [[DIOSSession sharedSessionWithURL:url] HTTPRequestOperationWithRequest:request success:success failure:failure];
  [client enqueueHTTPRequestOperation:operation];
  [client release];
}

+ (void) uploadFileWithURL:(NSString*)url
                    params:(NSDictionary*)params
              accessTokens:(NSDictionary*)accessTokens
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  if(![AppDelegate hasInternet]) {
    [[AppDelegate customStatusBar] showWithStatusMessage:@"Please check your Internet connection." hide:YES];
    return;
  }
  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", url, @"mast-api", @"field-instance-file"];
  DIOSSession *client = [[DIOSSession alloc] initWithBaseURL:[NSURL URLWithString:url] consumerKey:CONSUMER_KEY secret:CONSUMER_SECRET];
  [client setAccessToken:[accessTokens objectForKey:@"oauth_token"] secret:[accessTokens objectForKey:@"oauth_token_secret"]];
  
  NSMutableDictionary *myParams = [NSMutableDictionary new];
  [myParams setObject:[params objectForKey:@"bundle"] forKey:@"bundle"];
  [myParams setObject:[params objectForKey:@"field_name"] forKey:@"field_name"];
  
  NSURLRequest* request = [client multipartFormRequestWithMethod:@"POST"
                                                            path:path
                                                      parameters:myParams
                                      constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                    NSData *data = [params objectForKey:@"file"];
                                                                    [formData appendPartWithFileData:data
                                                                                                name:@"files"
                                                                                            fileName:@"image1.jpg"
                                                                                            mimeType:@"image/jpeg"];
                                      }];
  
  AFHTTPRequestOperation *operation = [[DIOSSession sharedSessionWithURL:url] HTTPRequestOperationWithRequest:request success:success failure:failure];
  [client enqueueHTTPRequestOperation:operation];
  [client release];
  [myParams release];

}
+ (void)logoutUserWithUrl:(NSString *)url
         accessTokens:(NSDictionary*)accessTokens
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  //When user/logout is enabled on mast api uncomment this line
//    NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@", url, @"mast-api", @"user", @"logout"];
  NSString *path = [NSString stringWithFormat:@"%@/%@/%@", url, @"user", @"logout"];
  [DGDClient sendRequestWithURL:url path:path method:@"GET" params:nil accessTokens:accessTokens success:success failure:failure];

}
@end
