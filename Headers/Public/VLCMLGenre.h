/*****************************************************************************
 * VLCMLGenre.h
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

typedef NS_ENUM (NSUInteger, VLCMLSortingCriteria);

@class VLCMLArtist, VLCMLMedia, VLCMLAlbum;

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLGenre : NSObject <VLCMLObject>

@property (nonatomic, copy) NSString *name;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;
- (UInt32)numberOfTracks;

- (nullable NSArray<VLCMLArtist *> *)artists;
- (nullable NSArray<VLCMLArtist *> *)artistWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                          desc:(BOOL)desc;

/**
 * @brief tracks Returns the tracks associated with this genre
 * @param withThumbnail True if only tracks with thumbnail should be fetched.
 *                      False if any track can be returned.
 * @param params Some query parameters, or nullptr for the default.
 *
 * This function supports sorting by:
 * - Duration
 * - InsertionDate
 * - ReleaseDate
 * - Alpha
 *
 * The default sort is to group tracks by their artist, album, disc number,
 * track number, and finally file name in case of ambiguous results.
 * Sort is ascending by default.
 */
- (nullable NSArray<VLCMLMedia *> *)tracks;
- (nullable NSArray<VLCMLMedia *> *)tracksWithThumbnails:(BOOL)thumbnails;
- (nullable NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;
- (nullable NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc
                                                   thumbnails:(BOOL)thumbnails;

- (nullable NSArray<VLCMLAlbum *> *)albums;
- (nullable NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;

@end

NS_ASSUME_NONNULL_END
