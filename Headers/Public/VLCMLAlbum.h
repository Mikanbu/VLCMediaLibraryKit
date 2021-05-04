/*****************************************************************************
 * VLCMLAlbum.h
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

#import <Foundation/Foundation.h>
#import "VLCMLObject.h"

@class VLCMLArtist, VLCMLMedia, VLCMLGenre;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);
typedef NS_ENUM(NSUInteger, VLCMLThumbnailSizeType);
typedef NS_ENUM(NSUInteger, VLCMLThumbnailStatus);

@interface VLCMLAlbum : NSObject <VLCMLObject>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy, nullable) VLCMLArtist *albumArtist;

/**
 * @brief Tracks represent the last query of tracks asked to the MediaLibrary.
 * If no previous query has been done, a default set of track will be returned.
 * @return Array of `VLCMLMedia *`.
 */
@property (nonatomic, copy, nullable) NSArray<VLCMLMedia *> *tracks;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;
- (uint)releaseYear;

/**
 * @brief isArtworkGenerated Returns true is a thumbnail generation was
 *                             attempted for the provided size.
 *
 * @param sizeType The targeted thumbnail size
 *
 * If the thumbnail generation failed, this will still return true, and the
 * associated thumbnail mrl will be empty.
 * \note By default this queries the thumbnail of type VLCMLThumbnailSizeTypeThumbnail
 */
- (VLCMLThumbnailStatus)isArtworkGenerated;
- (VLCMLThumbnailStatus)isArtworkGeneratedForType:(VLCMLThumbnailSizeType)type;

/**
 * \brief artworkMRL Returns the mrl of an artwork of the given size for an album
 * \param sizeType The targeted artwork size
 * \return An mrl, representing the absolute path to the album artwork
 *         or nil, if the artwork generation failed
 *
 * \note By default this returns the mrl for VLCMLThumbnailSizeTypeThumbnail
 * \sa{isArtworkGenerated}
 */
- (nullable NSURL *)artworkMRL;
- (nullable NSURL *)artworkMRLOfType:(VLCMLThumbnailSizeType)type;

- (nullable NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;

- (nullable NSArray<VLCMLMedia *> *)tracksByGenre:(VLCMLGenre *)genre
                                  sortingCriteria:(VLCMLSortingCriteria)criteria
                                             desc:(BOOL)desc;

/**
 * Returns an array of VLCMLArtist object.
 */
- (nullable NSArray<VLCMLArtist *> *)artists;
- (nullable NSArray<VLCMLArtist *> *)artistWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                          desc:(BOOL)desc;

- (UInt32)numberOfTracks;
- (UInt32)numberOfDiscs;
- (SInt64)duration;

- (BOOL)isUnknownAlbum;

- (nullable NSArray<VLCMLMedia *> *)searchTracks:(NSString *)pattern;
- (nullable NSArray<VLCMLMedia *> *)searchTracks:(NSString *)pattern
                                 sortingCriteria:(VLCMLSortingCriteria)criteria
                                            desc:(BOOL)desc;

@end

NS_ASSUME_NONNULL_END
