//
//  SCResponse.m
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "SCResponse.h"

@implementation SCResponse

-(id)init
{
    if (self = [super init])
    {
        [self setResult:[[NSMutableArray alloc] init]];
    }
    return self;
}

@end
