/*****************************************************************************
 * VLCMLSearchAggregate.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2017-2019 VLC authors and VideoLAN
 *
 * Author: Soomin Lee <bubu@mikan.io>
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
@class VLCMLAlbum, VLCMLArtist, VLCMLGenre, VLCMLMedia, VLCMLPlaylist;

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLSearchAggregate : NSObject

@property (nonatomic, copy, readonly, nullable) NSArray<VLCMLAlbum *> *albums;
@property (nonatomic, copy, readonly, nullable) NSArray<VLCMLArtist *> *artists;
@property (nonatomic, copy, readonly, nullable) NSArray<VLCMLGenre *> *genres;
@property (nonatomic, copy, readonly, nullable) NSArray<VLCMLMedia *> *media;
@property (nonatomic, copy, readonly, nullable) NSArray<VLCMLPlaylist *> *playlists;

+ (instancetype)initWithAlbums:(nullable NSArray<VLCMLAlbum *> *)albums
                       artists:(nullable NSArray<VLCMLArtist *> *)artists
                        genres:(nullable NSArray<VLCMLGenre *> *)genres
                         media:(nullable NSArray<VLCMLMedia *> *)media
                     playlists:(nullable NSArray<VLCMLPlaylist *> *)playlists;

@end

NS_ASSUME_NONNULL_END
