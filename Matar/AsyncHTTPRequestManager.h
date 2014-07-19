//
//  AsyncHTTPRequestManager.h
//  Matar
//
//  Created by Dorian Peake on 14/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_MAX_CONNECTIONS 5

@class AsyncHTTPResponse;

@interface AsyncHTTPRequestManager : NSObject

@property (strong) NSNumber *maxConnections;
@property (strong, readonly) NSNumber *connectionCount;     // total number of concurrent active connections

-(void)dispatchRequest:(NSURLRequest*)request;
-(void)dispatchRequest:(NSURLRequest*)request WithCallback:(void (^)(AsyncHTTPResponse*))callback;
-(id)initWithMaxConnections:(NSUInteger)maxCons;

@end
