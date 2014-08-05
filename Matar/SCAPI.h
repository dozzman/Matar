//
//  SCAPI.h
//  Matar
//
//  Created by Dorian Peake on 09/07/2014.
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
