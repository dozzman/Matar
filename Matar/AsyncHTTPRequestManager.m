//
//  AsyncHTTPRequestManager.m
//  Matar
//
//  Created by Dorian Peake on 14/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "AsyncHTTPRequestManager.h"

@interface AsyncHTTPRequestManager () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong) NSMutableDictionary *openConnections;
@property (strong) NSMutableArray *requestQueue;
@end

@implementation AsyncHTTPRequestManager

-(id)init
{
    if (self = [super init])
    {
        _connectionCount = [NSNumber alloc] initWithInt:
    }
    return self;
}

-(id)initWithMaxConnections:(NSUInteger)
{

}

-(void)queueRequest:(NSURLRequest*)request
{

}

-(void)queueRequest:(NSURLRequest*)request WithCallback:(void (^)(NSData*))callback
{

}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

}

@end
