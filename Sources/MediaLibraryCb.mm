/*****************************************************************************
 * MediaLibraryCb.cpp
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

#include "MediaLibraryCb.h"

#import "VLCAlbumTrack+Init.h"
#import "VLCUtils.h"

namespace medialibrary
{

MediaLibraryCb::MediaLibraryCb( id<VLCMediaLibraryDelegate> delegate )
    : m_delegate(delegate)
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
    this->m_delegate = delegate;
}

#pragma mark - Media

void MediaLibraryCb::onMediaAdded( std::vector<MediaPtr> media )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onMediaAdded:)]) {
        [this->m_delegate onMediaAdded:[VLCUtils arrayFromMediaPtrVector:media]];
    }
}

void MediaLibraryCb::onMediaUpdated( std::vector<MediaPtr> media )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onMediaUpdated:)]) {
        [this->m_delegate onMediaUpdated:[VLCUtils arrayFromMediaPtrVector:media]];
    }
}

void MediaLibraryCb::onMediaDeleted( std::vector<int64_t> mediaIds )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onMediaDeleted:)]) {
        [this->m_delegate onMediaDeleted:this->intVectorToArray(mediaIds)];
    }
}

#pragma mark - Artists

void MediaLibraryCb::onArtistsAdded( std::vector<ArtistPtr> artists )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onArtistsAdded:)]) {
        [this->m_delegate onArtistsAdded:[VLCUtils arrayFromArtistPtrVector:artists]];
    }
}

void MediaLibraryCb::onArtistsModified( std::vector<ArtistPtr> artists )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onArtistsModified:)]) {
        [this->m_delegate onArtistsModified:[VLCUtils arrayFromArtistPtrVector:artists]];
    }
}

void MediaLibraryCb::onArtistsDeleted( std::vector<int64_t> artistsIds )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onArtistsDeleted:)]) {
        [this->m_delegate onArtistsDeleted:this->intVectorToArray(artistsIds)];
    }
}

#pragma mark - Albums

void MediaLibraryCb::onAlbumsAdded( std::vector<AlbumPtr> albums )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onAlbumsAdded:)]) {
        [this->m_delegate onAlbumsAdded:[VLCUtils arrayFromAlbumPtrVector:albums]];
    }
}

void MediaLibraryCb::onAlbumsModified( std::vector<AlbumPtr> albums )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onAlbumsModified:)]) {
        [this->m_delegate onAlbumsModified:[VLCUtils arrayFromAlbumPtrVector:albums]];
    }
}

void MediaLibraryCb::onAlbumsDeleted( std::vector<int64_t> albumsIds )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onAlbumsDeleted:)]) {
        [this->m_delegate onAlbumsDeleted:this->intVectorToArray(albumsIds)];
    }
}

#pragma mark - Album trakcs

void MediaLibraryCb::onTracksAdded( std::vector<AlbumTrackPtr> tracks )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onTracksAdded:)]) {
        NSMutableArray *res = [NSMutableArray array];

        for ( const auto &track : tracks )
        {
            [res addObject:[[VLCAlbumTrack alloc] initWithAlbumTrackPtr:track]];
        }
        [this->m_delegate onTracksAdded:res];
    }
}

void MediaLibraryCb::onTracksDeleted( std::vector<int64_t> trackIds )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onTracksDeleted:)]) {
        [this->m_delegate onTracksDeleted:this->intVectorToArray(trackIds)];
    }
}

#pragma mark - Playlists

void MediaLibraryCb::onPlaylistsAdded( std::vector<PlaylistPtr> playlists )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onPlaylistsAdded:)]) {
        [this->m_delegate onPlaylistsAdded:[VLCUtils arrayFromPlaylistPtrVector:playlists]];
    }
}

void MediaLibraryCb::onPlaylistsModified( std::vector<PlaylistPtr> playlists )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onPlaylistsModified:)]) {
        [this->m_delegate onPlaylistsModified:[VLCUtils arrayFromPlaylistPtrVector:playlists]];
    }
}

void MediaLibraryCb::onPlaylistsDeleted( std::vector<int64_t> playlistIds )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onPlaylistsDeleted:)]) {
        [this->m_delegate onPlaylistsDeleted:this->intVectorToArray(playlistIds)];
    }
}

#pragma mark - Discovery

void MediaLibraryCb::onDiscoveryStarted( const std::string& entryPoint )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onDiscoveryStarted:)]) {
        [this->m_delegate onDiscoveryStarted:[[NSString alloc] initWithUTF8String:entryPoint.c_str()]];
    }
}

void MediaLibraryCb::onDiscoveryProgress( const std::string& entryPoint )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onDiscoveryProgress:)]) {
        [this->m_delegate onDiscoveryProgress:[[NSString alloc] initWithUTF8String:entryPoint.c_str()]];
    }

}

void MediaLibraryCb::onDiscoveryCompleted( const std::string& entryPoint )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onDiscoveryCompleted:)]) {
        [this->m_delegate onDiscoveryCompleted:[[NSString alloc] initWithUTF8String:entryPoint.c_str()]];
    }

}

#pragma mark - Reload

void MediaLibraryCb::onReloadStarted( const std::string& entryPoint )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onReloadStarted:)]) {
        [this->m_delegate onReloadStarted:[[NSString alloc] initWithUTF8String:entryPoint.c_str()]];
    }
}

void MediaLibraryCb::onReloadCompleted( const std::string& entryPoint )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onReloadCompleted:)]) {
        [this->m_delegate onReloadCompleted:[[NSString alloc] initWithUTF8String:entryPoint.c_str()]];
    }
}

#pragma mark - EntryPoints

void MediaLibraryCb::onEntryPointRemoved( const std::string& entryPoint, bool success )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onEntryPointRemoved:success:)]) {
        [this->m_delegate onEntryPointRemoved:[[NSString alloc] initWithUTF8String:entryPoint.c_str()] success:success];
    }
}

void MediaLibraryCb::onEntryPointBanned( const std::string& entryPoint, bool success )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onEntryPointBanned:success:)]) {
        [this->m_delegate onEntryPointBanned:[[NSString alloc] initWithUTF8String:entryPoint.c_str()] success:success];
    }

}

void MediaLibraryCb::onEntryPointUnbanned( const std::string& entryPoint, bool success )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onEntryPointUnbanned:success:)]) {
        [this->m_delegate onEntryPointUnbanned:[[NSString alloc] initWithUTF8String:entryPoint.c_str()] success:success];
    }
}

#pragma mark - Parsing
void MediaLibraryCb::onParsingStatsUpdated( uint32_t percent)
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onParsingStatsUpdated:)]) {
        [this->m_delegate onParsingStatsUpdated:percent];
    }
}

#pragma mark - Background
void MediaLibraryCb::onBackgroundTasksIdleChanged( bool isIdle )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onBackgroundTasksIdleChanged:)]) {
        [this->m_delegate onBackgroundTasksIdleChanged:isIdle];
    }
}

}// namespace - medialibrary
