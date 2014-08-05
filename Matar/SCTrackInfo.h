//
//  SCTrackInfo.h
//  Matar
//
//  Created by Dorian Peake on 10/07/2014.
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

@interface SCTrackInfo : NSObject

@property (strong) NSString *title;
@property NSInteger ID;
@property (strong) NSDate *createdAt;
@property (strong) NSString *tagList;
@property (strong) NSString *artist;
@property (strong) NSString *genre;
@property (strong) NSString *trackDescription;
@property (strong) NSURL *streamURL;
@property (strong) NSURL *coverURL;
@end
