//
//  SCTracksResponse.m
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "SCTracksResponse.h"

@implementation SCTracksResponse

-(void)addTrackInfo:(SCTrackInfo*)info
{
    [[self result] addObject:info];
    return;
}

-(id)init
{
    if (self = [super init])
    {
        [self setResourceType:TRACKS];
    }
    return self;
}

@end
