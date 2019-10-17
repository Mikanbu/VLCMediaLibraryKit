/*****************************************************************************
 * MediaLibraryCb.hpp
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
    virtual void onMediaModified( std::vector<int64_t> media );

    virtual void onMediaDeleted( std::vector<int64_t> mediaIds );

    virtual void onArtistsAdded( std::vector<ArtistPtr> artists );
    virtual void onArtistsModified( std::vector<int64_t> artists );
    virtual void onArtistsDeleted( std::vector<int64_t> artistsIds );

    virtual void onAlbumsAdded( std::vector<AlbumPtr> albums );
    virtual void onAlbumsModified( std::vector<int64_t> albums );
    virtual void onAlbumsDeleted( std::vector<int64_t> albumsIds );

    virtual void onPlaylistsAdded( std::vector<PlaylistPtr> playlists );
    virtual void onPlaylistsModified( std::vector<int64_t> playlists );
    virtual void onPlaylistsDeleted( std::vector<int64_t> playlistIds );

    virtual void onGenresAdded( std::vector<GenrePtr> genres );
    virtual void onGenresModified( std::vector<int64_t> genres );
    virtual void onGenresDeleted( std::vector<int64_t> genreIds );

    /**
     * @brief onDiscoveryStarted This callback will be invoked when a folder queued for discovery
     * (by calling IMediaLibrary::discover()) gets processed.
     * @param entryPoint The entrypoint being discovered
     * This callback will be invoked once per endpoint.
     */
    virtual void onDiscoveryStarted( const std::string& entryPoint );
    /**
     * @brief onDiscoveryProgress This callback will be invoked each time the discoverer enters a new
     * entrypoint. Typically, everytime it enters a new folder.
     * @param entryPoint The entrypoint being discovered
     * This callback can be invoked multiple times even though a single entry point was asked to be
     * discovered. ie. In the case of a file system discovery, discovering a folder would make this
     * callback being invoked for all subfolders
     */
    virtual void onDiscoveryProgress( const std::string& entryPoint );
    /**
     * @brief onDiscoveryCompleted Will be invoked when the discovery of a specified entrypoint has
     * completed.
     * ie. in the case of a filesystem discovery, once the folder, and all its files and subfolders
     * have been discovered.
     * This will also be invoked with an empty entryPoint when the initial reload of the medialibrary
     * has completed.
     */
    virtual void onDiscoveryCompleted( const std::string& entryPoint, bool success );
    /**
     * @brief onReloadStarted will be invoked when a reload operation begins.
     * @param entryPoint Will be an empty string is the reload is a global reload, or the specific
     * entry point that gets reloaded
     */
    virtual void onReloadStarted( const std::string& entryPoint );
    /**
     * @brief onReloadCompleted will be invoked when a reload operation gets completed.
     * @param entryPoint Will be an empty string is the reload was a global reload, or the specific
     * entry point that has been reloaded
     */
    virtual void onReloadCompleted( const std::string& entryPoint, bool success );
    /**
     * @brief onEntryPointAdded will be invoked when an entrypoint gets added
     * @param entryPoint The entry point which was scheduled for discovery
     * @param success A boolean to represent the operation's success
     *
     * This callback will only be emitted the first time the entry point gets
     * processed, after it has been inserted to the database.
     * In case of failure, it might be emited every time the request is sent, since
     * the provided entry point would most likely be invalid, and couldn't be inserted.
     * Later processing of that entry point will still cause \sa{onDiscoveryStarted}
     * \sa{onDiscoveryProgress} and \sa{onDiscoveryCompleted} events to be fired
     * \warning This event will be fired after \sa{onDiscoveryStarted} since we
     * don't know if an entry point is known before starting it's processing
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
     * @param percent The progress percentage [0,100]
     *
     */
    virtual void onParsingStatsUpdated( uint32_t percent);
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
    NSArray<NSNumber *> *intVectorToArray( std::vector<int64_t> vector );

private:
    id <VLCMediaLibraryDelegate> m_delegate;
    VLCMediaLibrary *m_medialibrary;
};

}
