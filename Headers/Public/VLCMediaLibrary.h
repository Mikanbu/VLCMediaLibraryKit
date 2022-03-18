/*****************************************************************************
 * VLCMediaLibrary.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2022 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
 *          Carola Nitz <caro # videolan.org>
 *          Pierre d'Herbemont <pdherbemont # videolan.org>
 *          Tobias Conradi <videolan # tobias-conradi.de>
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
#import "VLCMLObject.h"
#import "VLCMLMedia.h"

@class VLCMLFile, VLCMLLabel, VLCMLAlbum, VLCMLArtist, VLCMLPlaylist, VLCMLHistoryEntry, VLCMLGenre, VLCMLFolder, VLCMLShow, VLCMLMovie, VLCMLSearchAggregate, VLCMLMediaGroup;

extern VLCMLIdentifier const UnknownArtistID;
extern VLCMLIdentifier const VariousArtistID;

typedef NS_ENUM (NSUInteger, VLCMLSortingCriteria) {
    /*
     * Default depends on the entity type:
     * - By track number (and disc number) for album tracks
     * - Alphabetical order for others
     */
    VLCMLSortingCriteriaDefault,
    VLCMLSortingCriteriaAlpha,
    VLCMLSortingCriteriaDuration,
    VLCMLSortingCriteriaInsertionDate,
    VLCMLSortingCriteriaLastModificationDate,
    VLCMLSortingCriteriaReleaseDate,
    VLCMLSortingCriteriaFileSize,
    VLCMLSortingCriteriaArtist,
    VLCMLSortingCriteriaPlayCount,
    VLCMLSortingCriteriaAlbum,
    VLCMLSortingCriteriaFilename,
    // Sort by number of tracks in the containing entity (album, genre, artist, ...)
    VLCMLSortingCriteriaTrackNumber,
    // Sort by track ID (Track #1, track #2, ...)
    VLCMLSortingCriteriaTrackID,
    // Valid for folders only. Default order is descending
    VLCMLSortingCriteriaNbVideo,
    VLCMLSortingCriteriaNbAudio,
    // Valid for folders & media groups
    VLCMLSortingCriteriaNbMedia,
    // Only valid for artists for now
    VLCMLSortingCriteriaNbAlbum,
    VLCMLSortingCriteriaLastPlaybackDate,
};

typedef NS_ENUM (NSUInteger, VLCMLInitializeResult) {
    // Everything worked out fine
    VLCMLInitializeResultSuccess,

    // Should be considered the same as Success, but is an indication of
    // unrequired subsequent calls to initialize.
    VLCMLInitializeResultAlreadyInitialized,

    // A fatal error occured, the IMediaLibrary instance should be destroyed
    VLCMLInitializeResultFailed,

    // The database was reset, the caller needs to re-configure folders to
    // discover at the bare minimum.
    VLCMLInitializeResultDbReset,

    // Something is wrong with the database. It is up to the application to
    // chose what to do, the DB needs to be recovered or dropped in any case.
    VLCMLInitializeResultDbCorrupted
};

typedef NS_ENUM (NSUInteger, VLCMLThumbnailSizeType) {
    // A small sized thumbnail. Considered to be the default value before model 17
    VLCMLThumbnailSizeTypeThumbnail,
    // A banner type thumbnail. The exact size is application dependent.
    VLCMLThumbnailSizeTypeBanner,
    // The number of different size type
    VLCMLThumbnailSizeTypeCount
};

typedef NS_ENUM (NSUInteger, VLCMLThumbnailStatus) {
    // No thumbnail for this entity
    VLCMLThumbnailStatusMissing,
    // This thumbnail was successfully generated or was provided by the user
    // and is available to use
    VLCMLThumbnailStatusAvailable,
    // The thumbnail generation failed, without specific reason, usually
    // because of a timeout.
    // It is fine to ask for a new generation in this case
    VLCMLThumbnailStatusFailure,
    // The thumbnail generation failed at least 3 times. A new generation might
    // be required, but is likely to fail again.
    VLCMLThumbnailStatusPersistentFailure,
    // The thumbnail generation failed because of a crash. Asking for a new
    // generation is not recommended, unless you know the underlying issue was
    // fixed.
    VLCMLThumbnailStatusCrash
};

typedef NS_ENUM (NSUInteger, VLCMLHistoryType) {
    /// The history of media analyzed by the media library
    VLCMLHistoryTypeMedia,
    /// The network streams history
    VLCMLHistoryTypeNetwork
};

typedef NS_ENUM (NSUInteger, VLCMLLogLevel) {
    VLCMLLogLevelVerbose,
    VLCMLLogLevelDebug,
    VLCMLLogLevelInfo,
    VLCMLLogLevelWarning,
    VLCMLLogLevelError
};

@class VLCMediaLibrary;

#pragma mark - VLCMediaLibraryDelegate
#pragma mark -

NS_ASSUME_NONNULL_BEGIN

@protocol VLCMediaLibraryDelegate <NSObject>

@optional

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddMedia:(NSArray<VLCMLMedia *> *)media;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyMediaWithIds:(NSArray<NSNumber *> *)mediaIds;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteMediaWithIds:(NSArray<NSNumber *> *)mediaIds;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didConvertMediaToExternal
                    :(NSArray<NSNumber *> *)mediaIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddArtists:(NSArray<VLCMLArtist *> *)artists;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyArtistsWithIds:(NSArray<NSNumber *> *)artistsIds;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteArtistsWithIds:(NSArray<NSNumber *> *)artistsIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddAlbums:(NSArray<VLCMLAlbum *> *)albums;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyAlbumsWithIds:(NSArray<NSNumber *> *)albumsIds;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteAlbumsWithIds:(NSArray<NSNumber *> *)albumsIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddPlaylists:(NSArray<VLCMLPlaylist *> *)playlists;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyPlaylistsWithIds:(NSArray<NSNumber *> *)playlistsIds;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeletePlaylistsWithIds:(NSArray<NSNumber *> *)playlistsIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddGenres:(NSArray<VLCMLGenre *> *)genres;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyGenresWithIds:(NSArray<NSNumber *> *)genresIds;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteGenresWithIds:(NSArray<NSNumber *> *)genresIds;

- (void)medialibraryDidStartDiscovery:(VLCMediaLibrary *)medialibrary;
- (void)medialibraryDidEndDiscovery:(VLCMediaLibrary *)medialibrary;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didProgressDiscovery:(NSString *)currentFolder;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didFailDiscovery:(NSString *)entryPoint;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddEntryPoint:(NSString *)entryPoint withSuccess:(BOOL)success;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didRemoveEntryPoint:(NSString *)entryPoint withSuccess:(BOOL)success;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didBanEntryPoint:(NSString *)entryPoint withSuccess:(BOOL)success;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didUnbanEntryPoint:(NSString *)entryPoint withSuccess:(BOOL)success;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didUpdateParsingStatsWithOpsDone:(UInt32)opsDone
        opsScheduled:(UInt32)opsScheduled;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didChangeIdleBackgroundTasksWithSuccess:(BOOL)success;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary thumbnailReadyForMedia:(VLCMLMedia *)media
              ofType:(VLCMLThumbnailSizeType)type withSuccess:(BOOL)success;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary historyChangedOfType:(VLCMLHistoryType)type;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddMediaGroups:(NSArray<VLCMLMediaGroup *> *)mediaGroups;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyMediaGroupsWithIds:(NSArray<NSNumber *> *)mediaGroupsIds;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteMediaGroupsWithIds:(NSArray<NSNumber *> *)mediaGroupsIds;

/**
 * @brief unhandledExceptionWithContext will be invoked in case of an unhandled exception
 *
 * @param context A minimal context hint
 * @param errorMessage  The exception string
 * @param clearSuggested A boolean to inform the application that a database
 *                       clearing is suggested.
 *
 * If the application chooses to handle the error to present it to the user
 * or report it somehow, it should return true.
 * If the implementation returns false, then the exception will be rethrown
 * If clearSuggested is true, the application is advised to call
 * clearDatabase. After doing so, the medialibrary can still
 * be used without any further calls (but will need to rescan the entire user
 * collection). If clearDatabase isn't called, the database should be
 * considered as corrupted, and therefor the medialibrary considered unusable.
 *
 * If clearSuggested is false, there are no certain way of knowing if the
 * database is still usable or not.
 */

- (BOOL)medialibrary:(VLCMediaLibrary *)medialibrary unhandledExceptionWithContext:(NSString *)context
        errorMessage:(NSString *)errorMessage
      clearSuggested:(BOOL)clearSuggested;

/**
 * @brief onRescanStarted will be invoked when a rescan is started.
 *
 * This won't be emited when the media library issues a rescan itself, due
 * to a migration.
 */
- (void)medialibraryDidStartRescan:(VLCMediaLibrary *)medialibrary;

@end

#pragma mark - VLCMLDeviceListerDelegate
#pragma mark -

@protocol VLCMLDeviceListerDelegate <NSObject>

@optional

- (BOOL)medialibrary:(VLCMediaLibrary *)medialibrary deviceMountedWithUUID:(NSString *)uuid
      withMountPoint:(NSString *)mountPoint isRemovable:(BOOL)isRemovable;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary deviceUnmountedWithUUID:(NSString *)uuid
      withMountPoint:(NSString *)mountPoint;
@end

#pragma mark - VLCMediaLibrary
#pragma mark -

@interface VLCMediaLibrary : NSObject

@property (nonatomic, copy, readonly) NSString *databasePath;
@property (nonatomic, copy, readonly) NSString *medialibraryPath;
@property (nonatomic, weak) id <VLCMediaLibraryDelegate> delegate;
@property (nonatomic, weak) id <VLCMLDeviceListerDelegate> deviceListerDelegate;

#pragma mark -

/**
 * @brief  initialize Initializes the media library.
 *
 * @param databasePath        Path to the database file
 * @param medialibraryPath    Path to a folder that will contain medialibrary's files.
 * @return An \see{VLCMLInitializeResult} code.
 *
 * If initialize returns Failed, this medialibrary must not be used
 * anymore, and should be disposed off.
 * If it returns Ok the first time, calling this method again is a no-op and
 * AlreadyInitialized will be returned
 * In case DbReset is returned, it is up to application to decide what
 * to do to repopulate the database.
 *
 * The medialibraryPath path is assumed to be a folder dedicated to store the
 * various media library files. It might be emptied or modified at any time.
 *
 * This method is thread safe. If multiple initialization start simultaneously
 * only the first one will return Success, the later ones will return
 * AlreadyInitialized
 */
- (VLCMLInitializeResult)setupMediaLibraryWithDatabasePath:(NSString *)databasePath
                                          medialibraryPath:(NSString *)medialibraryPath
NS_SWIFT_NAME(setupMediaLibrary(databasePath:medialibraryPath:));

- (void)setVerbosity:(VLCMLLogLevel)level;

#pragma mark -
#pragma mark Medialibrary main methods

#pragma mark - Label

- (nullable VLCMLLabel *)createLabelWithName:(NSString *)name;
- (BOOL)deleteLabel:(VLCMLLabel *)label;

#pragma mark - Media

- (nullable VLCMLMedia *)mediaWithIdentifier:(VLCMLIdentifier)identifier;
- (nullable VLCMLMedia *)mediaWithMrl:(NSURL *)mrl;
- (nullable VLCMLMedia *)addExternalMediaWithMrl:(NSURL *)mrl;
- (nullable VLCMLMedia *)addExternalMediaWithMrl:(NSURL *)mrl duration:(int64_t)duration
NS_SWIFT_NAME(addExternalMedia(mrl:duration:));
- (nullable VLCMLMedia *)addStreamWithMrl:(NSURL *)mrl;

- (BOOL)removeExternalMedia:(VLCMLMedia *)media;

- (nullable NSArray<VLCMLMedia *> *)audioFiles;
- (nullable NSArray<VLCMLMedia *> *)audioFilesWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                             desc:(BOOL)desc;

- (nullable NSArray<VLCMLMedia *> *)videoFiles;
- (nullable NSArray<VLCMLMedia *> *)videoFilesWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                             desc:(BOOL)desc;

- (nullable NSArray<VLCMLMedia *> *)movies;
- (nullable NSArray<VLCMLMedia *> *)moviesWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;

- (nullable NSArray<VLCMLMedia *> *)inProgressMediaOfType:(VLCMLMediaType)type
                                      withSortingCriteria:(VLCMLSortingCriteria)criteria
                                                     desc:(BOOL)desc;

#pragma mark - Media groups

/**
 * @brief createMediaGroup Creates a media group
 * @param name The group name
 * @return The new group instance, or nil in case of error
 */
- (nullable VLCMLMediaGroup *)createMediaGroupWithName:(NSString *)name;

/**
 * @brief createMediaGroup Creates a media group with the provided media
 * @param mediaIds A list of media to be included in the group
 * @return The new group instance, or nullptr in case of error
 *
 * If the provided media are already part of a group, they will be moved to
 * the newly created one.
 * The group will have no name and will return an empty string.
 */
- (nullable VLCMLMediaGroup *)createMediaGroupWithMediaIds:(NSArray<NSNumber *> *)mediaIds;

/**
 * @brief deleteMediaGroup Deletes a media group
 * @param identifer The group ID
 * @return true in case of success, false otherwise
 *
 * This will ungroup all media that were part of the group.
 */
- (BOOL)deleteMediaGroupWithIdentifier:(VLCMLIdentifier)identifer;

/**
 * @brief mediaGroup Returns a media group with the given identifier
 * @return A media group, or nil if the group doesn't exist, or in case
 *         of sporadic failure.
 */
- (nullable VLCMLMediaGroup *)mediaGroupWithIdentifier:(VLCMLIdentifier)identifier;

/**
 * @brief mediaGroups Returns a query representing the root media groups of type unknown.
 *        For specific type, \see{mediaGroupsOfType:} code.
 * @param criteria A query parameter
 *
 * The supported sorting criteria are:
 * - Alpha (default)
 * - NbVideo
 * - NbAudio
 * - NbMedia
 */
- (nullable NSArray<VLCMLMediaGroup *> *)mediaGroupsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                                   desc:(BOOL)desc;
- (nullable NSArray<VLCMLMediaGroup *> *)mediaGroups;


- (nullable NSArray<VLCMLMediaGroup *> *)mediaGroupsOfType:(VLCMLMediaType)type
NS_SWIFT_NAME(mediaGroups(type:));
- (nullable NSArray<VLCMLMediaGroup *> *)mediaGroupsOfType:(VLCMLMediaType)type
                                           sortingCriteria:(VLCMLSortingCriteria)criteria
                                                      desc:(BOOL)desc
NS_SWIFT_NAME(mediaGroups(type:sortingCriteria:desc:));;

/**
 * @brief regroupAll Attemps to regroup all media that belong to a forced singleton group
 *
 * This will try to regroup all media that were manually removed from their
 * group, and now belong to a forced singleton group.
 * Media that belong to a group of only 1 element will not be affected by this.
 * Usual regrouping rules apply, meaning that a minimum of 6 characters match
 * is required for 2 media to be grouped together, and if applicable, the longest
 * match will be used to name the created group
 * In case of error, false will be returned, but some media might have been
 * regrouped already.
 *
 * @warning This might be a relatively long operation as it must fetch the
 *          first media being part of a singleton group and regroup it with
 *          its matching media, in a loop, until all media are regrouped
 */
- (BOOL)regroupAll;

#pragma mark - Album

- (nullable VLCMLAlbum *)albumWithIdentifier:(VLCMLIdentifier)identifier;

- (nullable NSArray<VLCMLAlbum *> *)albums;
- (nullable NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;

#pragma mark - Show

- (nullable VLCMLShow *)showWithIdentifier:(VLCMLIdentifier)identifier;

#pragma mark - Movie

- (nullable VLCMLMovie *)movieWitIdentifier:(VLCMLIdentifier)identifier;

#pragma mark - Artist

- (nullable VLCMLArtist *)artistWithIdentifier:(VLCMLIdentifier)identifier;

/**
 * @brief List all artists that have at least an album.
 * Artists that only appear on albums as guests won't be listed from here, but will be
 * returned when querying an album for all its appearing artists
 * @param includeAll If true, all artists including those without album
 *                   will be returned. If false, only artists which have
 *                   an album will be returned.
 */
- (nullable NSArray<VLCMLArtist *> *)artists:(BOOL)includeAll;

/**
 * @brief List all artists that have at least an album.
 * Artists that only appear on albums as guests won't be listed from here, but will be
 * returned when querying an album for all its appearing artists
 * @param criteria A sorting criteria. So far, this is ignored, and artists are sorted by lexial order
 * @param desc If true, the provided sorting criteria will be reversed.
 * @param includeAll If true, all artists including those without album
 *                   will be returned. If false, only artists which have
 *                   an album will be returned.
 */
- (nullable NSArray<VLCMLArtist *> *)artistsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                           desc:(BOOL)desc all:(BOOL)includeAll;

#pragma mark - Genre

- (nullable VLCMLGenre *)genreWithIdentifier:(VLCMLIdentifier)identifier;
- (nullable NSArray<VLCMLGenre *> *)genres;
- (nullable NSArray<VLCMLGenre *> *)genresWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;

#pragma mark - Playlist

- (nullable VLCMLPlaylist *)playlistWithIdentifier:(VLCMLIdentifier)identifier;
- (nullable NSArray<VLCMLPlaylist *> *)playlists;
- (nullable NSArray<VLCMLPlaylist *> *)playlistsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                               desc:(BOOL)desc;

- (nullable VLCMLPlaylist *)createPlaylistWithName:(NSString *)name;
- (BOOL)deletePlaylistWithIdentifier:(VLCMLIdentifier)identifier;

#pragma mark - History

- (nullable NSArray<VLCMLMedia *> *)history;
- (nullable NSArray<VLCMLMedia *> *)streamHistory;
- (BOOL)clearHistory;

#pragma mark - Search

/**
 * @brief searchMedia, searchAudio, and searchVideo search for some media, based on a pattern.
 * @param pattern A 3 character or more pattern that will be matched against the media's title
 *                or filename if no title was set for this media.
 * @param criteria Some query parameters. Valid sorting criteria are:
 *               - Duration
 *               - InsertionDate
 *               - ReleaseDate
 *               - PlayCount
 *               - Filename
 *               - LastModificationDate
 *               - FileSize
 *              Default sorting parameter uses the media's title.
 *              Passing nullptr will default to default ascending sort
 *
 * Only media that were discovered by the medialibrary will be included.
 * For instance, media that are added explicitely, playlist items that
 * point to remote content, will *not* be included
 */
- (nullable NSArray<VLCMLMedia *> *)searchMedia:(NSString *)pattern
                                           sort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;
- (nullable NSArray<VLCMLMedia *> *)searchMedia:(NSString *)pattern;

- (nullable NSArray<VLCMLPlaylist *> *)searchPlaylistsByName:(NSString *)name;
- (nullable NSArray<VLCMLPlaylist *> *)searchPlaylistsByName:(NSString *)name
                                                        sort:(VLCMLSortingCriteria)criteria
                                                        desc:(BOOL)desc;

- (nullable NSArray<VLCMLAlbum *> *)searchAlbumsByPattern:(NSString *)pattern;
- (nullable NSArray<VLCMLAlbum *> *)searchAlbumsByPattern:(NSString *)pattern
                                                     sort:(VLCMLSortingCriteria)criteria
                                                     desc:(BOOL)desc;

- (nullable NSArray<VLCMLGenre *> *)searchGenreByName:(NSString *)name;
- (nullable NSArray<VLCMLGenre *> *)searchGenreByName:(NSString *)name
                                                 sort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

- (nullable NSArray<VLCMLArtist *> *)searchArtistsByName:(NSString *)name all:(BOOL)includeAll;
- (nullable NSArray<VLCMLArtist *> *)searchArtistsByName:(NSString *)name all:(BOOL)includeAll
                                                    sort:(VLCMLSortingCriteria)criteria
                                                    desc:(BOOL)desc;

- (nullable NSArray<VLCMLFolder *> *)searchFoldersWithPattern:(NSString *)pattern;
- (nullable NSArray<VLCMLFolder *> *)searchFoldersWithPattern:(NSString *)pattern
                                                         type:(VLCMLMediaType)type;

- (nullable NSArray<VLCMLFolder *> *)searchFoldersWithPattern:(NSString *)pattern
                                              sortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;
- (nullable NSArray<VLCMLFolder *> *)searchFoldersWithPattern:(NSString *)pattern
                                                         type:(VLCMLMediaType)type
                                              sortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;

- (nullable NSArray<VLCMLMediaGroup *> *)searchMediaGroupsWithPattern:(NSString *)pattern;
- (nullable NSArray<VLCMLMediaGroup *> *)searchMediaGroupsWithPattern:(NSString *)pattern
                                                                 sort:(VLCMLSortingCriteria)criteria
                                                                 desc:(BOOL)desc;


- (VLCMLSearchAggregate *)search:(NSString *)pattern;
- (VLCMLSearchAggregate *)search:(NSString *)pattern
                            sort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;


#pragma mark - Discover

/**
 * @brief Launch a discovery on the provided entry point.
 * The actuall discovery will run asynchronously, meaning this method will immediatly return.
 * Depending on which discoverer modules where provided, this might or might not work
 * \note This must be called after start()
 * @param path What to discover.
 */
- (void)discoverOnEntryPoint:(NSString *)path;

/**
 * @brief enableDiscoverNetwork Enable discovery of network shares
 *
 * This can be called at any time, but won't have any effect before
 * initialize() has been called.
 * When disabling network discovery, all content that was discovered on
 * the network will be marked as non-present, meaning they won't be
 * returned until network discovery gets enabled again.
 * As far as the user is concerned, this is equivalent to (un)plugging
 * a USB drive, in the sense that the medialibrary will still store
 * information about network content and won't have to discover/parse it
 * again.
 */
- (void)enableDiscoverNetwork:(BOOL)enable;
- (nullable NSArray<VLCMLFolder *> *)entryPoints;
- (void)removeEntryPointWithPath:(NSString *)path;

#pragma mark - Folder

- (nullable VLCMLFolder *)folderWithIdentifier:(VLCMLIdentifier)identifier;
- (nullable VLCMLFolder *)folderAtMrl:(NSURL *)mrl;

/**
 * @brief folders Returns a flattened list of all folders of any type
 * @return An array of VLCMLFolder object
 */
- (NSArray<VLCMLFolder *> *)folders;

/**
 * @brief folders Returns a flattened list of all folders containing at least a media of a given type
 * @param type A required type of media, or VLCMediaTypeUnknown if any media type is fine.
 * @return An array of VLCMLFolder object
 *
 * This is flattened, ie.
 * ├── a
 * │   └── w
 * │       └── x
 * │           └── y
 * │               └── z
 * │                   └── DogMeme.avi
 * ├── c
 * │   └── NakedMoleRat.asf
 *
 * would return a query containing 'z' and 'c' as the other folders are
 * not containing any media.
 * In case a non flattened list is desired, the
 * entryPoints() & VLCMLFolder::subFolders() methods should be used.
 */
- (nullable NSArray<VLCMLFolder *> *)foldersOfType:(VLCMLMediaType)type;

- (nullable NSArray<VLCMLFolder *> *)foldersWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                           desc:(BOOL)desc;
- (nullable NSArray<VLCMLFolder *> *)foldersWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                           type:(VLCMLMediaType)type
                                                           desc:(BOOL)desc;


/**
 * @brief banFolderWithPath will prevent an entry point folder from being discovered.
 * If the folder was already discovered, it will be removed prior to the ban, and all
 * associated media will be discarded.
 * * @note This method is asynchronous and will run after all currently stacked
 * discovery/ban/unban operations have completed.
 */
- (void)banFolderWithPath:(NSString *)path;

/**
 * @brief unbanFolderWithEntryPoint Unban an entrypoint.
 * In case this entry point was indeed previously banned, this will issue a reload of
 * that entry point
 * @param entryPoint The entry point to unban
 * @note This method is asynchronous and will run after all currently stacked
 * discovery/ban/unban operations have completed.
 */
- (void)unbanFolderWithEntryPoint:(NSString *)entryPoint;

#pragma mark - Thumbnail

/**
 * @brief enableFailedThumbnailRegeneration Allow failed thumbnail attempt to be retried
 *
 * This will not attempt to regenerate the thumbnail immediatly, requestThumbnail
 * still has to be called afterward.
 */
- (void)enableFailedThumbnailRegeneration;

#pragma mark - Logger

#pragma mark - Background Operation

/**
 * @brief pauseBackgroundOperations Will stop potentially CPU intensive background
 * operations, until resumeBackgroundOperations() is called.
 * If an operation is currently running, it will finish before pausing.
 */
- (void)pauseBackgroundOperations;

/**
 * @brief resumeBackgroundOperations Resumes background tasks, previously
 * interrupted by pauseBackgroundOperations().
 */
- (void)resumeBackgroundOperations;

#pragma mark - Reload

- (void)reload;
- (void)reloadEntryPoint:(NSString *)entryPoint;

#pragma mark - Parser

/**
 * @brief forceParserRetry Forces a re-run of all metadata parsers and resets any
 * unterminated file retry count to 0, granting them 3 new tries at being parsed
 */
- (void)forceParserRetry;

#pragma mark - Scan

/**
 * @brief forceRescan Deletes all entities except Media and Playlist, and
 *                    forces all media to be rescanned.
 *
 * This can be called anytime after the medialibrary has been initialized. * It will make all held instances outdated. Those should be considered
 * as invalid the moment this method returns.
 */
- (void)forceRescan;

#pragma mark - Database

/**
 * @brief clearDatabase Will drop & recreate the database
 * @param restorePlaylists If true, the media library will attempt to keep
 *                         the user created playlists
 */
- (void)clearDatabaseWithRestorePlaylists:(BOOL)restorePlaylists
NS_SWIFT_NAME(clearDatabase(restorePlaylists:));

#pragma mark - DeviceLister

#pragma mark - Extensions

/**
 * @brief supportedMediaExtensions Returns the supported media extensions
 *
 * The list is guaranteed to be ordered alphabetically
 */

- (NSArray<NSString *> *)supportedMediaExtensions;

/**
 * @brief isMediaExtensionSupported Checks if the provided media extension
 *                                  is supported.
 */
- (BOOL)isMediaExtensionSupported:(NSString *)extension;

/**
 * @brief supportedPlaylistExtensions Returns the supported playlist extensions
 *
 * The list is guaranteed to be ordered alphabetically
 */
- (NSArray<NSString *> *)supportedPlaylistExtensions;

/**
 * @brief isPlaylistExtensionSupported Checks if the provided playlist extension
 *                                     is supported.
 */
- (BOOL)isPlaylistExtensionSupported:(NSString *)extension;

@end

NS_ASSUME_NONNULL_END
