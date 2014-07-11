//
//  SCTracksResponse.h
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "SCResponse.h"

@class SCTrackInfo;

@interface SCTracksResponse : SCResponse

-(void)addTrackInfo:(SCTrackInfo*)info;
-(id)init;

@end
