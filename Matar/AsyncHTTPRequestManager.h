//
//  AsyncHTTPRequestManager.h
//  Matar
//
//  Created by Dorian Peake on 14/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncHTTPRequestManager : NSObject

@property (strong) NSNumber *maxConnections;
@property (strong, readonly) NSNumber *connectionCount;     // total number of concurrent active connections

-(void)queueRequest:(NSURLRequest*)request;
-(void)queueRequest:(NSURLRequest*)request WithCallback:(void (^)(NSData*))callback;
-(id)initWithMaxConnections:(NSUInteger);

@end
