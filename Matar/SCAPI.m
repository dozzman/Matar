//
//  SCAPI.m
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "SCAPI.h"
#import "SCRequest.h"

// extension contains private member functions
@interface SCAPI () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+(void)executeHeadRequest;
+(NSString*)resourceStringFromNumber:(int)resource;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
@end

@implementation SCAPI

static NSMutableArray * const requestQueue;
static NSString * const clientID;
static NSString * const SChost = @"http://api.soundcloud.com";
static const int JSONLimit = 0xffffffff;
static NSDictionary * const openConnections;

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    unsigned long count = [openConnections count];
    
    for (unsigned long index = 0; index < count; index++)
    {
        NSMutableData *dataObj = [openConnections objectForKey:[NSString stringWithFormat:@"%lu",[connection hash]]];
        if (dataObj == nil)
        {
            // something went wrong
            NSLog(@"Couldn't find object associated with key in connections dictionary");
            return;
        }
        [dataObj appendData:data];
        
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

}

+(SCRequest*)newSCRequestWithResource:(int)resource WithCallback:(int (^)(SCResponse *))callback
{
    SCRequest *request = [SCRequest alloc];
    [request setResource:[self resourceStringFromNumber:resource]];
    [request setCallback:callback];
    return request;
}

+(SCRequest*)newSCRequestWithResource:(int)resource WithID:(NSString *)id WithCallback:(int (^)(SCResponse *))callback
{
    SCRequest *request = [SCRequest alloc];
    [request setResource:[self resourceStringFromNumber:resource]];
    [request setId:id];
    [request setCallback:callback];
    
    return request;
}

+(SCRequest*)newSCRequestWithResource:(int)resource WithID:(NSString *)id WithSubresource:(NSString *)subresource WithCallback:(int (^)(SCResponse *))callback
{
    SCRequest *request = [SCRequest alloc];
    [request setResource:[self resourceStringFromNumber:resource]];
    [request setId:id];
    [request setSubresource:subresource];
    [request setCallback:callback];
    
    return request;
}

+(void)dispatch:(SCRequest*)request
{
    [requestQueue addObject:request];
    
}

+(void)executeHeadRequest
{
    SCRequest *request = [requestQueue objectAtIndex:0];
    [requestQueue removeObjectAtIndex:0];
    
    NSMutableString *requestString = [NSMutableString stringWithString:SChost];
    
    if ([request id] != nil)
    {
        [requestString appendFormat:@"/%@",[request id]];
    }
    if ([request subresource] != nil)
    {
        [requestString appendFormat:@"/%@",[request subresource]];
    }
    
    [requestString appendFormat:@".json?client_id=%@&limit=%d", clientID, JSONLimit];
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [urlrequest setHTTPMethod:@"GET"];
    [urlrequest setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlrequest delegate:self];
    
    [openConnections insertValue:[[NSMutableData alloc] init] inPropertyWithKey:[NSString stringWithFormat:@"%lu",(unsigned long)[conn hash]]];
    
    
}

+(NSString*)resourceStringFromNumber:(int)resource
{
    switch (resource)
    {
        case USERS:
        {
            return @"users";
        } break;
        case TRACKS:
        {
            return @"tracks";
        } break;
        default:
            return nil;
        break;
    }
}

@end
