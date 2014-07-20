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
@class SCTrackInfo;

@interface SCAPI : NSObject

+(SCRequest*)newSCRequestWithResource:(int)resource WithCallback:(void (^)(SCResponse*))callback;
+(SCRequest*)newSCRequestWithResource:(int)resource WithID:(NSString*)id
                                                    WithCallback:(void (^)(SCResponse*))callback;
+(SCRequest*)newSCRequestWithResource:(int)resource WithID:(NSString*)id
                                                    WithSubresource:(NSString*)subresource
                                                    WithCallback:(void (^)(SCResponse*))callback;
+(SCAPI*)getInstance;
-(void)dispatch:(SCRequest*)request;
-(void)downloadTrack:(SCTrackInfo*)trackInfo ToLocationWithURL:(NSURL*)location WithCallback:(void (^)(bool))callback;

@end
