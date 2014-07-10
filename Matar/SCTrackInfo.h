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
@property NSInteger id;
@property (strong) NSDate *createdAt;
@property (strong) NSString *tagList;
@property (strong) NSString *userName;
@property (strong) NSURL *streamURL;

@end
