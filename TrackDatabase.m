//
//  TrackDatabase.m
//  Matar
//
//  Created by Dorian Peake on 05/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "TrackDatabase.h"
#include <sqlite3.h>

@interface TrackDatabase ()

@property sqlite3 *database;

-(int)openDatabase;

@end

@implementation TrackDatabase

static NSString * const databaseFilename = @"track_db.sqlite3";
static int sqlCallback(void *NotUsed, int colCount, char **colValue, char **colName);

+(TrackDatabase*)getInstance
{
    static TrackDatabase *singleton = nil;
    static dispatch_once_t makeSingleton;
    
    dispatch_once(&makeSingleton,
    ^{
        singleton = [[TrackDatabase alloc] init];
        [singleton openDatabase];
    });
    
    return singleton;
}


-(int)openDatabase
{
    TrackDatabase *track_db = self;
    
    // attempt to open the database
    sqlite3 *temp_db;
    NSString * uri_string = [[[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:databaseFilename] absoluteString];
    int rc = sqlite3_open_v2([uri_string fileSystemRepresentation], &temp_db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_URI, NULL);
    if (rc)
    {
        debugLog(@"Unable to open database file at %@",uri_string);
        sqlite3_close(temp_db);
        return rc;
    }
    
    // set up the database if neccessary
    const char * testForTable = "SELECT * FROM users";
    rc = sqlite3_exec(temp_db, testForTable, &sqlCallback, (void*)CALLBACK_TEST, NULL);
    if (rc)
    {
        const char * createTables = "CREATE TABLE users (                   "
                                    "   User_ID int NOT NULL,               "
                                    "   Username text NOT NULL,             "
                                    "   Avatar text,                        "
                                    "   PRIMARY KEY (User_ID)               "
                                    ");                                     "
                                    "CREATE TABLE likes (                   "
                                    "   User_ID int NOT NULL,               "
                                    "   Track_ID int NOT NULL,              "
                                    "   CONSTRAINT Like_ID PRIMARY KEY (User_ID, Track_ID)"
                                    ");                                     "
                                    "CREATE TABLE tracks (                  "
                                    "   Track_ID int NOT NULL,              "
                                    "   Title text NOT NULL,                "
                                    "   Artist text NOT NULL,               "
                                    "   Genre text,                         "
                                    "   Date text,                          "
                                    "   Tag_list text,                      "
                                    "   Description text                    "
                                    "   PRIMARY KEY (Track_ID)              "
                                    ");                                     ";
        
        rc = sqlite3_exec(temp_db, createTables, &sqlCallback, (void*)CALLBACK_CREATE_TABLES, NULL);
        if (rc)
        {
            debugLog(@"Unable to create the tables within the database.");
            sqlite3_close(temp_db);
            return rc;
        }
    }
    
    track_db.database = temp_db;
    return 0;
}

// sqlCallback deals with all callback responses from the sqlite3 database
static int sqlCallback(void *callbackID, int colCount, char **colValue, char **colName)
{
    switch ((int)callbackID)
    {
        case CALLBACK_TEST:
            // if we get here, the table exists and contains something
            debugLog(@"Table test returned non-empty");
        break;
        case CALLBACK_CREATE_TABLES:
            debugLog(@"New tables created");
        break;
    }
    return 0;
}

@end
