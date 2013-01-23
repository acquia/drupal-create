//
//  STLOAuthClient.h
//
//  Created by Marcelo Alves on 07/04/12.
//  Copyright (c) 2012 Some Time Left. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
// 
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. Redistributions in binary
//  form must reproduce the above copyright notice, this list of conditions and
//  the following disclaimer in the documentation and/or other materials
//  provided with the distribution. Neither the name of the Some Time Left nor
//  the names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission. THIS
//  SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "STLOAuthClient.h"
#include <sys/time.h>
#import <CommonCrypto/CommonHMAC.h>

// forward declarations
static NSString* Base64EncodedStringFromData(NSData *data);
static NSString* URLEncodeString(NSString *string);

@interface STLOAuthClient()
@property (copy) NSString *consumerKey;
@property (copy) NSString *consumerSecret;
@property (copy) NSString *tokenIdentifier;
@property (copy) NSString *tokenSecret;

- (id) initWithBaseURL:(NSURL *)url;
- (void) addGeneratedTimestampAndNonceInto:(NSMutableDictionary *)dictionary;
- (NSString *) authorizationHeaderValueForMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters;
@end

@implementation STLOAuthClient
@synthesize consumerKey = _consumerKey, 
         consumerSecret = _consumerSecret, 
            tokenSecret = _tokenSecret, 
        tokenIdentifier = _tokenIdentifier, 
           signRequests = _signRequests, 
                  realm = _realm;

- (id) initWithBaseURL:(NSURL *)url consumerKey:(NSString *)consumerKey secret:(NSString *)consumerSecret {
  self = [super initWithBaseURL:url];
  
  if (self) {
    self.signRequests = YES;
    self.consumerKey = consumerKey;
    self.consumerSecret = consumerSecret;
  }
  
  return self;
}

- (id) initWithBaseURL:(NSURL *)url {
  return [self initWithBaseURL:url consumerKey:NULL secret:NULL];
}

- (void) setAccessToken:(NSString *)accessToken secret:(NSString *)secret {
  self.tokenIdentifier = accessToken;
  self.tokenSecret = secret;
}

- (void) setConsumerKey:(NSString *)consumerKey secret:(NSString *)secret {
  self.consumerKey = consumerKey;
  self.consumerSecret = secret;
}

- (NSMutableURLRequest *) requestWithMethod:(NSString *)method 
                                       path:(NSString *)path 
                                 parameters:(NSDictionary *)parameters {
  
  NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
  
  if (self.signRequests) {
    NSString *authorizationHeader = [self authorizationHeaderValueForMethod:method path:path parameters:parameters];
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
  }
  
  return request;
}

- (NSURLRequest *) unsignedRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
  NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
  
  return request;
}

- (NSURLRequest *) signedRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
  NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
  
  NSString *authorizationHeader = [self authorizationHeaderValueForMethod:method path:path parameters:parameters];
  [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
  
  return request;
}

#pragma mark - "private" methods.

static const NSString *kOAuthSignatureMethodKey = @"oauth_signature_method";
static const NSString *kOAuthVersionKey = @"oauth_version";
static const NSString *kOAuthConsumerKey = @"oauth_consumer_key";
static const NSString *kOAuthTokenIdentifier = @"oauth_token";
static const NSString *kOAuthSignatureKey = @"oauth_signature";

static const NSString *kOAuthSignatureTypeHMAC_SHA1 = @"HMAC-SHA1";
static const NSString *kOAuthVersion1_0 = @"1.0";

- (NSMutableDictionary *) mutableDictionaryWithOAuthInitialData {
  NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 kOAuthSignatureTypeHMAC_SHA1, kOAuthSignatureMethodKey,
                                 kOAuthVersion1_0, kOAuthVersionKey,
                                 nil];
  
  if (self.consumerKey) [result setObject:self.consumerKey forKey:kOAuthConsumerKey];
  if (self.tokenIdentifier) [result setObject:self.tokenIdentifier forKey:kOAuthTokenIdentifier];
  
  [self addGeneratedTimestampAndNonceInto:result];
  
  return  result;
}

- (NSString *) stringWithOAuthParameters:(NSMutableDictionary *)oauthParams requestParameters:(NSDictionary *)parameters {
  // UTF-8/URL Encoding of all parameters (oauth + request) 
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:[parameters count] + [oauthParams count]];
  [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
    [params setObject:URLEncodeString(obj) forKey:URLEncodeString(key)];
  }];
  [oauthParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
    [params setObject:URLEncodeString(obj) forKey:URLEncodeString(key)];
  }];
  
  // sorting parameters
  NSArray *sortedKeys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
    NSComparisonResult result = [key1 compare:key2 options:NSLiteralSearch];
    if (result == NSOrderedSame)
      result = [[params objectForKey:key1] compare:[params objectForKey:key2] options:NSLiteralSearch];
    
    return result;
  }];
  
  // join keys and values with =
  NSMutableArray *longListOfParameters = [NSMutableArray arrayWithCapacity:[sortedKeys count]];
  [sortedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
    [longListOfParameters addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
  }];
  
  // join components with &
  return [longListOfParameters componentsJoinedByString:@"&"];
}

- (NSString *) authorizationHeaderValueForMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)params {
  NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
  NSString *fixedURL = [self baseURLforAddress:url];
  NSMutableDictionary *oauthParams = [self mutableDictionaryWithOAuthInitialData];
 
  // adding oauth_ extra params to the header
  NSMutableDictionary *parameters = [params mutableCopy];
  
  NSString *allParameters = [self stringWithOAuthParameters:oauthParams requestParameters:parameters];
  // adding HTTP method and URL
  NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@", [method uppercaseString], URLEncodeString(fixedURL), URLEncodeString(allParameters)];
  
  NSString *signature = [self signatureForBaseString:signatureBaseString];
  
  // add to OAuth params
  [oauthParams setObject:signature forKey:kOAuthSignatureKey];
  
  // build OAuth Authorization Header
  NSMutableArray *headerParams = [NSMutableArray arrayWithCapacity:[oauthParams count]];
  [oauthParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
    [headerParams addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, URLEncodeString(obj)]];
  }];
  
  // let's use the base URL if a realm was not set
  NSString *oauthRealm = self.realm;
  if (!oauthRealm) oauthRealm = [self baseURLforAddress:[self baseURL]];
  
  NSString *result = [NSString stringWithFormat:@"OAuth realm=\"%@\",%@", oauthRealm, [headerParams componentsJoinedByString:@","]];
  
  return result;
}

//
//  The following method is based on code from :
//
//  ASIHTTPRequest+OAuth.m
//
//  Created by Scott James Remnant on 6/1/11.
//  Copyright 2011 Scott James Remnant <scott@netsplit.com>. All rights reserved.
//
- (void) addGeneratedTimestampAndNonceInto:(NSMutableDictionary *)dictionary {
  static time_t last_timestamp = -1;
  static NSMutableSet *nonceHistory = nil;
  
  // Make sure we never send the same timestamp and nonce
  if (!nonceHistory)
    nonceHistory = [[NSMutableSet alloc] init];
  
  struct timeval tv;
  NSString *timestamp, *nonce;
  do {
    // Get the time of day, for both the timestamp and the random seed
    gettimeofday(&tv, NULL);
    
    // Generate a random alphanumeric character sequence for the nonce
    char nonceBytes[16];
    srandom(tv.tv_sec | tv.tv_usec);
    for (int i = 0; i < 16; i++) {
      int byte = random() % 62;
      if (byte < 26)
        nonceBytes[i] = 'a' + byte;
      else if (byte < 52)
        nonceBytes[i] = 'A' + byte - 26;
      else
        nonceBytes[i] = '0' + byte - 52;
    }
    
    timestamp = [NSString stringWithFormat:@"%d", tv.tv_sec];
    nonce = [NSString stringWithFormat:@"%.16s", nonceBytes];
  } while ((tv.tv_sec == last_timestamp) && [nonceHistory containsObject:nonce]);
  
  if (tv.tv_sec != last_timestamp) {
    last_timestamp = tv.tv_sec;
    [nonceHistory removeAllObjects];
  }
  [nonceHistory addObject:nonce];
  
  [dictionary setObject:nonce forKey:@"oauth_nonce"];
  [dictionary setObject:timestamp forKey:@"oauth_timestamp"];
}

- (NSString *) signatureForBaseString:(NSString *)baseString {
  NSString *key = [NSString stringWithFormat:@"%@&%@", self.consumerSecret != nil ? URLEncodeString(self.consumerSecret) : @"", self.tokenSecret != nil ? URLEncodeString(self.tokenSecret) : @""];
  
  const char *keyBytes = [key cStringUsingEncoding:NSUTF8StringEncoding];
  const char *baseStringBytes = [baseString cStringUsingEncoding:NSUTF8StringEncoding];
  unsigned char digestBytes[CC_SHA1_DIGEST_LENGTH];

  CCHmac(kCCHmacAlgSHA1, keyBytes, strlen(keyBytes), baseStringBytes, strlen(baseStringBytes), digestBytes);
  
  NSData *digestData = [NSData dataWithBytes:digestBytes length:CC_SHA1_DIGEST_LENGTH];
  return Base64EncodedStringFromData(digestData); 
}

- (NSString *) baseURLforAddress:(NSURL *)url {
  NSAssert1([url host] != nil, @"URL host missing: %@", [url absoluteString]);
  
  // Port need only be present if it's not the default
  NSString *hostString;
  if (([url port] == nil)
      || ([[[url scheme] lowercaseString] isEqualToString:@"http"] && ([[url port] integerValue] == 80))
      || ([[[url scheme] lowercaseString] isEqualToString:@"https"] && ([[url port] integerValue] == 443))) {
    hostString = [[url host] lowercaseString];
  } else {
    hostString = [NSString stringWithFormat:@"%@:%@", [[url host] lowercaseString], [url port]];
  }
  
  NSString *pathString = (__bridge NSString *)CFURLCopyPath((__bridge CFURLRef)[url absoluteURL]);
  return [NSString stringWithFormat:@"%@://%@%@", [[url scheme] lowercaseString], hostString, pathString];
}

@end

#pragma mark - Helper Functions
//
//  The function below is based on
//
//  NSString+URLEncode.h
//
//  Created by Scott James Remnant on 6/1/11.
//  Copyright 2011 Scott James Remnant <scott@netsplit.com>. All rights reserved.
//
static NSString *URLEncodeString(NSString *string) {
  // See http://en.wikipedia.org/wiki/Percent-encoding and RFC3986
  // Hyphen, Period, Understore & Tilde are expressly legal
  const CFStringRef legalURLCharactersToBeEscaped = CFSTR("!*'();:@&=+$,/?#[]<>\"{}|\\`^% ");
  
  return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8);
}

// The function below was inspired on
//
// AFOAuth2Client.m
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
static NSString * Base64EncodedStringFromData(NSData *data) {
  NSUInteger length = [data length];
  NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
  
  uint8_t *input = (uint8_t *)[data bytes];
  uint8_t *output = (uint8_t *)[mutableData mutableBytes];
  
  for (NSUInteger i = 0; i < length; i += 3) {
    NSUInteger value = 0;
    for (NSUInteger j = i; j < (i + 3); j++) {
      value <<= 8;
      if (j < length) value |= (0xFF & input[j]); 
    }
    
    static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    NSUInteger idx = (i / 3) * 4;
    output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
    output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
    output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
    output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
  }
  
  return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}
