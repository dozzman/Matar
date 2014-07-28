//
//  SCiTunesInterface.h
//  Matar
//
//  Created by Dorian Peake on 28/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class iTunesTrack;
@class SCTrackInfo;

@interface SCiTunesInterface : NSObject

+(iTunesTrack*) iTunesTrackWithSCTrackInfo:(SCTrackInfo*)trackInfo;
+

@end
