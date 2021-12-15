/*****************************************************************************
 * VLCMLShow.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2021 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
 *          Pierre d'Herbemont <pdherbemont # videolan.org>
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

#import <Foundation/Foundation.h>
#import "VLCMLObject.h"

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);

@class VLCMLMedia;

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLShow : NSObject <VLCMLObject>

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSDate *releaseDate;
@property (nonatomic, copy, readonly) NSString *shortSummary;
@property (nonatomic, copy, readonly) NSURL *artworkMrl;
@property (nonatomic, copy, readonly) NSString *tvdbId;
@property (nonatomic, copy, nullable, readonly) NSArray<VLCMLMedia *> *episodes;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;

- (nullable NSArray<VLCMLMedia *> *)episodesWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                           desc:(BOOL)desc;

- (nullable NSArray<VLCMLMedia *> *)searchEpisodesWithPattern:(NSString *)pattern
                                                         sort:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;

- (UInt32)numberOfSeasons;
- (UInt32)numberOfEpisodes;

@end

NS_ASSUME_NONNULL_END
