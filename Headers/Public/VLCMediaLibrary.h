/*****************************************************************************
 * VLCMediaLibrary.h
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

#import "VLCMLObject.h"

@class VLCMLFile, VLCMLLabel, VLCMLMedia, VLCMLMediaSearchAggregate, VLCMLAlbum, VLCMLAlbumTrack, VLCMLArtist, VLCMLPlaylist, VLCMLHistoryEntry, VLCMLGenre, VLCMLFolder, VLCMLShow, VLCMLMovie, VLCMLSearchAggregate;

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
    VLCMLSortingCriteriaArtist
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
    VLCMLInitializeResultDbReset
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
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didUpdateMedia:(NSArray<VLCMLMedia *> *)media;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteMediaWithIds:(NSArray<NSNumber *> *)mediaIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddArtists:(NSArray<VLCMLArtist *> *)artists;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyArtists:(NSArray<VLCMLArtist *> *)artists;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteArtistsWithIds:(NSArray<NSNumber *> *)artistsIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddAlbums:(NSArray<VLCMLAlbum *> *)albums;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyAlbums:(NSArray<VLCMLAlbum *> *)albums;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteAlbumsWithIds:(NSArray<NSNumber *> *)albumsIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddTracks:(NSArray<VLCMLAlbumTrack *> *)tracks;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeleteTracksWithIds:(NSArray<NSNumber *> *)tracksIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didAddPlaylists:(NSArray<VLCMLPlaylist *> *)playlists;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didModifyPlaylists:(NSArray<VLCMLPlaylist *> *)playlists;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didDeletePlaylistsWithIds:(NSArray<NSNumber *> *)playlistsIds;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didStartDiscovery:(NSString *)entryPoint;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didProgressDiscovery:(NSString *)entryPoint;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didCompleteDiscovery:(NSString *)entryPoint;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didStartReload:(NSString *)entryPoint;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didCompleteReload:(NSString *)entryPoint;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didRemoveEntryPoint:(NSString *)entryPoint withSuccess:(BOOL)success;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didBanEntryPoint:(NSString *)entryPoint withSuccess:(BOOL)success;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary didUnbanEntryPoint:(NSString *)entryPoint withSuccess:(BOOL)success;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didUpdateParsingStatsWithPercent:(UInt32)percent;

- (void)medialibrary:(VLCMediaLibrary *)medialibrary didChangeIdleBackgroundTasksWithSuccess:(BOOL)success;
- (void)medialibrary:(VLCMediaLibrary *)medialibrary thumbnailReadyForMedia:(VLCMLMedia *)media withSuccess:(BOOL)success;

@end

#pragma mark - VLCMLDeviceListerDelegate
#pragma mark -

@protocol VLCMLDeviceListerDelegate <NSObject>

@optional

- (BOOL)onDevicePluggedWithUuid:(NSString *)uuid mountPoint:(NSString *)mountPoint;
- (void)onDeviceUnpluggedWithUuid:(NSString *)uuid;
- (void)isDeviceKnown:(NSString *)uuid;

@end

#pragma mark - VLCMediaLibrary
#pragma mark -

@interface VLCMediaLibrary : NSObject

@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, copy) NSString *thumbnailPath;
@property (nonatomic, weak) id <VLCMediaLibraryDelegate> delegate;
@property (nonatomic, weak) id <VLCMLDeviceListerDelegate> deviceListerDelegate;

#pragma mark -

/**
 * Returns a `VLCMedialibrary` shared instance.
 * \return a `VLCMedialibrary` shared instance.
 */
+ (instancetype)sharedMediaLibrary;

- (BOOL)start;
- (VLCMLInitializeResult)setupMediaLibraryWithDatabasePath:(NSString *)databasePath
                                             thumbnailPath:(NSString *)thumbnailPath
NS_SWIFT_NAME(setupMediaLibrary(databasePath:thumbnailPath:));

- (void)setVerbosity:(VLCMLLogLevel)level;

#pragma mark -
#pragma mark Medialibrary main methods

#pragma mark - Label

- (VLCMLLabel *)createLabelWithName:(NSString *)name;
- (BOOL)deleteLabel:(VLCMLLabel *)label;

#pragma mark - Media

- (VLCMLMedia *)mediaWithIdentifier:(VLCMLIdentifier)identifier;
- (VLCMLMedia *)mediaWithMrl:(NSString *)mrl;
- (VLCMLMedia *)addMediaWithMrl:(NSString *)mrl;
- (NSArray<VLCMLMedia *> *)audioFilesWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;
- (NSArray<VLCMLMedia *> *)videoFilesWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Album

- (VLCMLAlbum *)albumWithIdentifier:(VLCMLIdentifier)identifier;
- (NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Show

- (VLCMLShow *)showWithName:(NSString *)name;

#pragma mark - Movie

- (VLCMLMovie *)movieWithName:(NSString *)name;

#pragma mark - Artist

- (VLCMLArtist *)artistWithIdentifier:(VLCMLIdentifier)identifier;
/**
 * @brief List all artists that have at least an album.
 * Artists that only appear on albums as guests won't be listed from here, but will be
 * returned when querying an album for all its appearing artists
 * @param sort A sorting criteria. So far, this is ignored, and artists are sorted by lexial order
 * @param desc If true, the provided sorting criteria will be reversed.
 * @param includeAll If true, all artists including those without album
 *                   will be returned. If false, only artists which have
 *                   an album will be returned.
 */
- (NSArray<VLCMLArtist *> *)artistsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc all:(BOOL)includeAll;

#pragma mark - Genre

- (NSArray<VLCMLGenre *> *)genresWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;
- (VLCMLGenre *)genreWithIdentifier:(VLCMLIdentifier)identifier;

#pragma mark - Playlist

- (VLCMLPlaylist *)createPlaylistWithName:(NSString *)name;
- (NSArray<VLCMLPlaylist *> *)playlistsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;
- (VLCMLPlaylist *)playlistWithIdentifier:(VLCMLIdentifier)identifier;
- (BOOL)deletePlaylistWithIdentifier:(VLCMLIdentifier)identifier;

#pragma mark - History

- (BOOL)addMediaToStreamHistory:(VLCMLMedia *)media;
- (NSArray<VLCMLHistoryEntry *> *)lastStreamsPlayed;
- (NSArray<VLCMLMedia *> *)lastMediaPlayed;
- (BOOL)clearHistory;

#pragma mark - Search

- (VLCMLMediaSearchAggregate *)searchMedia:(NSString *)pattern;
- (NSArray<VLCMLPlaylist *> *)searchPlaylistsByName:(NSString *)name;
- (NSArray<VLCMLAlbum *> *)searchAlbumsByPattern:(NSString *)pattern;
- (NSArray<VLCMLGenre *> *)searchGenreByName:(NSString *)name;
- (NSArray<VLCMLArtist *> *)searchArtistsByName:(NSString *)name;
- (VLCMLSearchAggregate *)search:(NSString *)pattern;

#pragma mark - Discover

/**
 * @brief Launch a discovery on the provided entry point.
 * The actuall discovery will run asynchronously, meaning this method will immediatly return.
 * Depending on which discoverer modules where provided, this might or might not work
 * \note This must be called after start()
 * @param entryPoint What to discover.
 */
- (void)discoverOnEntryPoint:(NSString *)path;
- (void)enableDiscoverNetwork:(BOOL)enable;
- (NSArray<VLCMLFolder *> *)entryPoints;
- (void)removeEntryPointWithPath:(NSString *)path;

#pragma mark - Folder

- (void)banFolderWithPath:(NSString *)path;
- (void)unbanFolderWithEntryPoint:(NSString *)entryPoint;

#pragma mark - Thumbnail

- (NSString *)thumbnailPath;

#pragma mark - Logger

#pragma mark - Background Operation

- (void)pauseBackgroundOperations;
- (void)resumeBackgroundOperations;

#pragma mark - Reload

- (void)reload;
- (void)reloadEntryPoint:(NSString *)entryPoint;

#pragma mark - Parser

- (void)forceParserRetry;

#pragma mark - DeviceLister

@end

NS_ASSUME_NONNULL_END
