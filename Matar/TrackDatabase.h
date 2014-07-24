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
-(int)addTrack:(SCTrackInfo*)track;
-(int)addUser:(SCUserInfo*)user;
-(int)trackExists:(SCTrackInfo*)track WithCallback:(void (^)(bool))callback;
-(int)trackExistsWithID:(NSUInteger)ID WithCallback:(void (^)(bool))callback;
-(int)userExists:(SCUserInfo*)user WithCallback:(void (^)(bool))callback;
-(int)userExistsWithID:(NSUInteger)ID WithCallback:(void (^)(bool))callback;
-(void)cleanup;

@end