//
//  SCRequest.h
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCResponse;

@interface SCRequest : NSObject

@property int limit;
@property (strong) NSString* resource;
@property (strong) NSString *id;
@property (strong) NSString *subresource;
@property (strong) int(^callback)(SCResponse*);

@end
