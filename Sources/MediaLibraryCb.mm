/*****************************************************************************
 * MediaLibraryCb.cpp
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

#import "MediaLibraryCb.h"

#import "VLCMLMedia+Init.h"
#import "VLCMLUtils.h"

namespace medialibrary
{

MediaLibraryCb::MediaLibraryCb( VLCMediaLibrary *medialibrary, id<VLCMediaLibraryDelegate> delegate )
    : m_medialibrary(medialibrary), m_delegate(delegate)
{
}

#pragma mark - Private
NSArray<NSNumber *> *MediaLibraryCb::intVectorToArray( std::vector<int64_t> vector )
{
    NSMutableArray *res = [NSMutableArray array];

    for ( const auto &it : vector )
    {
        [res addObject:[NSNumber numberWithLongLong:it]];
    }
    return res;
}

#pragma mark - Setter

void MediaLibraryCb::setDelegate( id<VLCMediaLibraryDelegate> delegate )
{
    m_delegate = delegate;
}

#pragma mark - Media

void MediaLibraryCb::onMediaAdded( std::vector<MediaPtr> media )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didAddMedia:)]) {
        [m_delegate medialibrary:m_medialibrary didAddMedia:[VLCMLUtils arrayFromMediaPtrVector:media]];
    }
}

void MediaLibraryCb::onMediaUpdated( std::vector<MediaPtr> media )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didUpdateMedia:)]) {
        [m_delegate medialibrary:m_medialibrary didUpdateMedia:[VLCMLUtils arrayFromMediaPtrVector:media]];
    }
}

void MediaLibraryCb::onMediaDeleted( std::vector<int64_t> mediaIds )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didDeleteMediaWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary didDeleteMediaWithIds:intVectorToArray(mediaIds)];
    }
}

#pragma mark - Artists

void MediaLibraryCb::onArtistsAdded( std::vector<ArtistPtr> artists )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didAddArtists:)]) {
        [m_delegate medialibrary:m_medialibrary didAddArtists:[VLCMLUtils arrayFromArtistPtrVector:artists]];
    }
}

void MediaLibraryCb::onArtistsModified( std::vector<ArtistPtr> artists )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didModifyArtists:)]) {
        [m_delegate medialibrary:m_medialibrary didModifyArtists:[VLCMLUtils arrayFromArtistPtrVector:artists]];
    }
}

void MediaLibraryCb::onArtistsDeleted( std::vector<int64_t> artistsIds )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didDeleteArtistsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary didDeleteArtistsWithIds:intVectorToArray(artistsIds)];
    }
}

#pragma mark - Albums

void MediaLibraryCb::onAlbumsAdded( std::vector<AlbumPtr> albums )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didAddAlbums:)]) {
        [m_delegate medialibrary:m_medialibrary didAddAlbums:[VLCMLUtils arrayFromAlbumPtrVector:albums]];
    }
}

void MediaLibraryCb::onAlbumsModified( std::vector<AlbumPtr> albums )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didModifyAlbums:)]) {
        [m_delegate medialibrary:m_medialibrary didModifyAlbums:[VLCMLUtils arrayFromAlbumPtrVector:albums]];
    }
}

void MediaLibraryCb::onAlbumsDeleted( std::vector<int64_t> albumsIds )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didDeleteAlbumsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary didDeleteAlbumsWithIds:intVectorToArray(albumsIds)];
    }
}

#pragma mark - Playlists

void MediaLibraryCb::onPlaylistsAdded( std::vector<PlaylistPtr> playlists )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didAddPlaylists:)]) {
        [m_delegate medialibrary:m_medialibrary didAddPlaylists:[VLCMLUtils arrayFromPlaylistPtrVector:playlists]];
    }
}

void MediaLibraryCb::onPlaylistsModified( std::vector<PlaylistPtr> playlists )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didModifyPlaylists:)]) {
        [m_delegate medialibrary:m_medialibrary didModifyPlaylists:[VLCMLUtils arrayFromPlaylistPtrVector:playlists]];
    }
}

void MediaLibraryCb::onPlaylistsDeleted( std::vector<int64_t> playlistIds )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didDeletePlaylistsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary didDeletePlaylistsWithIds:intVectorToArray(playlistIds)];
    }
}

#pragma mark - Discovery

void MediaLibraryCb::onDiscoveryStarted( const std::string& entryPoint )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didStartDiscovery:)]) {
        [m_delegate medialibrary:m_medialibrary didStartDiscovery:[NSString stringWithUTF8String:entryPoint.c_str()]];
    }
}

void MediaLibraryCb::onDiscoveryProgress( const std::string& entryPoint )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didProgressDiscovery:)]) {
        [m_delegate medialibrary:m_medialibrary didProgressDiscovery:[NSString stringWithUTF8String:entryPoint.c_str()]];
    }

}

void MediaLibraryCb::onDiscoveryCompleted( const std::string& entryPoint, bool success )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didCompleteDiscovery:)]) {
        [m_delegate medialibrary:m_medialibrary didCompleteDiscovery:[NSString stringWithUTF8String:entryPoint.c_str()]];
    }
}

#pragma mark - Reload

void MediaLibraryCb::onReloadStarted( const std::string& entryPoint )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didStartReload:)]) {
        [m_delegate medialibrary:m_medialibrary didStartReload:[NSString stringWithUTF8String:entryPoint.c_str()]];
    }
}

void MediaLibraryCb::onReloadCompleted( const std::string& entryPoint, bool success )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didCompleteReload:)]) {
        [m_delegate medialibrary:m_medialibrary didCompleteReload:[NSString stringWithUTF8String:entryPoint.c_str()]];
    }
}

#pragma mark - EntryPoints

void MediaLibraryCb::onEntryPointRemoved( const std::string& entryPoint, bool success )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didRemoveEntryPoint:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary didRemoveEntryPoint:[NSString stringWithUTF8String:entryPoint.c_str()]
                     withSuccess:success];
    }
}

void MediaLibraryCb::onEntryPointBanned( const std::string& entryPoint, bool success )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didBanEntryPoint:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary didBanEntryPoint:[NSString stringWithUTF8String:entryPoint.c_str()]
                     withSuccess:success];
    }

}

void MediaLibraryCb::onEntryPointUnbanned( const std::string& entryPoint, bool success )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didUnbanEntryPoint:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary didUnbanEntryPoint:[NSString stringWithUTF8String:entryPoint.c_str()]
                     withSuccess:success];
    }
}

#pragma mark - Parsing
void MediaLibraryCb::onParsingStatsUpdated( uint32_t percent)
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didUpdateParsingStatsWithPercent:)]) {
        [m_delegate medialibrary:m_medialibrary didUpdateParsingStatsWithPercent:percent];
    }
}

#pragma mark - Background
void MediaLibraryCb::onBackgroundTasksIdleChanged( bool isIdle )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didChangeIdleBackgroundTasksWithSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary didChangeIdleBackgroundTasksWithSuccess:isIdle];
    }
}

void MediaLibraryCb::onMediaThumbnailReady( MediaPtr media, bool success )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:thumbnailReadyForMedia:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary thumbnailReadyForMedia:[[VLCMLMedia alloc] initWithMediaPtr:media]
                     withSuccess:success];
    }
}

}// namespace - medialibrary
