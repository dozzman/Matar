//
//  AsyncHTTPRequest.h
//  Matar
//
//  Created by Dorian Peake on 19/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AsyncHTTPResponse;

@interface AsyncHTTPRequest : NSObject

@property (strong) NSURLRequest* request;
@property (strong) void (^callback)(AsyncHTTPResponse*);

-(id)initWithRequest:(NSURLRequest*)request;
-(id)initWithRequest:(NSURLRequest *)request WithCallback:(void (^)(AsyncHTTPResponse*))callback;

@end
