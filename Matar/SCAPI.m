//
//  SCAPI.m
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "SCAPI.h"
#import "SCRequest.h"
#import "SCTrackInfo.h"
#import "SCUserInfo.h"
#import "SCUsersResponse.h"
#import "SCTracksResponse.h"

enum DataRequestArrayIndices
{
    DATA_INDEX,
    REQUEST_INDEX
};

// extension contains private member functions
@interface SCAPI () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong) NSMutableArray * const requestQueue;
@property CFMutableDictionaryRef openConnections;

-(void)executeHeadRequest;
+(NSString*)resourceStringFromNumber:(int)resource;
+(SCTrackInfo*)trackInfoFromDictionary:(NSDictionary*)dict;
+(SCUserInfo*)userInfoFromDictionary:(NSDictionary*)dict;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;


@end

@implementation SCAPI

static NSString *clientID;
static NSString * const SChost = @"http://api.soundcloud.com";
static const int JSONLimit = 0x7fffff;

-(id)init
{
    if (self = [super init])
    {
        [self setRequestQueue:[[NSMutableArray alloc] init]];
        [self setOpenConnections: CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)];
        NSError *e;
        NSString *clientIDPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"clientID"];
        NSLog(@"Using %@ as clientIDpath",clientIDPath);
        clientID = [[NSString stringWithContentsOfFile:clientIDPath encoding:NSUTF8StringEncoding error:&e] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"Loaded clientID %@ from file",clientID);
    }
    
    return self;
    
}

+(SCAPI *)getInstance
{
    static SCAPI *singleton = nil;
    
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken,
    ^{
        singleton = [[SCAPI alloc] init];
    });
    
    return singleton;
}


// the following connection methods manage the asynchronous JSON requests sent to the soundcloud servers.
// the methods manage linking connections to their associated data and running any callbacks provided.
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSArray *dataRequestArray = (NSArray*)CFDictionaryGetValue(self.openConnections, (__bridge const void *)(connection));
    
    if (!dataRequestArray)
    {
        NSLog(@"Some connection transferred data without being in the connections dictionary");
        return;
    }
    
    NSMutableData *dictData = (NSMutableData*)[dataRequestArray objectAtIndex:DATA_INDEX];
    
    NSLog(@"Received a little data...");
    [dictData appendData:data];
    
    return;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // extract data
    NSArray *dataRequestArray = (NSArray*)CFDictionaryGetValue(self.openConnections, (__bridge const void *)(connection));
    NSMutableData *data = (NSMutableData*)[dataRequestArray objectAtIndex:DATA_INDEX];
    SCRequest *request = (SCRequest*)[dataRequestArray objectAtIndex:REQUEST_INDEX];
    NSError *e;
    
    // debugging //////
    NSString *stringOfData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data:\n\n%@",stringOfData);
    ///////////////////
    
    // serialise the data and call the callback
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
    if ([jsonData isKindOfClass:[NSDictionary class]])
    {
        // its a single item which is described in its 'kind' dictionary entry
        // could be track, user, etc
        NSString *jsonDataType = [(NSDictionary*)jsonData objectForKey:@"kind"];
        
        if ([jsonDataType isEqual: @"user"])
        {
            SCUserInfo *userInfo = [SCAPI userInfoFromDictionary:(NSDictionary*)jsonData];
            SCUsersResponse *response = [[SCUsersResponse alloc] init];
            [response addUserInfo:userInfo];
            dispatch_async(dispatch_get_main_queue(),
            ^{
               [request callback](response);
            });
        }
        else if ([jsonDataType isEqual:@"track"])
        {
            SCTrackInfo *trackInfo = [SCAPI trackInfoFromDictionary:(NSDictionary*)jsonData];
            SCTracksResponse *response = [[SCTracksResponse alloc] init];
            [response addTrackInfo:trackInfo];
            dispatch_async(dispatch_get_main_queue(),
            ^{
               [request callback](response);
            });
        }
        else
        {
            NSLog(@"Unknown json type");
        }
    }
    else if ([jsonData isKindOfClass:[NSArray class]])
    {
        // next level down must be a dictionary
        NSArray *jsonArray = (NSArray*)jsonData;
        NSDictionary *firstItem = [jsonArray objectAtIndex:0];
        long count = [jsonArray count];
        NSString *jsonDataType = [firstItem objectForKey:@"kind"];
        
        if ([jsonDataType isEqual:@"user"])
        {
            SCUsersResponse *response = [[SCUsersResponse alloc] init];
            for (long index = 0; index < count; index++)
            {
                NSDictionary *item = [jsonArray objectAtIndex:index];
                [response addUserInfo: [SCAPI userInfoFromDictionary:item]];
            }
            dispatch_async(dispatch_get_main_queue(),
            ^{
               [request callback](response);
            });

        }
        else if ([jsonDataType isEqual:@"track"])
        {
            SCTracksResponse *response = [[SCTracksResponse alloc] init];
            for (long index = 0; index < count; index++)
            {
                NSDictionary *item = [jsonArray objectAtIndex:index];
                [response addTrackInfo: [SCAPI trackInfoFromDictionary:item]];
            }
            dispatch_async(dispatch_get_main_queue(),
            ^{
               [request callback](response);
            });
        }
        else
        {
            NSLog(@"Unknown json type");
        }
    }
    
    // remove connection entry from dictionary
    CFDictionaryRemoveValue(self.openConnections, (__bridge const void*)connection);
    
    return;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // on failiure, remove the connection dictionary entry and run the callback with a nil value to express failiure
    SCRequest* request = CFDictionaryGetValue(self.openConnections, (__bridge const void*)connection);
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [request callback](nil);
    });
    CFDictionaryRemoveValue(self.openConnections, (__bridge const void *)(connection));
    
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Received NSURLResponse with content length %lld",[response expectedContentLength]);
}

+(SCRequest*)newSCRequestWithResource:(int)resource WithCallback:(int (^)(SCResponse *))callback
{
    SCRequest *request = [SCRequest alloc];
    [request setResource:[self resourceStringFromNumber:resource]];
    [request setCallback:callback];
    return request;
}

+(SCRequest*)newSCRequestWithResource:(int)resource WithID:(NSString *)ID WithCallback:(int (^)(SCResponse *))callback
{
    SCRequest *request = [SCRequest alloc];
    [request setResource:[self resourceStringFromNumber:resource]];
    [request setID:ID];
    [request setCallback:callback];
    
    return request;
}

+(SCRequest*)newSCRequestWithResource:(int)resource WithID:(NSString *)ID WithSubresource:(NSString *)subresource WithCallback:(int (^)(SCResponse *))callback
{
    SCRequest *request = [SCRequest alloc];
    [request setResource:[self resourceStringFromNumber:resource]];
    [request setID:ID];
    [request setSubresource:subresource];
    [request setCallback:callback];
    
    return request;
}

// begin asynchronous JSON request on object
-(void)dispatch:(SCRequest*)request
{
    NSLog(@"Request added to queue");
    [self.requestQueue addObject:request];
    [self performSelector:@selector(executeHeadRequest)];
    
}

// executes the first SCRequest object on the queue and subsequently queues up any more for execution
-(void)executeHeadRequest
{
    SCRequest *request = [self.requestQueue objectAtIndex:0];
    [self.requestQueue removeObjectAtIndex:0];
    
    // chain execution of the SoundCloud requests
    if ([self.requestQueue count] > 0)
    {
        [self performSelector:@selector(executeHeadRequest)];
    }
    
    NSMutableString *requestString = [NSMutableString stringWithFormat:@"%@/%@",SChost,[request resource]];
    
    if ([request ID] != nil)
    {
        [requestString appendFormat:@"/%@",[request ID]];
    }
    if ([request subresource] != nil)
    {
        [requestString appendFormat:@"/%@",[request subresource]];
    }
    
    [requestString appendFormat:@".json?client_id=%@&limit=%d", clientID, JSONLimit];
    NSLog(@"sending request: %@",requestString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [urlrequest setHTTPMethod:@"GET"];
    [urlrequest setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlrequest delegate:self];
    
    CFDictionaryAddValue(self.openConnections, (void*)conn,(void*)[NSArray arrayWithObjects:[NSMutableData dataWithCapacity:0],request, nil]);
    
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

+(SCTrackInfo*)trackInfoFromDictionary:(NSDictionary*)dict
{
    SCTrackInfo *trackInfo = [[SCTrackInfo alloc] init];
    [trackInfo setTitle:[dict objectForKey:@"title"]];
    [trackInfo setTagList:[dict objectForKey:@"tag_list"]];
    [trackInfo setStreamURL:[NSURL URLWithString:[dict objectForKey:@"stream_url"]]];
    [trackInfo setID:[(NSNumber*)[dict objectForKey:@"id"] intValue]];
    [trackInfo setGenre:[dict objectForKey:@"genre"]];
    [trackInfo setDescription:[dict objectForKey:@"description"]];
    NSString *newDate = [[dict objectForKey:@"created_at"] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    [trackInfo setCreatedAt:[NSDate dateWithString:newDate]];
    NSString *artist = [(NSDictionary*)[dict objectForKey:@"user"] objectForKey:@"username"];
    [trackInfo setArtist:artist];
    
    return trackInfo;
    
}

+(SCUserInfo*)userInfoFromDictionary:(NSDictionary*)dict
{
    SCUserInfo *userInfo = [[SCUserInfo alloc] init];
    [userInfo setUserName:[dict objectForKey:@"username"]];
    [userInfo setID:[(NSNumber*)[dict objectForKey:@"id"] intValue]];
    [userInfo setAvatarURL:[dict objectForKey:@"avatar_url"]];
    
    return userInfo;
}


@end
