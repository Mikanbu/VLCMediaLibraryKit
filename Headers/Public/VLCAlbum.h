/*****************************************************************************
 * VLCAlbum.h
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

@class VLCArtist, VLCMedia, VLCGenre;

typedef NS_ENUM(NSUInteger, VLCSortingCriteria);

@interface VLCAlbum : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy) NSString *artworkMrl;

/**
 * @brief Tracks represent the last query of tracks asked to the MediaLibrary.
 * If no previous query has been done, a default set of track will be returned.
 * @return Array of `VLCMedia *`.
 */
@property (nonatomic, copy) NSArray<VLCMedia *> *tracks;

- (instancetype)init NS_UNAVAILABLE;

- (int64_t)identifier;
- (NSString *)title;
- (uint)releaseYear;
- (NSString *)shortSummary;
- (NSString *)artworkMrl;

- (VLCArtist *)albumMainArtist;

- (NSArray<VLCMedia *> *)tracks;
- (NSArray<VLCMedia *> *)tracksWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc;
- (NSArray<VLCMedia *> *)tracksByGenre:(VLCGenre *)genre sortingCriteria:(VLCSortingCriteria)criteria;

/**
 * Returns an array of VLCArtist object.
 */
- (NSArray<VLCArtist *> *)artistsByDesc:(BOOL)desc;

- (uint32_t)numberOfTracks;
- (uint)duration;

@end
