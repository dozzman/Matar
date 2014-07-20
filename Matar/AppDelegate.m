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
#import "AsyncHTTPRequestManager.h"
#import "AsyncHTTPResponse.h"

@interface AppDelegate () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong) AsyncHTTPRequestManager *requestManager;

-(bool)downloadTrack:(SCTrackInfo*)trackInfo WithCallback:(void (^)(NSData*))callback;

@end

@implementation AppDelegate

-(id)init
{
    if (self = [super init])
    {
        // initialise ivars and properties
        [self setRequestManager:[[AsyncHTTPRequestManager alloc] init]];
    }
    return self;
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
                    [[TrackDatabase getInstance] userExists:user WithCallback:
                    ^(bool exists) {
                        if (!exists)
                        {
                            [[TrackDatabase getInstance] addUser:user];
                        }
                    }];
                    //NSLog(@"ID: %d, Username: %@, AvatarURL: %@",(int)user.ID,user.userName,user.avatarURL);
                }
            }
            break;
            
            case TRACKS:
            {
                NSLog(@"Track list returned");
                for (long index = 0; index < count; index++)
                {
                    SCTrackInfo *track = [result objectAtIndex:index];
                    [[TrackDatabase getInstance] trackExists:track WithCallback:
                    ^(bool exists)
                    {
                        if (!exists)
                        {
                            [[TrackDatabase getInstance] addTrack:track];
                        }
                    }];
                    /*NSLog(@"Artist: %@, Title: %@, Date: %@, StreamURL: %@",[track artist],[track title], [NSDateFormatter localizedStringFromDate:track.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle], [track.streamURL path]);*/
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
    [self.requestManager dispatchRequest:request WithCallback:
    ^(AsyncHTTPResponse *response) {
        callback(response.data);
    }];
    
    return true;
}

@end