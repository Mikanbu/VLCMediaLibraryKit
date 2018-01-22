/*****************************************************************************
 * VLCArtist.h
 * MediaLibraryKit
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

typedef NS_ENUM(NSUInteger, VLCSortingCriteria);

@class VLCAlbum, VLCMedia;

@interface VLCArtist : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortBio;
@property (nonatomic, copy) NSString *artworkMrl;
@property (nonatomic, copy) NSString *musicBrainzId;


- (instancetype)init NS_UNAVAILABLE;

- (int64_t)identifier;

- (NSString *)name;
- (NSString *)shortBio;
- (NSString *)artworkMrl;
- (NSString *)musicBrainzId;

/**
 * Return all albums from the current artist.
 * \return a NSArray of VLCAlbum object.
 */
- (NSArray<VLCAlbum *> *)albums:(VLCSortingCriteria)sortingCriteria;

/**
 * Return all medias from the current artist.
 * \return a NSArray of VLCMedia object.
 */
- (NSArray<VLCMedia *> *)media:(VLCSortingCriteria)sortingCriteria;

@end
