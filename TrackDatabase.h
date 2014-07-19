//
//  TrackDatabase.h
//  Matar
//
//  Created by Dorian Peake on 05/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCTrackInfo;
@class SCUserInfo;

enum CALLBACK_ID {
    CALLBACK_TEST,
    CALLBACK_CREATE_TABLES
};

// database object which manages the SQLite3 track database of downloaded songs
@interface TrackDatabase : NSObject

+(TrackDatabase*)getInstance;
-(bool)addTrack:(SCTrackInfo*)track;
-(bool)addUser:(SCUserInfo*)user;
-(bool)trackExists:(SCTrackInfo*)track;
-(bool)trackExistsWithID:(NSUInteger)ID;
-(bool)userExists:(SCUserInfo*)user;
-(bool)userExistsWithID:(NSUInteger)ID;

@end