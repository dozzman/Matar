//
//  SCAPI.h
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCRequest;
@class SCResponse;

@interface SCAPI : NSObject

+(SCRequest*)newSCRequestWithResource:(int)resource WithCallback:(int (^)(SCResponse*))callback;
+(SCRequest*)newSCRequestWithResource:(int)resource WithID:(NSString*)id
                                                    WithCallback:(int (^)(SCResponse*))callback;
+(SCRequest*)newSCRequestWithResource:(int)resource WithID:(NSString*)id
                                                    WithSubresource:(NSString*)subresource
                                                    WithCallback:(int (^)(SCResponse*))callback;
+(SCAPI*)getInstance;
-(void)dispatch:(SCRequest*)request;

@end
