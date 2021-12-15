/*****************************************************************************
 * MediaLibraryCb.hpp
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2017-2021 VLC authors and VideoLAN
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

#import "VLCMediaLibrary.h"

namespace medialibrary
{

class MediaLibraryCb : public IMediaLibraryCb
{
public:
    MediaLibraryCb( VLCMediaLibrary *medialibrary, id<VLCMediaLibraryDelegate> delegate );

    void setDelegate( id<VLCMediaLibraryDelegate> delegate );

    /**
     * @brief onFileAdded Will be called when some media get added.
     * Depending if the media is being restored or was just discovered,
     * the media type might be a best effort guess. If the media was freshly
     * discovered, it is extremely likely that no metadata will be
     * available yet.
     * The number of media is undefined, but is guaranteed to be at least 1.
     */
    virtual void onMediaAdded( std::vector<MediaPtr> media );
    /**
     * @brief onFileUpdated Will be called when a file metadata gets updated.
     */
    virtual void onMediaModified( std::set<int64_t> mediaIds );

    virtual void onMediaDeleted( std::set<int64_t> mediaIds );

    /**
     * @brief onMediaConvertedToExternal Will be invoked when some media are converted
     * from internal to external
     * @param mediaIds The converted media IDs
     *
     * A media will be converted from internal to external if the entrypoint which
     * contains it gets removed from the list of known entry points. The media
     * will only be deleted at a later point from the database, if they haven't
     * been played for around 6 months, and are not part of any playlist
     */
    virtual void onMediaConvertedToExternal( std::set<int64_t> mediaIds );

    virtual void onArtistsAdded( std::vector<ArtistPtr> artists );
    virtual void onArtistsModified( std::set<int64_t> artistsIds );
    virtual void onArtistsDeleted( std::set<int64_t> artistsIds );

    virtual void onAlbumsAdded( std::vector<AlbumPtr> albums );
    virtual void onAlbumsModified( std::set<int64_t> albumsIds );
    virtual void onAlbumsDeleted( std::set<int64_t> albumsIds );

    virtual void onPlaylistsAdded( std::vector<PlaylistPtr> playlists );
    virtual void onPlaylistsModified( std::set<int64_t> playlistsIds );
    virtual void onPlaylistsDeleted( std::set<int64_t> playlistIds );

    virtual void onGenresAdded( std::vector<GenrePtr> genres );
    virtual void onGenresModified( std::set<int64_t> genresIds );
    virtual void onGenresDeleted( std::set<int64_t> genreIds );

    virtual void onMediaGroupsAdded( std::vector<MediaGroupPtr> mediaGroups );
    virtual void onMediaGroupsModified( std::set<int64_t> mediaGroupsIds );
    virtual void onMediaGroupsDeleted( std::set<int64_t> mediaGroupsIds );

    virtual void onBookmarksAdded( std::vector<BookmarkPtr> bookmarks );
    virtual void onBookmarksModified( std::set<int64_t> bookmarkIds );
    virtual void onBookmarksDeleted( std::set<int64_t> bookmarkIds );

    /**
     * @brief onDiscoveryStarted This callback will be invoked when the discoverer
     * starts to crawl an entrypoint that was scheduled for discovery or reload.
     *
     * This callback will be invoked when the discoverer thread gets woken up
     * regardless of how many entry points need to be discovered.
     */
    virtual void onDiscoveryStarted();
    /**
     * @brief onDiscoveryProgress This callback will be invoked each time the
     * discoverer enters a new folder.
     * @param currentFolder The folder being discovered
     *
     * This callback can be invoked multiple times even though a single entry point was asked to be
     * discovered. ie. In the case of a file system discovery, discovering a folder would make this
     * callback being invoked for all subfolders
     */
    virtual void onDiscoveryProgress( const std::string& currentFolder );
    /**
     * @brief onDiscoveryCompleted Will be invoked when the discoverer finishes
     * all its queued operations and goes back to idle.
     *
     * This callback will be invoked once for each invocation fo onDiscoveryStarted
     */
    virtual void onDiscoveryCompleted();
    /**
     * @brief onDiscoveryFailed Will be invoked when a discovery operation fails
     * @param entryPoint The entry point for which the discovery failed.
     */
    virtual void onDiscoveryFailed( const std::string& entryPoint );
    /**
     * @brief onReloadStarted will be invoked when a reload operation begins.
     * @param entryPoint Will be an empty string is the reload is a global reload, or the specific
     * entry point that gets reloaded
     */
    virtual void onEntryPointAdded( const std::string& entryPoint, bool success );
    /**
     * @brief onEntryPointRemoved will be invoked when an entrypoint removal request gets processsed
     * by the appropriate worker thread.
     * @param entryPoint The entry point which removal was required
     * @param success A boolean representing the operation's success
     */
    virtual void onEntryPointRemoved( const std::string& entryPoint, bool success );
    /**
     * @brief onEntryPointBanned will be called when an entrypoint ban request is done being processed.
     * @param entryPoint The banned entrypoint
     * @param success A boolean representing the operation's success
     */
    virtual void onEntryPointBanned( const std::string& entryPoint, bool success );
    /**
     * @brief onEntryPointUnbanned will be called when an entrypoint unban request is done being processed.
     * @param entryPoint The unbanned entrypoint
     * @param success A boolean representing the operation's success
     */
    virtual void onEntryPointUnbanned( const std::string& entryPoint, bool success );
    /**
     * @brief onParsingStatsUpdated Called when the parser statistics are updated
     *
     * There is no waranty about how often this will be called.
     * @param opsDone The number of operation the parser completed
     * @param opsScheduled The number of operations currently scheduled by the parser
     *
     */
    virtual void onParsingStatsUpdated( uint32_t opsDone, uint32_t opsScheduled );
    /**
     * @brief onBackgroundTasksIdleChanged Called when background tasks idle state change
     * @param isIdle true when all background tasks are idle, false otherwise
     */
    virtual void onBackgroundTasksIdleChanged( bool isIdle );

    /**
     * @brief onMediaThumbnailReady Called when a thumbnail generation completed.
     * @param media The media for which a thumbnail was generated
     * @param sizeType The size type that was requerested
     * @param success true if the thumbnail was generated, false if the generation failed
     */
    virtual void onMediaThumbnailReady( MediaPtr media, ThumbnailSizeType sizeType, bool success );

    /**
     * @brief onHistoryChanged Called when a media history gets modified (including when cleared)
     * @param type The history type
     */
    virtual void onHistoryChanged( HistoryType type );

    /**
     * @brief onUnhandledException will be invoked in case of an unhandled exception
     *
     * @param context A minimal context hint
     * @param errMsg  The exception string, as returned by std::exception::what()
     * @param clearSuggested A boolean to inform the application that a database
     *                       clearing is suggested.
     *
     * If the application chooses to handle the error to present it to the user
     * or report it somehow, it should return true.
     * If the implementation returns false, then the exception will be rethrown
     * If clearSuggested is true, the application is advised to call
     * IMediaLibrary::clearDatabase. After doing so, the medialibrary can still
     * be used without any further calls (but will need to rescan the entire user
     * collection). If clearDatabase isn't called, the database should be
     * considered as corrupted, and therefor the medialibrary considered unusable.
     *
     * If clearSuggested is false, there are no certain way of knowing if the
     * database is still usable or not.
     */
    virtual bool onUnhandledException( const char* /* context */,
                                       const char* /* errMsg */,
                                      bool /* clearSuggested */ );

    /**
     * @brief onRescanStarted will be invoked when a rescan is started.
     *
     * This won't be emited when the media library issues a rescan itself, due
     * to a migration.
     */
    virtual void onRescanStarted();

private:
    NSArray<NSNumber *> *intSetToArray( std::set<int64_t> set );

private:
    id <VLCMediaLibraryDelegate> m_delegate;
    VLCMediaLibrary *m_medialibrary;
};

}
