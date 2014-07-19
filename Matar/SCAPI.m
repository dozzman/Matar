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
#import "AsyncHTTPRequestManager.h"
#import "AsyncHTTPResponse.h"

enum DataRequestArrayIndices
{
    DATA_INDEX,
    REQUEST_INDEX
};

// extension contains private member functions
@interface SCAPI () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong) NSMutableArray * const requestQueue;
@property CFMutableDictionaryRef openConnections;
@property (strong) AsyncHTTPRequestManager *requestManager;

+(NSString*)resourceStringFromNumber:(int)resource;
+(SCTrackInfo*)trackInfoFromDictionary:(NSDictionary*)dict;
+(SCUserInfo*)userInfoFromDictionary:(NSDictionary*)dict;


@end

@implementation SCAPI

static NSString *clientID;
static NSString * const SChost = @"http://api.soundcloud.com";
static const int JSONLimit = 0x7fffff;

-(id)init
{
    if (self = [super init])
    {
        [self setRequestManager:[[AsyncHTTPRequestManager alloc] init]];
        [self setRequestQueue:[[NSMutableArray alloc] init]];
        [self setOpenConnections: CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)];
        NSError *e;
        NSString *clientIDPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"clientID"];
        clientID = [[NSString stringWithContentsOfFile:clientIDPath encoding:NSUTF8StringEncoding error:&e] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [urlrequest setHTTPMethod:@"GET"];
    [urlrequest setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [self.requestManager dispatchRequest:urlrequest WithCallback:
    ^(AsyncHTTPResponse* response)
    {
        NSData *data = response.data;
        NSError *e;
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
            // otherwise unknown json type
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
            // otherwise unknown json type
        }
    }];
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
