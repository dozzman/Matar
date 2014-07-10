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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    // TODO load client id from some file somewhere
    
    // Insert code here to initialize your application
    [SCAPI newSCRequestWithResource: USERS WithID:@"sonarbear" WithCallback:^(SCResponse *response)
    {
        NSLog(@"appdelegate callback launched");
        NSArray *result = [response result];
        
        long count = [result count];
        
        switch ([response resourceType])
        {
            case USERS:
            {
                //SCUsersResponse *userResponse = (SCUsersResponse*)response;
                NSLog(@"User list returned");
            }
            break;
            
            case TRACKS:
            {
                //SCTracksResponse *trackResponse = (SCTracksResponse*)response;
                
                for (long index = 0; index < count; index++)
                {
                    SCTrackInfo *track = [result objectAtIndex:index];
                    NSLog(@"%@",[track title]);
                }
            }
            break;
        }
        
        return 0;
    }];
}

@end