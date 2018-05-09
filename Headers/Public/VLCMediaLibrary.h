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

#pragma mark - VLCMediaLibraryDelegate
#pragma mark -

@protocol VLCMediaLibraryDelegate <NSObject>

@optional

- (void)onMediaAdded:(NSArray<VLCMLMedia *> *)media;
- (void)onMediaUpdated:(NSArray<VLCMLMedia *> *)media;
- (void)onMediaDeleted:(NSArray<NSNumber *> *)mediaIds;

- (void)onArtistsAdded:(NSArray<VLCMLArtist *> *)artists;
- (void)onArtistsModified:(NSArray<VLCMLArtist *> *)artists;
- (void)onArtistsDeleted:(NSArray<NSNumber *> *)artistsIds;

- (void)onAlbumsAdded:(NSArray<VLCMLAlbum *> *)albums;
- (void)onAlbumsModified:(NSArray<VLCMLAlbum *> *)albums;
- (void)onAlbumsDeleted:(NSArray<NSNumber *> *)albumsIds;

- (void)onTracksAdded:(NSArray<VLCMLAlbumTrack *> *)tracks;
- (void)onTracksDeleted:(NSArray<NSNumber *> *)tracks;

- (void)onPlaylistsAdded:(NSArray<VLCMLPlaylist *> *)playlists;
- (void)onPlaylistsModified:(NSArray<VLCMLPlaylist *> *)playlists;
- (void)onPlaylistsDeleted:(NSArray<NSNumber *> *)playlistsIds;

- (void)onDiscoveryStarted:(NSString *)entryPoint;
- (void)onDiscoveryProgress:(NSString *)entryPoint;
- (void)onDiscoveryCompleted:(NSString *)entryPoint;

- (void)onReloadStarted:(NSString *)entryPoint;
- (void)onReloadCompleted:(NSString *)entryPoint;

- (void)onEntryPointRemoved:(NSString *)entryPoint success:(BOOL)success;
- (void)onEntryPointBanned:(NSString *)entryPoint success:(BOOL)success;
- (void)onEntryPointUnbanned:(NSString *)entryPoint success:(BOOL)success;

- (void)onParsingStatsUpdated:(UInt32)percent;

- (void)onBackgroundTasksIdleChanged:(BOOL)success;
- (void)onMediaThumbnailReady:(VLCMLMedia *)media success:(BOOL)success;

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

@property (nonatomic, copy) NSString *dbPath;
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
- (VLCMLInitializeResult)setupMediaLibraryWithDb:(NSString *)dbPath thumbnailPath:(NSString *)thumbnailPath;

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
 * @brief artists List all artists that have at least an album.
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
