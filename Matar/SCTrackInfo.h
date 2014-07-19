//
//  SCTrackInfo.h
//  Matar
//
//  Created by Dorian Peake on 10/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCTrackInfo : NSObject

@property (strong) NSString *title;
@property NSInteger ID;
@property (strong) NSDate *createdAt;
@property (strong) NSString *tagList;
@property (strong) NSString *artist;
@property (strong) NSString *genre;
@property (strong) NSString *description;
@property (strong) NSURL *streamURL;
@property (strong) NSURL *coverURL;
@end
