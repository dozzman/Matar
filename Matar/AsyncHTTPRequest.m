//
//  AsyncHTTPRequest.m
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


#import "AsyncHTTPRequest.h"

@interface AsyncHTTPRequest ()

@property (strong) NSURLRequest* request;
@property (strong) void (^callback)(AsyncHTTPResponse*);

@end

@implementation AsyncHTTPRequest

-(id)initWithRequest:(NSURLRequest*)request
{
    if (self = [super init])
    {
        [self setRequest:request];
    }
    return self;
}

-(id)initWithRequest:(NSURLRequest *)request WithCallback:(void (^)(AsyncHTTPResponse*))callback
{
    if (self = [super init])
    {
        [self setRequest:request];
        [self setCallback:callback];
    }
    return self;
}

@end
