//
//  AsyncHTTPResponse.m
//  Matar
//
//  Created by Dorian Peake on 19/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "AsyncHTTPResponse.h"

@interface AsyncHTTPResponse ()

@property (strong) NSError *error;
@property (strong) NSData *data;

@end

@implementation AsyncHTTPResponse

-(id)initWithError:(NSError*)error
{
    if (self = [super init])
    {
        [self setError:error];
    }
    return self;
}


-(id)initWithData:(NSData*)newData
{
    if (self = [super init])
    {
        [self setData:newData];
    }
    return self;
}
@end
