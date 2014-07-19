//
//  TrackDatabase.m
//  Matar
//
//  Created by Dorian Peake on 05/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#include <sqlite3.h>
#import "TrackDatabase.h"
#import "SCTrackInfo.h"
#import "SCUserInfo.h"

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
    NSString * uriString = [[[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:databaseFilename] absoluteString];
    int rc = sqlite3_open_v2([uriString fileSystemRepresentation], &temp_db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_URI, NULL);
    if (rc)
    {
        sqlite3_close(temp_db);
        return rc;
    }
    
    // set up the database if neccessary
    const char * testForTable = "SELECT * FROM users";
    rc = sqlite3_exec(temp_db, testForTable, &sqlCallback, (void*)CALLBACK_TEST, NULL);
    if (rc)
    {
        rc = 0;
        const char * createUsers =  "CREATE TABLE users (                   "
                                    "   User_ID int NOT NULL,               "
                                    "   Username text NOT NULL,             "
                                    "   Avatar text,                        "
                                    "   PRIMARY KEY (User_ID)               "
                                    ");                                     ";
        const char * createLikes =  "CREATE TABLE likes (                   "
                                    "   User_ID int NOT NULL,               "
                                    "   Track_ID int NOT NULL,              "
                                    "   CONSTRAINT Like_ID PRIMARY KEY (User_ID, Track_ID)"
                                    ");                                     ";
        const char * createTracks = "CREATE TABLE tracks (                  "
                                    "   Track_ID int NOT NULL,              "
                                    "   Title text NOT NULL,                "
                                    "   Artist text NOT NULL,               "
                                    "   Genre text,                         "
                                    "   Date text,                          "
                                    "   Tag_list text,                      "
                                    "   Description text,                   "
                                    "   PRIMARY KEY (Track_ID)              "
                                    ");                                     ";
        
        rc += sqlite3_exec(temp_db, createTracks, &sqlCallback, (void*)CALLBACK_CREATE_TABLES, NULL);
        rc += sqlite3_exec(temp_db, createUsers, &sqlCallback, (void*)CALLBACK_CREATE_TABLES, NULL);
        rc += sqlite3_exec(temp_db, createLikes, &sqlCallback, (void*)CALLBACK_CREATE_TABLES, NULL);
        if (rc)
        {
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
        break;
        case CALLBACK_CREATE_TABLES:
        break;
    }
    return 0;
}

-(bool)addTrack:(SCTrackInfo *)track
{
    char buffer[165536];
    char SQLStatement[165536];
    strncpy(SQLStatement, "INSERT INTO tracks VALUES(", 165536);
    
    // ID
    sprintf(buffer, "%d",(int)track.ID);
    strncat(SQLStatement,buffer,strlen(buffer));
    strncat(SQLStatement,",",1);
    
    // title
    strncat(SQLStatement,"\"",1);
    NSString *title = [track.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(SQLStatement,[title UTF8String],[title length]);
    strncat(SQLStatement,"\"",1);
    strncat(SQLStatement,",",1);
    
    // artist
    strncat(SQLStatement,"\"",1);
    NSString *artist = [track.artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(SQLStatement,[artist UTF8String],[artist length]);
    strncat(SQLStatement,"\"",1);
    strncat(SQLStatement,",",1);
    
    // genre
    strncat(SQLStatement,"\"",1);
    NSString *genre = [track.genre stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(SQLStatement,[genre UTF8String],[genre length]);
    strncat(SQLStatement,"\"",1);
    strncat(SQLStatement,",",1);
    
    // date
    strncat(SQLStatement,"\"",1);
    const char * date = [[track.createdAt descriptionWithLocale:NSLocaleLanguageCode] UTF8String];
    strncat(SQLStatement,date,strlen(date));
    strncat(SQLStatement,"\"",1);
    strncat(SQLStatement,",",1);
    
    // taglist
    strncat(SQLStatement,"\"",1);
    NSString *tagList = [track.tagList stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(SQLStatement,[tagList UTF8String],[tagList length]);
    strncat(SQLStatement,"\"",1);
    strncat(SQLStatement,",",1);
    
    // description
    strncat(SQLStatement,"\"",1);
    NSString *description = [track.description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(SQLStatement,[description UTF8String],[description length]);
    strncat(SQLStatement,"\"",1);
    
    strncat(SQLStatement,")",1);
    
    int rc = sqlite3_exec(self.database, SQLStatement, &sqlCallback, (void*)NULL, NULL);
    
    if (rc)
    {
        //something went wrong
        return false;
    }
    return true;
}

-(bool)addUser:(SCUserInfo *)user
{

    return true;
}

-(bool)trackExists:(SCTrackInfo *)track
{

    return true;
}

-(bool)userExists:(SCUserInfo *)user
{

    return true;
}

@end
