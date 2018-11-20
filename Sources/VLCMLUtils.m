/*****************************************************************************
 * VLCMLUtils.m
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

#import "VLCMLUtils.h"
#import "VLCMLMedia+Init.h"
#import "VLCMLAlbum+Init.h"
#import "VLCMLArtist+Init.h"
#import "VLCMLPlaylist+Init.h"
#import "VLCMLGenre+Init.h"
#import "VLCMLFolder+Init.h"

@implementation VLCMLUtils

+ (NSArray<VLCMLMedia *> *)arrayFromMediaPtrVector:(std::vector<medialibrary::MediaPtr>)media
{
    NSMutableArray *mediaList = [NSMutableArray array];

    for (const auto &medium : media) {
        [mediaList addObject:[[VLCMLMedia alloc] initWithMediaPtr:medium]];
    }
    return [mediaList copy];
}

+ (NSArray<VLCMLAlbum *> *)arrayFromAlbumPtrVector:(std::vector<medialibrary::AlbumPtr>)albums
{
    NSMutableArray<VLCMLAlbum *> *albumList = [NSMutableArray array];

    for (const auto &album : albums) {
        [albumList addObject:[[VLCMLAlbum alloc] initWithAlbumPtr:album]];
    }
    return [albumList copy];
}

+ (NSArray<VLCMLArtist *> *)arrayFromArtistPtrVector:(std::vector<medialibrary::ArtistPtr>)artists
{
    NSMutableArray<VLCMLArtist *> *artistList = [NSMutableArray array];

    for (const auto &artist : artists) {
        [artistList addObject:[[VLCMLArtist alloc] initWithArtistPtr:artist]];
    }
    return [artistList copy];
}

+ (NSArray<VLCMLPlaylist *> *)arrayFromPlaylistPtrVector:(std::vector<medialibrary::PlaylistPtr>)playlists
{
    NSMutableArray<VLCMLPlaylist *> *playlistList = [NSMutableArray array];

    for (const auto &playlist : playlists) {
        [playlistList addObject:[[VLCMLPlaylist alloc] initWithPlaylistPtr:playlist]];
    }
    return [playlistList copy];
}

+ (NSArray<VLCMLGenre *> *)arrayFromGenrePtrVector:(std::vector<medialibrary::GenrePtr>)genres
{
    NSMutableArray<VLCMLGenre *> *genreList = [NSMutableArray array];

    for (const auto &genre : genres) {
        [genreList addObject:[[VLCMLGenre alloc] initWithGenrePtr:genre]];
    }
    return [genreList copy];
}

+ (NSArray<VLCMLFolder *> *)arrayFromFolderPtrVector:(std::vector<medialibrary::FolderPtr>)folders
{
    NSMutableArray<VLCMLFolder *> *folderList = [NSMutableArray array];

    for (const auto &folder : folders) {
        [folderList addObject:[[VLCMLFolder alloc] initWithFolderPtr:folder]];
    }
    return [folderList copy];
}

+ (medialibrary::QueryParameters)queryParamatersFromSort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    return medialibrary::QueryParameters {
        .sort = (medialibrary::SortingCriteria)criteria,
        .desc = static_cast<bool>(desc)
    };
}

@end
