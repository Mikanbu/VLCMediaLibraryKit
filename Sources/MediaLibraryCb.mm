/*****************************************************************************
 * MediaLibraryCb.cpp
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2017-2020 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Carola Nitz <caro # videolan.org>
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

NSArray<NSNumber *> *MediaLibraryCb::intSetToArray( std::set<int64_t> set )
{
    NSMutableArray *res = [NSMutableArray array];

    for ( const auto &it : set )
    {
        [res addObject:[NSNumber numberWithLongLong:it]];
    }
    return [res copy];
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
        [m_delegate medialibrary:m_medialibrary
                     didAddMedia:[VLCMLUtils arrayFromMediaPtrVector:media]];
    }
}

void MediaLibraryCb::onMediaModified( std::set<int64_t> mediaIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didModifyMediaWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
           didModifyMediaWithIds:intSetToArray(mediaIds)];
    }
}

void MediaLibraryCb::onMediaDeleted( std::set<int64_t> mediaIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didDeleteMediaWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
           didDeleteMediaWithIds:intSetToArray(mediaIds)];
    }
}

void MediaLibraryCb::onMediaConvertedToExternal( std::set<int64_t> mediaIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didConvertMediaToExternal:)]) {
        [m_delegate medialibrary:m_medialibrary
       didConvertMediaToExternal:intSetToArray(mediaIds)];
    }
}

#pragma mark - Artists

void MediaLibraryCb::onArtistsAdded( std::vector<ArtistPtr> artists )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didAddArtists:)]) {
        [m_delegate medialibrary:m_medialibrary
                   didAddArtists:[VLCMLUtils arrayFromArtistPtrVector:artists]];
    }
}

void MediaLibraryCb::onArtistsModified( std::set<int64_t> artistsIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didModifyArtistsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
         didModifyArtistsWithIds:intSetToArray(artistsIds)];
    }
}

void MediaLibraryCb::onArtistsDeleted( std::set<int64_t> artistsIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didDeleteArtistsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
         didDeleteArtistsWithIds:intSetToArray(artistsIds)];
    }
}

#pragma mark - Albums

void MediaLibraryCb::onAlbumsAdded( std::vector<AlbumPtr> albums )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didAddAlbums:)]) {
        [m_delegate medialibrary:m_medialibrary
                    didAddAlbums:[VLCMLUtils arrayFromAlbumPtrVector:albums]];
    }
}

void MediaLibraryCb::onAlbumsModified( std::set<int64_t> albumsIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didModifyAlbumsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
          didModifyAlbumsWithIds:intSetToArray(albumsIds)];
    }
}

void MediaLibraryCb::onAlbumsDeleted( std::set<int64_t> albumsIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didDeleteAlbumsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
          didDeleteAlbumsWithIds:intSetToArray(albumsIds)];
    }
}

#pragma mark - Playlists

void MediaLibraryCb::onPlaylistsAdded( std::vector<PlaylistPtr> playlists )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didAddPlaylists:)]) {
        [m_delegate medialibrary:m_medialibrary
                 didAddPlaylists:[VLCMLUtils arrayFromPlaylistPtrVector:playlists]];
    }
}

void MediaLibraryCb::onPlaylistsModified( std::set<int64_t> playlistsIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didModifyPlaylistsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
       didModifyPlaylistsWithIds:intSetToArray(playlistsIds)];
    }
}

void MediaLibraryCb::onPlaylistsDeleted( std::set<int64_t> playlistIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didDeletePlaylistsWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
       didDeletePlaylistsWithIds:intSetToArray(playlistIds)];
    }
}

#pragma mark - Genres

void MediaLibraryCb::onGenresAdded( std::vector<GenrePtr> genres )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:didAddGenres:)]) {
        [m_delegate medialibrary:m_medialibrary
                    didAddGenres:[VLCMLUtils arrayFromGenrePtrVector:genres]];
    }
}

void MediaLibraryCb::onGenresModified( std::set<int64_t> genres )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didModifyGenresWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
          didModifyGenresWithIds:intSetToArray(genres)];
    }
}

void MediaLibraryCb::onGenresDeleted( std::set<int64_t> genresIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didDeleteGenresWithIds:)]) {
        [m_delegate medialibrary:m_medialibrary
          didDeleteGenresWithIds:intSetToArray(genresIds)];
    }
}

#pragma mark - Media Groups

void MediaLibraryCb::onMediaGroupsAdded( std::vector<MediaGroupPtr> mediaGroups )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didAddMediaGroups:)]) {
        [m_delegate
         medialibrary:m_medialibrary
         didAddMediaGroups:[VLCMLUtils arrayFromMediaGroupPtrVector:mediaGroups]];
    }
}

void MediaLibraryCb::onMediaGroupsModified( std::set<int64_t> mediaGroupsIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didModifyMediaGroupsWithIds:)]) {
        [m_delegate
         medialibrary:m_medialibrary
         didModifyMediaGroupsWithIds:intSetToArray(mediaGroupsIds)];
    }
}

void MediaLibraryCb::onMediaGroupsDeleted( std::set<int64_t> mediaGroupsIds )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didDeleteMediaGroupsWithIds:)]) {
        [m_delegate
         medialibrary:m_medialibrary
         didDeleteMediaGroupsWithIds:intSetToArray(mediaGroupsIds)];
    }
}

#pragma mark - Bookmarks

void MediaLibraryCb::onBookmarksAdded(std::vector<BookmarkPtr> bookmarks)
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didAddBookmarks:)]) {
        [m_delegate medialibrary:m_medialibrary didAddBookmarks:[VLCMLUtils arrayFromBookmarkPtrVector:bookmarks]];
    }
}

void MediaLibraryCb::onBookmarksModified(std::set<int64_t> bookmarkIds)
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:modifiedBookmarks:)]) {
        [m_delegate medialibrary:m_medialibrary modifiedBookmarks:intSetToArray(bookmarkIds)];
    }
}

void MediaLibraryCb::onBookmarksDeleted(std::set<int64_t> bookmarkIds)
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:deletedBookmarks:)]) {
        [m_delegate medialibrary:m_medialibrary deletedBookmarks:intSetToArray(bookmarkIds)];
    }
}

#pragma mark - folders

void MediaLibraryCb::onFoldersAdded( std::vector<FolderPtr> folders )
{

}

void MediaLibraryCb::onFoldersModified( std::set<int64_t> folderIds )
{

}

void MediaLibraryCb::onFoldersDeleted( std::set<int64_t> folderIds )
{

}

#pragma mark - Discovery

void MediaLibraryCb::onDiscoveryStarted()
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibraryDidStartDiscovery:)]) {
        [m_delegate medialibraryDidStartDiscovery:m_medialibrary];
    }
}

void MediaLibraryCb::onDiscoveryProgress( const std::string& currentFolder )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didProgressDiscovery:)]) {
        [m_delegate medialibrary:m_medialibrary
            didProgressDiscovery:[NSString stringWithUTF8String:currentFolder.c_str()]];
    }
}

void MediaLibraryCb::onDiscoveryCompleted()
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibraryDidEndDiscovery:)]) {
        [m_delegate medialibraryDidEndDiscovery:m_medialibrary];
    }
}

void MediaLibraryCb::onDiscoveryFailed( const std::string& entryPoint )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didFailDiscovery:)]) {
        [m_delegate medialibrary:m_medialibrary
                didFailDiscovery:[NSString stringWithUTF8String:entryPoint.c_str()]];
    }
}

#pragma mark - EntryPoints

void MediaLibraryCb::onEntryPointAdded( const std::string& entryPoint, bool success )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didAddEntryPoint:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary
                didAddEntryPoint:[NSString stringWithUTF8String:entryPoint.c_str()]
                     withSuccess:success];
    }
}

void MediaLibraryCb::onEntryPointRemoved( const std::string& entryPoint, bool success )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didRemoveEntryPoint:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary
             didRemoveEntryPoint:[NSString stringWithUTF8String:entryPoint.c_str()]
                     withSuccess:success];
    }
}

void MediaLibraryCb::onEntryPointBanned( const std::string& entryPoint, bool success )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didBanEntryPoint:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary
                didBanEntryPoint:[NSString stringWithUTF8String:entryPoint.c_str()]
                     withSuccess:success];
    }

}

void MediaLibraryCb::onEntryPointUnbanned( const std::string& entryPoint, bool success )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didUnbanEntryPoint:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary
              didUnbanEntryPoint:[NSString stringWithUTF8String:entryPoint.c_str()]
                     withSuccess:success];
    }
}

#pragma mark - Parsing
void MediaLibraryCb::onParsingStatsUpdated( uint32_t opsDone, uint32_t opsScheduled )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:didUpdateParsingStatsWithOpsDone:opsScheduled:)]) {
        [m_delegate medialibrary:m_medialibrary
didUpdateParsingStatsWithOpsDone:opsDone
                    opsScheduled:opsScheduled];
    }
}

#pragma mark - Background
void MediaLibraryCb::onBackgroundTasksIdleChanged( bool isIdle )
{
    if (m_delegate
        && [m_delegate
            respondsToSelector:@selector(medialibrary:didChangeIdleBackgroundTasksWithSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary didChangeIdleBackgroundTasksWithSuccess:isIdle];
    }
}

void MediaLibraryCb::onMediaThumbnailReady( MediaPtr media, ThumbnailSizeType sizeType, bool success )
{
    if (m_delegate
        && [m_delegate
            respondsToSelector:@selector(medialibrary:thumbnailReadyForMedia:ofType:withSuccess:)]) {
        [m_delegate medialibrary:m_medialibrary
          thumbnailReadyForMedia:[[VLCMLMedia alloc] initWithMediaPtr:media]
                          ofType:(VLCMLThumbnailSizeType)sizeType
                     withSuccess:success];
    }
}

void MediaLibraryCb::onHistoryChanged( HistoryType type )
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibrary:historyChangedOfType:)]) {
        [m_delegate medialibrary:m_medialibrary historyChangedOfType:(VLCMLHistoryType)type];
    }
}

bool MediaLibraryCb::onUnhandledException(const char *context,
                                          const char *errMsg, bool clearSuggested)
{
    if (m_delegate
        && [m_delegate
            respondsToSelector:@selector(medialibrary:unhandledExceptionWithContext:errorMessage:clearSuggested:)]) {
        return [m_delegate medialibrary:m_medialibrary
          unhandledExceptionWithContext:[NSString stringWithUTF8String:context]
                           errorMessage:[NSString stringWithUTF8String:errMsg]
                         clearSuggested:clearSuggested];
    }
    return false;
}

void MediaLibraryCb::onRescanStarted()
{
    if (m_delegate
        && [m_delegate respondsToSelector:@selector(medialibraryDidStartRescan:)]) {
        [m_delegate medialibraryDidStartRescan:m_medialibrary];
    }
}

}// namespace - medialibrary
