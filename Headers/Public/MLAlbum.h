/*****************************************************************************
 * MLAlbum.h
 * MediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2017 VLC authors and VideoLAN
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

@class MLArtist, MLMedia, MLGenre;

typedef NS_ENUM(NSUInteger, MLSortingCriteria);

@interface MLAlbum : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *shortSummary;
@property (nonatomic, strong) NSString *artworkMrl;

- (instancetype)init NS_UNAVAILABLE;

- (int64_t)identifier;
- (NSString *)title;
- (uint)releaseYear;
- (NSString *)shortSummary;
- (NSString *)artworkMrl;

- (MLArtist *)albumMainArtist;

- (NSArray<MLMedia *> *)tracksWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc;
- (NSArray<MLMedia *> *)tracksByGenre:(MLGenre *)genre sortingCriteria:(MLSortingCriteria)criteria;

/**
 * Returns an array of MLArtist object.
 */
- (NSArray<MLArtist *> *)artistsOrderedBy:(BOOL)desc;

- (uint32_t)numberOfTracks;
- (uint)duration;

@end
