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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Program Started");
    SCRequest *newRequest =
    [SCAPI newSCRequestWithResource: USERS WithID:@"sonarbear" WithSubresource:@"favorites" WithCallback:^(SCResponse *response)
    {
        NSLog(@"appdelegate callback launched");
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

@end