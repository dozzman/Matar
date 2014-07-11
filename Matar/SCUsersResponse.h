//
//  SCUsersResponse.h
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "SCResponse.h"

@class SCUserInfo;

@interface SCUsersResponse : SCResponse

-(void)addUserInfo:(SCUserInfo*)info;
-(id)init;

@end
