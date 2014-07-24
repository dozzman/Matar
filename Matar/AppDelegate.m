//
//  AppDelegate.m
//  Matar
//
//  Created by Dorian Peake on 04/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "AppDelegate.h"
#include <sqlite3.h>
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
@property (strong) NSMutableDictionary *plistDefaults;

-(void)testcode;

@end

@implementation AppDelegate

-(id)init
{
    if (self = [super init])
    {
        // set up default download directory
        NSError *err = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *defaultDownloadDirectory = [fileManager URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:NULL create:NO error:&err];
        NSMutableDictionary *defaultPlistDefaults = [NSMutableDictionary dictionaryWithObjectsAndKeys:[defaultDownloadDirectory path],@"DownloadLocation", nil];
        
        [self setRequestManager:[[AsyncHTTPRequestManager alloc] init]];
        [self setPlistDefaults:defaultPlistDefaults];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError *err;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *plistURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Defaults.plist"];
    
    // if doesnt exist, create the file and store the default data inside
    bool success = [fileManager fileExistsAtPath:[plistURL path]];
    
    if (!success)
    {
        NSData *defaultPlistData = [NSPropertyListSerialization dataWithPropertyList:[self plistDefaults] format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];
        
        if (err != nil)
        {
            NSLog(@"Failed to serialise the default property list data");
            return;
        }
        
        if (![fileManager createFileAtPath:[plistURL path] contents:defaultPlistData attributes:NULL])
        {
            NSLog(@"Failed to create %@",[plistURL path]);
            return;
        }
    }
    
    // load the property list file
    NSData *plistData = [NSData dataWithContentsOfURL:plistURL];
    if (plistData == nil)
    {
        NSLog(@"Failed to load property list data from file");
        return;
    }
    
    NSMutableDictionary *plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListMutableContainers format:NULL error:&err];
    
    
    if (err != nil)
    {
        // error whilst loading the property list file
        NSLog(@"Failed to serialise property list");
        return;
    }
    
    [self setPlistDefaults:plist];
    
    NSEnumerator *enumerator = [[self plistDefaults] keyEnumerator];
    
    NSString *key = nil;
    NSLog(@"Enumerating dictionary...");
    
    while (key = [enumerator nextObject])
    {
        NSLog(@"%@ = %@",key,[[self plistDefaults] objectForKey:key]);
    }
    
    // run the test code for now
    [self testcode];
}

// test code separates production code from testing
-(void)testcode
{
    // currently test code requests a bunch of information about users or tracks from soundcloud and stores them
    // in the SQL database
    
    // set the textfield to the value of the download folder location
    NSString *downloadLocation = (NSString*)[[self plistDefaults] valueForKey:@"DownloadLocation"];
    //[[self downloadLocationText] setValue:downloadLocation];
    [[self downloadLocationText] setStringValue:downloadLocation];
    
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
                    NSLog(@"Artist: %@, Title: %@, Date: %@, StreamURL: %@",[track artist],[track title], [NSDateFormatter localizedStringFromDate:track.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle], [track.streamURL path]);
                }
            }
            break;
        }
    }];
    
    [[SCAPI getInstance] dispatch:newRequest];
}

- (IBAction)downloadLocation:(id)sender
{
    NSString *newDownloadLocation = [[self downloadLocationText] stringValue];
    NSMutableDictionary *plist = [self plistDefaults];
    
    [plist setValue:newDownloadLocation forKey:@"DownloadLocation"];
    return;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // save the plist file and close the sqlite3 database (if neccessary)
    NSMutableDictionary *plist = [self plistDefaults];
    NSError *err = nil;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];
    
    if (err != nil)
    {
        NSLog(@"Error serialising property list");
        return NSTerminateNow;
    }
    
    bool success = [plistData writeToURL:[[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Defaults.plist"] atomically:YES];
    
    if (!success)
    {
        NSLog(@"Failed to write property list to file");
        return NSTerminateNow;
    }
    
    [[TrackDatabase getInstance] cleanup];
    
    return NSTerminateNow;
}
@end