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

- (void)onParsingStatsUpdated:(uint32_t)percent;

- (void)onBackgroundTasksIdleChanged:(BOOL)success;

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
- (BOOL)setupMediaLibraryWithDb:(NSString *)dbPath thumbnailPath:(NSString *)thumbnailPath;

- (void)setVerbosity:(VLCMLLogLevel)level;

#pragma mark -
#pragma mark Medialibrary main methods

#pragma mark - Label

- (VLCMLLabel *)createLabelWithName:(NSString *)name;
- (BOOL)deleteLabel:(VLCMLLabel *)label;

#pragma mark - Media

- (VLCMLMedia *)mediaWithIdentifier:(int64_t)identifier;
- (VLCMLMedia *)mediaWithMrl:(NSString *)mrl;
- (VLCMLMedia *)addMediaWithMrl:(NSString *)mrl;
- (NSArray<VLCMLMedia *> *)audioFilesWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;
- (NSArray<VLCMLMedia *> *)videoFilesWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Album

- (VLCMLAlbum *)albumWithIdentifier:(int64_t)identifier;
- (NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Show

- (VLCMLShow *)showWithName:(NSString *)name;

#pragma mark - Movie

- (VLCMLMovie *)movieWithName:(NSString *)name;

#pragma mark - Artist

- (VLCMLArtist *)artistWithIdentifier:(int64_t)identifier;
- (NSArray<VLCMLArtist *> *)artistsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Genre

- (NSArray<VLCMLGenre *> *)genresWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;
- (VLCMLGenre *)genreWithIdentifier:(int64_t)identifier;

#pragma mark - Playlist

- (VLCMLPlaylist *)createPlaylistWithName:(NSString *)name;
- (NSArray<VLCMLPlaylist *> *)playlistsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc;
- (VLCMLPlaylist *)playlistWithIdentifier:(int64_t)identifier;
- (BOOL)deletePlaylistWithIdentifier:(int64_t)identifier;

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
