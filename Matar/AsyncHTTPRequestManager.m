//
//  AsyncHTTPRequestManager.m
//  Matar
//
//  Created by Dorian Peake on 14/07/2014.
//
//  Matar, the Soundcloud Precipitation Inducer.
//  Copyright (C) 2014  Dorian Peake
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


#import "AsyncHTTPRequestManager.h"
#import "AsyncHTTPRequest.h"
#import "AsyncHTTPResponse.h"

enum RequestDataArrayIndices
{
    REQUEST_INDEX,
    DATA_INDEX
};

@interface AsyncHTTPRequestManager () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property CFMutableDictionaryRef openConnections;
@property (strong) NSMutableArray *requestQueue;
@property (strong) NSNumber *connectionCount;

@end

@implementation AsyncHTTPRequestManager

-(id)init
{
    if (self = [super init])
    {
        [self setOpenConnections: CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)];
        [self setRequestQueue:[[NSMutableArray alloc]initWithCapacity:0]];
        [self setConnectionCount:[[NSNumber alloc] initWithInt:0]];
        [self setMaxConnections:[NSNumber numberWithInt:DEFAULT_MAX_CONNECTIONS]];
    }
    return self;
}

-(id)initWithMaxConnections:(NSUInteger)maxCons
{
    if(self = [super init])
    {
        [self setConnectionCount:[[NSNumber alloc] initWithInt:0]];
        [self setMaxConnections:[NSNumber numberWithLong:maxCons]];
    }
    return self;
}

-(void)dispatchRequest:(NSURLRequest*)request
{
    AsyncHTTPRequest *asyncRequest = [[AsyncHTTPRequest alloc] initWithRequest:request];
    [self.requestQueue addObject:asyncRequest];
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [self executeHeadRequest];
    });
}

-(void)dispatchRequest:(NSURLRequest*)request WithCallback:(void (^)(AsyncHTTPResponse*))callback
{
    AsyncHTTPRequest *asyncRequest = [[AsyncHTTPRequest alloc] initWithRequest:request WithCallback:callback];
    [self.requestQueue addObject:asyncRequest];
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [self executeHeadRequest];
    });
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // run the callback with a new AsyncHTTPResponse object
    NSArray *requestDataArray = CFDictionaryGetValue(self.openConnections, (__bridge const void*) connection);
    AsyncHTTPRequest *request = [requestDataArray objectAtIndex:REQUEST_INDEX];
    NSMutableData *data = [requestDataArray objectAtIndex:DATA_INDEX];
    AsyncHTTPResponse *response = [[AsyncHTTPResponse alloc] initWithData:data];
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        request.callback(response);
    });
    
    CFDictionaryRemoveValue(self.openConnections, (__bridge const void*)connection);
    
    [self setConnectionCount:[[NSNumber alloc] initWithInt:([self.connectionCount intValue] - 1)]];
    if ([self.requestQueue count])
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self executeHeadRequest];
        });
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // pass message straight to user, if callback exists
    AsyncHTTPRequest *request = CFDictionaryGetValue(self.openConnections, (__bridge const void*)connection);
    
    if (request.callback == nil)
    {
        return;
    }
    
    AsyncHTTPResponse *response = [[AsyncHTTPResponse alloc] initWithError:error];
    dispatch_async(dispatch_get_main_queue(),
    ^{
        request.callback(response);
    });
    
    CFDictionaryRemoveValue(self.openConnections, (__bridge const void*)connection);
    [self setConnectionCount:[[NSNumber alloc] initWithInt:([self.connectionCount intValue] - 1)]];
    if ([self.requestQueue count])
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self executeHeadRequest];
        });
    }
    return;
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // nothing much to do here at the moment
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append data
    NSMutableData *currentData = [(NSArray*)CFDictionaryGetValue(self.openConnections, (__bridge const void*) connection) objectAtIndex:DATA_INDEX];
    
    [currentData appendData:data];
    
    return;
    
}

-(bool)executeHeadRequest
{
    if (self.connectionCount >= self.maxConnections)
    {
        return false;
    }
    
    AsyncHTTPRequest *request = [self.requestQueue objectAtIndex:0];
    [self.requestQueue removeObjectAtIndex:0];
    // TODO may change from object to integer to reduce reallocation overhead
    [self setConnectionCount:[[NSNumber alloc] initWithInt:([self.connectionCount intValue] + 1)]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request.request delegate:self];
    CFDictionaryAddValue(self.openConnections, (__bridge const void *)(conn), (__bridge const void *)[[NSArray alloc] initWithObjects:request,[[NSMutableData alloc] initWithCapacity:0], nil]);
    
    return true;
}

@end
