/*****************************************************************************
 * MLUtils.m
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

#import "MLUtils.h"
#import "MLMedia+Init.h"
#import "MLAlbum+Init.h"
#import "MLArtist+Init.h"
#import "MLPlaylist+Init.h"

@implementation MLUtils

+ (NSArray<MLMedia *> *)arrayFromMediaPtrVector:(std::vector<medialibrary::MediaPtr>)media
{
    NSMutableArray *mediaList = [NSMutableArray array];

    for (const auto &medium : media) {
        [mediaList addObject:[[MLMedia alloc] initWithMediaPtr:medium]];
    }
    return mediaList;
}

+ (NSArray<MLAlbum *> *)arrayFromAlbumPtrVector:(std::vector<medialibrary::AlbumPtr>)albums
{
    NSMutableArray<MLAlbum *> *albumList = [NSMutableArray array];

    for (const auto &album : albums) {
        [albumList addObject:[[MLAlbum alloc] initWithAlbumPtr:album]];
    }
    return albumList;
}

+ (NSArray<MLArtist *> *)arrayFromArtistPtrVector:(std::vector<medialibrary::ArtistPtr>)artists
{
    NSMutableArray<MLArtist *> *artistList = [NSMutableArray array];

    for (const auto &artist : artists) {
        [artistList addObject:[[MLArtist alloc] initWithArtistPtr:artist]];
    }
    return artistList;
}

+ (NSArray<MLPlaylist *> *)arrayFromPlaylistPtrVector:(std::vector<medialibrary::PlaylistPtr>)playlists
{
    NSMutableArray<MLPlaylist *> *playlistList = [NSMutableArray array];

    for (const auto &playlist : playlists) {
        [playlistList addObject:[[MLPlaylist alloc] initWithPlaylistPtr:playlist]];
    }
    return playlistList;
}

@end
