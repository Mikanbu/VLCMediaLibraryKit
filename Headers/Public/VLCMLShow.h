/*****************************************************************************
 * VLCMLShow.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2018 VLC authors and VideoLAN
 * $Id$
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#import "VLCMLObject.h"

@class VLCMLMedia;

@interface VLCMLShow : NSObject <VLCMLObject>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSDate *releaseDate;
@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy) NSURL *artworkMrl;
@property (nonatomic, copy) NSString *tvdbId;
@property (nonatomic, copy) NSArray<VLCMLMedia *> *episodes;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;
- (NSString *)title;
- (NSDate *)releaseDate;
- (NSString *)shortSummary;
- (NSURL *)artworkMrl;
- (NSString *)tvdbId;
- (NSArray<VLCMLMedia *> *)episodes;


@end

