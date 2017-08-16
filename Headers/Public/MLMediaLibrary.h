/*****************************************************************************
 * MLMediaLibrary.h
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

@class MLFile, MLLabel, MLMedia, MLMediaSearchAggregate, MLAlbum, MLAlbumTrack, MLArtist, MLPlaylist, MLHistoryEntry, MLGenre, MLFolder, MLShow, MLMovie, MLSearchAggregate;

typedef NS_ENUM (NSUInteger, MLSortingCriteria) {
    /*
     * Default depends on the entity type:
     * - By track number (and disc number) for album tracks
     * - Alphabetical order for others
     */
    MLSortingCriteriaDefault,
    MLSortingCriteriaAlpha,
    MLSortingCriteriaDuration,
    MLSortingCriteriaInsertionDate,
    MLSortingCriteriaLastModificationDate,
    MLSortingCriteriaReleaseDate,
    MLSortingCriteriaFileSize,
    MLSortingCriteriaArtist
};

typedef NS_ENUM (NSUInteger, MLLogLevel) {
    MLLogLevelVerbose,
    MLLogLevelDebug,
    MLLogLevelInfo,
    MLLogLevelWarning,
    MLLogLevelError
};

@protocol MLMediaLibraryDelegate <NSObject>

@optional

- (void)onMediaAdded:(NSArray<MLMedia *> *)media;
- (void)onMediaUpdated:(NSArray<MLMedia *> *)media;
- (void)onMediaDeleted:(NSArray<NSNumber *> *)mediaIds;

- (void)onArtistsAdded:(NSArray<MLArtist *> *)artists;
- (void)onArtistsModified:(NSArray<MLArtist *> *)artists;
- (void)onArtistsDeleted:(NSArray<NSNumber *> *)artistsIds;

- (void)onAlbumsAdded:(NSArray<MLAlbum *> *)albums;
- (void)onAlbumsModified:(NSArray<MLAlbum *> *)albums;
- (void)onAlbumsDeleted:(NSArray<NSNumber *> *)albumsIds;

- (void)onTracksAdded:(NSArray<MLAlbumTrack *> *)tracks;
- (void)onTracksDeleted:(NSArray<NSNumber *> *)tracks;

- (void)onPlaylistsAdded:(NSArray<MLPlaylist *> *)playlists;
- (void)onPlaylistsModified:(NSArray<MLPlaylist *> *)playlists;
- (void)onPlaylistsDeleted:(NSArray<NSNumber *> *)playlistsIds;

- (void)onDiscoveryStarted:(NSString *)entryPoint;
- (void)onDiscoveryProgress:(NSString *)entryPoint;
- (void)onDiscoveryCompleted:(NSString *)entryPoint;

- (void)onReloadStarted:(NSString *)entryPoint;
- (void)onReloadCompleted:(NSString *)entryPoint;

- (void)onEntryPointRemoved:(NSString *)entryPoint success:(BOOL)success;
- (void)onEntryPointBanned:(NSString *)entryPoint success:(BOOL)success;
- (void)onEntryPointUnbanned:(NSString *)entryPoint success:(BOOL)success;

- (void)onParsingStatsUpdated:(uint32_t)percent;

- (void)onBackgroundTasksIdleChanged:(BOOL)success;

@end

@protocol MLDeviceListerDelegate <NSObject>

@optional

- (BOOL)onDevicePluggedWithUuid:(NSString *)uuid mountPoint:(NSString *)mountPoint;
- (void)onDeviceUnpluggedWithUuid:(NSString *)uuid;
- (void)isDeviceKnown:(NSString *)uuid;

@end

@interface MLMediaLibrary : NSObject

@property (nonatomic, copy) NSString *dbPath;
@property (nonatomic, copy) NSString *thumbnailPath;
@property (nonatomic, weak) id <MLMediaLibraryDelegate> delegate;
@property (nonatomic, weak) id <MLDeviceListerDelegate> deviceListerDelegate;

#pragma mark -

/**
 * Returns a `MLMedialibrary` shared instance.
 * \return a `MLMedialibrary` shared instance.
 */
+ (instancetype)sharedMediaLibrary;

- (BOOL)start;
- (BOOL)setupMediaLibraryWithDb:(NSString *)dbPath thumbnailPath:(NSString *)thumbnailPath;

#pragma mark -

- (void)setVerbosity:(MLLogLevel)level;

#pragma mark -

#pragma mark - Label

- (MLLabel *)createLabelWithName:(NSString *)name;
- (BOOL)deleteLabel:(MLLabel *)label;

#pragma mark - Media

- (MLMedia *)mediaWithIdentifier:(int64_t)identifier;
- (MLMedia *)mediaWithMrl:(NSString *)mrl;
- (MLMedia *)addMediaWithMrl:(NSString *)mrl;
- (NSArray<MLMedia *> *)audioFilesWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc;
- (NSArray<MLMedia *> *)videoFilesWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Album

- (MLAlbum *)albumWithIdentifier:(int64_t)identifier;
- (NSArray<MLAlbum *> *)albumsWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Show

- (MLShow *)showWithName:(NSString *)name;

#pragma mark - Movie

- (MLMovie *)movieWithName:(NSString *)name;

#pragma mark - Artist

- (MLArtist *)artistWithIdentifier:(int64_t)identifier;
- (NSArray<MLArtist *> *)artistsWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Genre

- (NSArray<MLGenre *> *)genresWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc;
- (MLGenre *)genreWithIdentifier:(int64_t)identifier;

#pragma mark - Playlist

- (MLPlaylist *)createPlaylistWithName:(NSString *)name;
- (NSArray<MLPlaylist *> *)playlistsWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc;
- (MLPlaylist *)playlistWithIdentifier:(int64_t)identifier;
- (BOOL)deletePlaylistWithIdentifier:(int64_t)identifier;

#pragma mark - History

- (BOOL)addMediaToStreamHistory:(MLMedia *)media;
- (NSArray<MLHistoryEntry *> *)lastStreamsPlayed;
- (NSArray<MLMedia *> *)lastMediaPlayed;
- (BOOL)clearHistory;

#pragma mark - Search

- (MLMediaSearchAggregate *)searchMedia:(NSString *)pattern;
- (NSArray<MLPlaylist *> *)searchPlaylistsByName:(NSString *)name;
- (NSArray<MLAlbum *> *)searchAlbumsByPattern:(NSString *)pattern;
- (NSArray<MLGenre *> *)searchGenreByName:(NSString *)name;
- (NSArray<MLArtist *> *)searchArtistsByName:(NSString *)name;
- (MLSearchAggregate *)search:(NSString *)pattern;

#pragma mark - Discover

- (void)discoverOnEntryPoint:(NSString *)path;
- (void)enableDiscoverNetwork:(BOOL)enable;
- (NSArray<MLFolder *> *)entryPoints;
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
