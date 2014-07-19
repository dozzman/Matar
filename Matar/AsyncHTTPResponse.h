//
//  AsyncHTTPResponse.h
//  Matar
//
//  Created by Dorian Peake on 19/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncHTTPResponse : NSObject

@property (strong,readonly) NSError *error;
@property (strong,readonly) NSData *data;

-(id)initWithError:(NSError*)error;
-(id)initWithData:(NSData*)newData;

@end
