//
//  AppDelegate.m
//  Matar
//
//  Created by Dorian Peake on 04/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "AppDelegate.h"
#import <sqlite3.h>
#import "TrackDatabase.h"
#import "SCAPI.h"
#import "SCResponse.h"
#import "SCUsersResponse.h"
#import "SCTracksResponse.h"
#import "SCTrackInfo.h"
#import "SCUserInfo.h"

@interface AppDelegate () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

enum dataCallbackEnum
{
    DATA_INDEX,
    CALLBACK_INDEX
};

@property CFMutableDictionaryRef openConnections;
@property (strong) NSMutableArray *downloadQueue;
@property (strong, readonly) NSNumber *maxConnections;

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(bool)downloadTrack:(SCTrackInfo*)trackInfo WithCallback:(void (^)(NSData*))callback;

@end

@implementation AppDelegate

-(id)init
{
    if (self = [super init])
    {
        // initialise ivars
        [self setOpenConnections:CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)];
        [self setDownloadQueue:[[NSMutableArray alloc] init]];
    }
    return self;
}

// this set of connection functions deal with downloading mp3 tracks from soundcloud
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // call the callback with nil as a parameter to express failure
    NSArray *dataCallbackArray = CFDictionaryGetValue(self.openConnections, (__bridge const void *)(connection));
    void (^callback)(NSData*) = [dataCallbackArray objectAtIndex:CALLBACK_INDEX];
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        callback(nil);
    });

    CFDictionaryRemoveValue(self.openConnections, (__bridge const void*)connection);

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSArray *dataCallbackArray = CFDictionaryGetValue(self.openConnections, (__bridge const void *)(connection));
    NSMutableData *currentData = [dataCallbackArray objectAtIndex:DATA_INDEX];
    [currentData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // HTTPRequest was successful, nothing much to do here...
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSArray *dataCallbackArray = CFDictionaryGetValue(self.openConnections, (__bridge const void *)(connection));
    NSData *data = [dataCallbackArray objectAtIndex:DATA_INDEX];
    void (^callback)(NSData*) = [dataCallbackArray objectAtIndex:CALLBACK_INDEX];
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        callback(data);
    });
    
    CFDictionaryRemoveValue(self.openConnections, (__bridge const void*)connection);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    SCRequest *newRequest =
    [SCAPI newSCRequestWithResource: USERS WithID:@"sonarbear" WithSubresource:@"favorites" WithCallback:^(SCResponse *response)
    {
        NSArray *result = [response result];
        
        long count = [result count];
        
        switch ([response resourceType])
        {
            case USERS:
            {
                NSLog(@"User list returned");
                for (long index = 0; index < count; index++)
                {
                    SCUserInfo *user = [result objectAtIndex:index];
                    NSLog(@"ID: %d, Username: %@, AvatarURL: %@",[user ID],[user userName],[user avatarURL]);
                }
            }
            break;
            
            case TRACKS:
            {
                NSLog(@"Track list returned");
                for (long index = 0; index < count; index++)
                {
                    SCTrackInfo *track = [result objectAtIndex:index];
                    NSLog(@"Artist: %@, Title: %@, Date: %@, StreamURL: %@",[track artist],[track title], [NSDateFormatter localizedStringFromDate:track.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle], [track.streamURL path]);
                }
            }
            break;
        }
        
        return 0;
    }];

    [[SCAPI getInstance] dispatch:newRequest];
}

-(bool)downloadTrack:(SCTrackInfo*)trackInfo WithCallback:(void (^)(NSData*))callback
{    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:trackInfo.streamURL];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    CFDictionaryAddValue(self.openConnections, (__bridge const void*)conn, (__bridge const void*)[NSArray arrayWithObjects:[NSMutableData dataWithCapacity:0], callback, nil]);
    
    return true;
}

@end