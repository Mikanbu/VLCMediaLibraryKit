/*****************************************************************************
 * VLCMLArtist.h
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

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);

@class VLCMLAlbum, VLCMLMedia;

@interface VLCMLArtist : NSObject <VLCMLObject>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortBio;
@property (nonatomic, copy) NSURL *artworkMrl;
@property (nonatomic, copy) NSString *musicBrainzId;


- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;

- (NSString *)name;
- (NSString *)shortBio;

/**
 * @brief isThumbnailGenerated Returns true is a thumbnail generation was attempted.
 *
 * If the thumbnail generation failed, this will still return true, and the
 * associated thumbnail mrl will be empty.
 */
- (BOOL)isArtworkGenerated;
- (NSURL *)artworkMrl;
- (NSString *)musicBrainzId;

/**
 * Return all albums from the current artist.
 * \return a NSArray of VLCMLAlbum object.
 */
- (NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

/**
 * Return all medias from the current artist.
 * \return a NSArray of VLCMLMedia object.
 */
- (NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

@end
