//
//  AppDelegate.h
//  Matar
//
//  Created by Dorian Peake on 04/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class iTunesTrack;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong,readonly) NSMutableDictionary *plistDefaults;
@property (weak) IBOutlet NSTextField *downloadLocationText;

- (IBAction)setDownloadLocation:(id)sender;

@end
