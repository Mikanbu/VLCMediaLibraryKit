/*****************************************************************************
 * VLCMLUtils.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2018-2022 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
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
#import "VLCMLMediaGroup+Init.h"
#import "VLCMLBookmark+Init.h"

@implementation VLCMLUtils

+ (nullable NSArray<VLCMLMedia *> *)arrayFromMediaQuery:(medialibrary::Query<medialibrary::IMedia>)mediaQuery
{
    if (!mediaQuery)
        return nil;
    return [self arrayFromMediaPtrVector:mediaQuery->all()];
}

+ (nullable NSArray<VLCMLAlbum *> *)arrayFromAlbumQuery:(medialibrary::Query<medialibrary::IAlbum>)albumQuery
{
    if (!albumQuery)
        return nil;
    return [self arrayFromAlbumPtrVector:albumQuery->all()];
}

+ (nullable NSArray<VLCMLArtist *> *)arrayFromArtistQuery:(medialibrary::Query<medialibrary::IArtist>)artistQuery
{
    if (!artistQuery)
        return nil;
    return [self arrayFromArtistPtrVector:artistQuery->all()];
}

+ (nullable NSArray<VLCMLPlaylist *> *)arrayFromPlaylistQuery:(medialibrary::Query<medialibrary::IPlaylist>)playlistQuery
{
    if (!playlistQuery)
        return nil;
    return [self arrayFromPlaylistPtrVector:playlistQuery->all()];
}

+ (nullable NSArray<VLCMLGenre *> *)arrayFromGenreQuery:(medialibrary::Query<medialibrary::IGenre>)genreQuery
{
    if (!genreQuery)
        return nil;
    return [self arrayFromGenrePtrVector:genreQuery->all()];
}

+ (nullable NSArray<VLCMLFolder *> *)arrayFromFolderQuery:(medialibrary::Query<medialibrary::IFolder>)folderQuery
{
    if (!folderQuery)
        return nil;
    return [self arrayFromFolderPtrVector:folderQuery->all()];
}

+ (nullable
   NSArray<VLCMLMediaGroup *> *)arrayFromMediaGroupQuery:(medialibrary::Query<medialibrary::IMediaGroup>)mediaGroupQuery
{
    if (!mediaGroupQuery)
        return nil;
    return [self arrayFromMediaGroupPtrVector:mediaGroupQuery->all()];
}

+ (NSArray<VLCMLMedia *> *)arrayFromMediaPtrVector:(const std::vector<medialibrary::MediaPtr>&)media
{
    NSMutableArray *mediaList = [NSMutableArray array];

    for (const auto &medium : media) {
        VLCMLMedia *mlMedium = [[VLCMLMedia alloc] initWithMediaPtr:medium];
        if (mlMedium) {
            [mediaList addObject:mlMedium];
        }
    }
    return [mediaList copy];
}

+ (NSArray<VLCMLAlbum *> *)arrayFromAlbumPtrVector:(const std::vector<medialibrary::AlbumPtr>&)albums
{
    NSMutableArray<VLCMLAlbum *> *albumList = [NSMutableArray array];

    for (const auto &album : albums) {
        VLCMLAlbum *mlAlbum = [[VLCMLAlbum alloc] initWithAlbumPtr:album];
        if (mlAlbum) {
            [albumList addObject:mlAlbum];
        }
    }
    return [albumList copy];
}

+ (NSArray<VLCMLArtist *> *)arrayFromArtistPtrVector:(const std::vector<medialibrary::ArtistPtr>&)artists
{
    NSMutableArray<VLCMLArtist *> *artistList = [NSMutableArray array];

    for (const auto &artist : artists) {
        VLCMLArtist *mlArtist = [[VLCMLArtist alloc] initWithArtistPtr:artist];
        if (mlArtist) {
            [artistList addObject:mlArtist];
        }
    }
    return [artistList copy];
}

+ (NSArray<VLCMLPlaylist *> *)arrayFromPlaylistPtrVector:(const std::vector<medialibrary::PlaylistPtr>&)playlists
{
    NSMutableArray<VLCMLPlaylist *> *playlistList = [NSMutableArray array];

    for (const auto &playlist : playlists) {
        VLCMLPlaylist *mlPlaylist = [[VLCMLPlaylist alloc] initWithPlaylistPtr:playlist];
        if (mlPlaylist) {
            [playlistList addObject:mlPlaylist];
        }
    }
    return [playlistList copy];
}

+ (NSArray<VLCMLGenre *> *)arrayFromGenrePtrVector:(const std::vector<medialibrary::GenrePtr>&)genres
{
    NSMutableArray<VLCMLGenre *> *genreList = [NSMutableArray array];

    for (const auto &genre : genres) {
        VLCMLGenre *mlGenre = [[VLCMLGenre alloc] initWithGenrePtr:genre];
        if (mlGenre) {
            [genreList addObject:mlGenre];
        }
    }
    return [genreList copy];
}

+ (NSArray<VLCMLFolder *> *)arrayFromFolderPtrVector:(const std::vector<medialibrary::FolderPtr>&)folders
{
    NSMutableArray<VLCMLFolder *> *folderList = [NSMutableArray array];

    for (const auto &folder : folders) {
        VLCMLFolder *mlFolder = [[VLCMLFolder alloc] initWithFolderPtr:folder];
        if (mlFolder) {
            [folderList addObject:mlFolder];
        }
    }
    return [folderList copy];
}

+ (NSArray<VLCMLMediaGroup *> *)arrayFromMediaGroupPtrVector:(const std::vector<medialibrary::MediaGroupPtr>&)mediaGroups
{
    NSMutableArray<VLCMLMediaGroup *> *mediaGroupList = [NSMutableArray array];

    for (const auto &mediaGroup : mediaGroups) {
        VLCMLMediaGroup *mlMediaGroup = [[VLCMLMediaGroup alloc] initWithMediaGroupPtr:mediaGroup];
        if (mlMediaGroup) {
            [mediaGroupList addObject:mlMediaGroup];
        }
    }
    return [mediaGroupList copy];
}

+ (NSArray<VLCMLBookmark *> *)arrayFromBookmarkPtrVector:(const std::vector<medialibrary::BookmarkPtr>&)bookmarks
{
    NSMutableArray<VLCMLBookmark *> *bookmarkList = [NSMutableArray array];

    for (const auto &bookmark : bookmarks) {
        VLCMLBookmark *mlBookmark = [[VLCMLBookmark alloc] initWithBookmarkPointer:bookmark];
        if (mlBookmark) {
            [bookmarkList addObject:mlBookmark];
        }
    }
    return [bookmarkList copy];
}

+ (medialibrary::QueryParameters)queryParamatersFromSort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    return medialibrary::QueryParameters {
        .sort = (medialibrary::SortingCriteria)criteria,
        .desc = static_cast<bool>(desc)
    };
}

@end
