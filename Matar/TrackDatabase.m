//
//  TrackDatabase.m
//  Matar
//
//  Created by Dorian Peake on 04/07/2014.
//
//  Matar, the Soundcloud Precipitation Inducer.
//  Copyright (C) 2014  Dorian Peake
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#include <sqlite3.h>
#import "TrackDatabase.h"
#import "SCTrackInfo.h"
#import "SCUserInfo.h"

@interface TrackDatabase ()

@property sqlite3 *database;

@property char *buffer;         // buffers for construction of SQL querys
@property char *SQLStatement;   //  ""          ""

-(int)openDatabase;

@end

@implementation TrackDatabase

static NSString * const databaseFilename = @"track_db.sqlite3";
static int sqlExistsCallback(void *NotUsed, int colCount, char **colValue, char **colName);
static NSUInteger bufferSize = 165536*sizeof(char);

-(void)cleanup
{
    sqlite3_close([self database]);
    return;
}

-(id)init
{
    if (self = [super init])
    {
        [self setBuffer:malloc(bufferSize)];
        [self setSQLStatement:malloc(bufferSize)];
    }
    return self;
}

-(void)dealloc
{
    // singleton class so not really needed, just here for brevity and correctness
    free([self buffer]);
    free([self SQLStatement]);
}

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
    const char * testForTable = "SELECT EXISTS (SELECT name FROM sqlite_master WHERE type=\"table\" AND name=\"users\")";
    rc = sqlite3_exec(temp_db, testForTable, &sqlExistsCallback,
    (__bridge void*) ^(bool exists)
    {
        int rc2 = 0;
        if (!exists)
        {
            const char * createUsers =  "CREATE TABLE users (                   "
                                        "   User_ID int NOT NULL,               "
                                        "   Username text NOT NULL,             "
                                        "   AvatarURL text,                     "
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
                                        "   CoverURL text,                      "
                                        "   PRIMARY KEY (Track_ID)              "
                                        ");                                     ";
            
            // TODO currently assuming tables are created successfully if return value is zero
            // don't think this is always the case...
            rc2 += sqlite3_exec(temp_db, createTracks, NULL, (void*)CALLBACK_CREATE_TABLES, NULL);
            rc2 += sqlite3_exec(temp_db, createUsers, NULL, (void*)CALLBACK_CREATE_TABLES, NULL);
            rc2 += sqlite3_exec(temp_db, createLikes, NULL, (void*)CALLBACK_CREATE_TABLES, NULL);
            if (rc2)
            {
                sqlite3_close(temp_db);
                return;
            }
        }
    }, NULL);
    
    self.database = temp_db;
    return 0;
}

// sqlExistsCallback expects to be called from a query of the form 'SELECT EXISTS (...)'
// and provided with a callback which expects a boolean describing whether the query exists or not
static int sqlExistsCallback(void *block, int colCount, char **colValue, char **colName)
{
    void (^callback)(bool) = (__bridge void (^)(bool))block;
    bool result;
    if (atoi(colValue[0]) == 0)
    {
        result = false;
    }
    else
    {
        result = true;
    }
    
    callback(result);
    
    return 0;
}

-(int)addTrack:(SCTrackInfo *)track
{
    // TODO could more efficiently allocate buffer globally rather than on every stack call
    strncpy(self.SQLStatement, "INSERT INTO tracks VALUES(", bufferSize);
    
    // ID
    sprintf(self.buffer, "%d",(int)track.ID);
    strncat(self.SQLStatement,self.buffer,strlen(self.buffer));
    strncat(self.SQLStatement,",",1);
    
    // title
    strncat(self.SQLStatement,"\"",1);
    NSString *title = [track.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(self.SQLStatement,[title UTF8String],[title length]);
    strncat(self.SQLStatement,"\"",1);
    strncat(self.SQLStatement,",",1);
    
    // artist
    strncat(self.SQLStatement,"\"",1);
    NSString *artist = [track.artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(self.SQLStatement,[artist UTF8String],[artist length]);
    strncat(self.SQLStatement,"\"",1);
    strncat(self.SQLStatement,",",1);
    
    // genre
    strncat(self.SQLStatement,"\"",1);
    NSString *genre = [track.genre stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(self.SQLStatement,[genre UTF8String],[genre length]);
    strncat(self.SQLStatement,"\"",1);
    strncat(self.SQLStatement,",",1);
    
    // date
    strncat(self.SQLStatement,"\"",1);
    const char * date = [[track.createdAt descriptionWithLocale:NSLocaleLanguageCode] UTF8String];
    strncat(self.SQLStatement,date,strlen(date));
    strncat(self.SQLStatement,"\"",1);
    strncat(self.SQLStatement,",",1);
    
    // taglist
    strncat(self.SQLStatement,"\"",1);
    NSString *tagList = [track.tagList stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(self.SQLStatement,[tagList UTF8String],[tagList length]);
    strncat(self.SQLStatement,"\"",1);
    strncat(self.SQLStatement,",",1);
    
    // description
    strncat(self.SQLStatement,"\"",1);
    NSString *description = [track.description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(self.SQLStatement,[description UTF8String],[description length]);
    strncat(self.SQLStatement,"\"",1);
    strncat(self.SQLStatement,",",1);
    
    // coverURL
    strncat(self.SQLStatement,"\"",1);
    NSString *coverURL = [[track.coverURL absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(self.SQLStatement,[coverURL UTF8String],[coverURL length]);
    strncat(self.SQLStatement,"\"",1);
    
    
    strncat(self.SQLStatement,")",1);
    
    int rc = sqlite3_exec(self.database, self.SQLStatement, NULL, (void*)NULL, NULL);
    
    return rc;
}

-(int)addUser:(SCUserInfo *)user
{

    strncpy(self.SQLStatement, "INSERT INTO users VALUES(", bufferSize);
    
    // ID
    sprintf(self.buffer, "%d",(int)user.ID);
    strncat(self.SQLStatement,self.buffer,strlen(self.buffer));
    strncat(self.SQLStatement,",",1);
    
    // username
    strncat(self.SQLStatement,"\"",1);
    NSString *userName = [user.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(self.SQLStatement,[userName UTF8String],[userName length]);
    strncat(self.SQLStatement,"\"",1);
    strncat(self.SQLStatement,",",1);
    
    // avatarURL
    strncat(self.SQLStatement,"\"",1);
    NSString *avatarURL = [[user.avatarURL absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strncat(self.SQLStatement,[avatarURL UTF8String],[avatarURL length]);
    strncat(self.SQLStatement,"\"",1);
    
    strncat(self.SQLStatement,")",1);
    
    int rc = sqlite3_exec(self.database, self.SQLStatement, NULL, (void*)NULL, NULL);
    
    return rc;
}

-(int)trackExists:(SCTrackInfo *)track WithCallback:(void (^)(bool))callback
{
    return [self trackExistsWithID:track.ID WithCallback:callback];
}

-(int)trackExistsWithID:(NSUInteger)ID WithCallback:(void (^)(bool))callback
{
    sprintf(self.SQLStatement, "SELECT EXISTS (SELECT * FROM tracks WHERE Track_ID = %d LIMIT 1)", (int)ID);
    
    int rc = sqlite3_exec([[TrackDatabase getInstance] database], self.SQLStatement, &sqlExistsCallback,(__bridge void*)callback,NULL);

    return rc;
    
}

-(int)userExists:(SCUserInfo *)user WithCallback:(void (^)(bool))callback
{

    return [self userExistsWithID:user.ID WithCallback:callback];
}

-(int)userExistsWithID:(NSUInteger)ID WithCallback:(void (^)(bool))callback
{
    sprintf(self.SQLStatement, "SELECT EXISTS (SELECT * FROM users WHERE User_ID = %d LIMIT 1)", (int)ID);
    
    int rc = sqlite3_exec([[TrackDatabase getInstance] database], self.SQLStatement, &sqlExistsCallback,(__bridge void*)callback,NULL);

    return rc;
}

@end
