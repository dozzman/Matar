//
//  SCUsersResponse.m
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "SCUsersResponse.h"

@implementation SCUsersResponse

-(void)addUserInfo:(SCUserInfo*)info
{
    [[self result] addObject:info];
    return;
}

-(id)init
{
    if (self = [super init])
    {
        [self setResourceType:USERS];
    }
    return self;
}

@end
