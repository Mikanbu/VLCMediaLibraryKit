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

#import "VLCMLObject.h"

@class VLCMLArtist, VLCMLMedia, VLCMLGenre;

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);

@interface VLCMLAlbum : NSObject <VLCMLObject>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy) NSURL *artworkMrl;
@property (nonatomic, copy) VLCMLArtist *albumArtist;

/**
 * @brief Tracks represent the last query of tracks asked to the MediaLibrary.
 * If no previous query has been done, a default set of track will be returned.
 * @return Array of `VLCMLMedia *`.
 */
@property (nonatomic, copy) NSArray<VLCMLMedia *> *tracks;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;
- (NSString *)title;
- (uint)releaseYear;
- (NSString *)shortSummary;

/**
 * @brief isThumbnailGenerated Returns true is a thumbnail generation was attempted.
 *
 * If the thumbnail generation failed, this will still return true, and the
 * associated thumbnail mrl will be empty.
 */
- (BOOL)isArtworkGenerated;
- (NSURL *)artworkMrl;

- (VLCMLArtist *)albumArtist;

- (NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;
- (NSArray<VLCMLMedia *> *)tracksByGenre:(VLCMLGenre *)genre sortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

/**
 * Returns an array of VLCMLArtist object.
 */
- (NSArray<VLCMLArtist *> *)artistWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

- (UInt32)numberOfTracks;
- (uint)duration;

@end
