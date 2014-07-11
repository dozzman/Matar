//
//  TrackDatabase.h
//  Matar
//
//  Created by Dorian Peake on 05/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

// debgugging macros
#define DEBUG_ENABLED

#ifdef DEBUG_ENABLED
#define debugLog(...) NSLog(__VA_ARGS__)
#else
#define debugLog(...)
#endif

#import <Foundation/Foundation.h>

enum CALLBACK_ID {
    CALLBACK_TEST,
    CALLBACK_CREATE_TABLES
};

// database object which manages the SQLite3 track database of downloaded songs
@interface TrackDatabase : NSObject

+(TrackDatabase*)getInstance;

@end