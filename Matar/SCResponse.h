//
//  SCResponse.h
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

enum SCResourceType
{
    USERS,
    TRACKS
};

@interface SCResponse : NSObject

@property int resourceType;
@property (strong) NSMutableArray *result;

@end
