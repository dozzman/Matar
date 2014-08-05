//
//  AsyncHTTPResponse.m
//  Matar
//
//  Created by Dorian Peake on 19/07/2014.
//
//  Matar, the Soundcloud Precipitation Inducer.
//  Copyright (C) 2014  Dorian Peake
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


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
