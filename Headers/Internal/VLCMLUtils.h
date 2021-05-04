/*****************************************************************************
 * VLCMLUtils.h
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

@class VLCMLMedia, VLCMLAlbum, VLCMLArtist, VLCMLPlaylist, VLCMLGenre, VLCMLFolder, VLCMLMediaGroup;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);

@interface VLCMLUtils : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (nullable NSArray<VLCMLMedia *> *)arrayFromMediaQuery:(medialibrary::Query<medialibrary::IMedia>)mediaQuery;
+ (nullable NSArray<VLCMLAlbum *> *)arrayFromAlbumQuery:(medialibrary::Query<medialibrary::IAlbum>)albumQuery;
+ (nullable NSArray<VLCMLArtist *> *)arrayFromArtistQuery:(medialibrary::Query<medialibrary::IArtist>)artistQuery;
+ (nullable NSArray<VLCMLPlaylist *> *)arrayFromPlaylistQuery:(medialibrary::Query<medialibrary::IPlaylist>)playlistQuery;
+ (nullable NSArray<VLCMLGenre *> *)arrayFromGenreQuery:(medialibrary::Query<medialibrary::IGenre>)genreQuery;
+ (nullable NSArray<VLCMLFolder *> *)arrayFromFolderQuery:(medialibrary::Query<medialibrary::IFolder>)folderQuery;
+ (nullable
   NSArray<VLCMLMediaGroup *> *)arrayFromMediaGroupQuery:(medialibrary::Query<medialibrary::IMediaGroup>)mediaGroupQuery;

+ (NSArray<VLCMLMedia *> *)arrayFromMediaPtrVector:(std::vector<medialibrary::MediaPtr>)media;
+ (NSArray<VLCMLAlbum *> *)arrayFromAlbumPtrVector:(std::vector<medialibrary::AlbumPtr>)albums;
+ (NSArray<VLCMLArtist *> *)arrayFromArtistPtrVector:(std::vector<medialibrary::ArtistPtr>)artists;
+ (NSArray<VLCMLPlaylist *> *)arrayFromPlaylistPtrVector:(std::vector<medialibrary::PlaylistPtr>)playlists;
+ (NSArray<VLCMLGenre *> *)arrayFromGenrePtrVector:(std::vector<medialibrary::GenrePtr>)genres;
+ (NSArray<VLCMLFolder *> *)arrayFromFolderPtrVector:(std::vector<medialibrary::FolderPtr>)folders;
+ (NSArray<VLCMLMediaGroup *> *)arrayFromMediaGroupPtrVector:(std::vector<medialibrary::MediaGroupPtr>)mediaGroups;

+ (medialibrary::QueryParameters)queryParamatersFromSort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

@end

NS_ASSUME_NONNULL_END
