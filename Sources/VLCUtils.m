/*****************************************************************************
 * VLCUtils.m
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

#import "VLCUtils.h"
#import "VLCMedia+Init.h"
#import "VLCAlbum+Init.h"
#import "VLCArtist+Init.h"
#import "VLCPlaylist+Init.h"
#import "VLCGenre+Init.h"

@implementation VLCUtils

+ (NSArray<VLCMedia *> *)arrayFromMediaPtrVector:(std::vector<medialibrary::MediaPtr>)media
{
    NSMutableArray *mediaList = [NSMutableArray array];

    for (const auto &medium : media) {
        [mediaList addObject:[[VLCMedia alloc] initWithMediaPtr:medium]];
    }
    return mediaList;
}

+ (NSArray<VLCAlbum *> *)arrayFromAlbumPtrVector:(std::vector<medialibrary::AlbumPtr>)albums
{
    NSMutableArray<VLCAlbum *> *albumList = [NSMutableArray array];

    for (const auto &album : albums) {
        [albumList addObject:[[VLCAlbum alloc] initWithAlbumPtr:album]];
    }
    return albumList;
}

+ (NSArray<VLCArtist *> *)arrayFromArtistPtrVector:(std::vector<medialibrary::ArtistPtr>)artists
{
    NSMutableArray<VLCArtist *> *artistList = [NSMutableArray array];

    for (const auto &artist : artists) {
        [artistList addObject:[[VLCArtist alloc] initWithArtistPtr:artist]];
    }
    return artistList;
}

+ (NSArray<VLCPlaylist *> *)arrayFromPlaylistPtrVector:(std::vector<medialibrary::PlaylistPtr>)playlists
{
    NSMutableArray<VLCPlaylist *> *playlistList = [NSMutableArray array];

    for (const auto &playlist : playlists) {
        [playlistList addObject:[[VLCPlaylist alloc] initWithPlaylistPtr:playlist]];
    }
    return playlistList;
}

+ (NSArray<VLCGenre *> *)arrayFromGenrePtrVector:(std::vector<medialibrary::GenrePtr>)genres
{
    NSMutableArray<VLCGenre *> *genreList = [NSMutableArray array];

    for (const auto &genre : genres) {
        [genreList addObject:[[VLCGenre alloc] initWithGenrePtr:genre]];
    }
    return genreList;
}

@end
