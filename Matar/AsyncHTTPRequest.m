//
//  AsyncHTTPRequest.m
//  Matar
//
//  Created by Dorian Peake on 19/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "AsyncHTTPRequest.h"

@interface AsyncHTTPRequest ()

@property (strong) NSURLRequest* request;
@property (strong) void (^callback)(AsyncHTTPResponse*);

@end

@implementation AsyncHTTPRequest

-(id)initWithRequest:(NSURLRequest*)request
{
    if (self = [super init])
    {
        [self setRequest:request];
    }
    return self;
}

-(id)initWithRequest:(NSURLRequest *)request WithCallback:(void (^)(AsyncHTTPResponse*))callback
{
    if (self = [super init])
    {
        [self setRequest:request];
        [self setCallback:callback];
    }
    return self;
}

@end
