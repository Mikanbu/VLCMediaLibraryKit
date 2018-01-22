/*****************************************************************************
 * VLCMediaLibrary.h
 * MediaLibraryKit
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

@class VLCFile, VLCLabel, VLCMedia, VLCMediaSearchAggregate, VLCAlbum, VLCAlbumTrack, VLCArtist, VLCPlaylist, VLCHistoryEntry, VLCGenre, VLCFolder, VLCShow, VLCMovie, VLCSearchAggregate;

typedef NS_ENUM (NSUInteger, VLCSortingCriteria) {
    /*
     * Default depends on the entity type:
     * - By track number (and disc number) for album tracks
     * - Alphabetical order for others
     */
    VLCSortingCriteriaDefault,
    VLCSortingCriteriaAlpha,
    VLCSortingCriteriaDuration,
    VLCSortingCriteriaInsertionDate,
    VLCSortingCriteriaLastModificationDate,
    VLCSortingCriteriaReleaseDate,
    VLCSortingCriteriaFileSize,
    VLCSortingCriteriaArtist
};

typedef NS_ENUM (NSUInteger, VLCLogLevel) {
    VLCLogLevelVerbose,
    VLCLogLevelDebug,
    VLCLogLevelInfo,
    VLCLogLevelWarning,
    VLCLogLevelError
};

#pragma mark - VLCMediaLibraryDelegate
#pragma mark -

@protocol VLCMediaLibraryDelegate <NSObject>

@optional

- (void)onMediaAdded:(NSArray<VLCMedia *> *)media;
- (void)onMediaUpdated:(NSArray<VLCMedia *> *)media;
- (void)onMediaDeleted:(NSArray<NSNumber *> *)mediaIds;

- (void)onArtistsAdded:(NSArray<VLCArtist *> *)artists;
- (void)onArtistsModified:(NSArray<VLCArtist *> *)artists;
- (void)onArtistsDeleted:(NSArray<NSNumber *> *)artistsIds;

- (void)onAlbumsAdded:(NSArray<VLCAlbum *> *)albums;
- (void)onAlbumsModified:(NSArray<VLCAlbum *> *)albums;
- (void)onAlbumsDeleted:(NSArray<NSNumber *> *)albumsIds;

- (void)onTracksAdded:(NSArray<VLCAlbumTrack *> *)tracks;
- (void)onTracksDeleted:(NSArray<NSNumber *> *)tracks;

- (void)onPlaylistsAdded:(NSArray<VLCPlaylist *> *)playlists;
- (void)onPlaylistsModified:(NSArray<VLCPlaylist *> *)playlists;
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

#pragma mark - VLCDeviceListerDelegate
#pragma mark -

@protocol VLCDeviceListerDelegate <NSObject>

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
@property (nonatomic, weak) id <VLCDeviceListerDelegate> deviceListerDelegate;

#pragma mark -

/**
 * Returns a `VLCMedialibrary` shared instance.
 * \return a `VLCMedialibrary` shared instance.
 */
+ (instancetype)sharedMediaLibrary;

- (BOOL)start;
- (BOOL)setupMediaLibraryWithDb:(NSString *)dbPath thumbnailPath:(NSString *)thumbnailPath;

- (void)setVerbosity:(VLCLogLevel)level;

#pragma mark -
#pragma mark Medialibrary main methods

#pragma mark - Label

- (VLCLabel *)createLabelWithName:(NSString *)name;
- (BOOL)deleteLabel:(VLCLabel *)label;

#pragma mark - Media

- (VLCMedia *)mediaWithIdentifier:(int64_t)identifier;
- (VLCMedia *)mediaWithMrl:(NSString *)mrl;
- (VLCMedia *)addMediaWithMrl:(NSString *)mrl;
- (NSArray<VLCMedia *> *)audioFilesWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc;
- (NSArray<VLCMedia *> *)videoFilesWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Album

- (VLCAlbum *)albumWithIdentifier:(int64_t)identifier;
- (NSArray<VLCAlbum *> *)albumsWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Show

- (VLCShow *)showWithName:(NSString *)name;

#pragma mark - Movie

- (VLCMovie *)movieWithName:(NSString *)name;

#pragma mark - Artist

- (VLCArtist *)artistWithIdentifier:(int64_t)identifier;
- (NSArray<VLCArtist *> *)artistsWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc;

#pragma mark - Genre

- (NSArray<VLCGenre *> *)genresWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc;
- (VLCGenre *)genreWithIdentifier:(int64_t)identifier;

#pragma mark - Playlist

- (VLCPlaylist *)createPlaylistWithName:(NSString *)name;
- (NSArray<VLCPlaylist *> *)playlistsWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc;
- (VLCPlaylist *)playlistWithIdentifier:(int64_t)identifier;
- (BOOL)deletePlaylistWithIdentifier:(int64_t)identifier;

#pragma mark - History

- (BOOL)addMediaToStreamHistory:(VLCMedia *)media;
- (NSArray<VLCHistoryEntry *> *)lastStreamsPlayed;
- (NSArray<VLCMedia *> *)lastMediaPlayed;
- (BOOL)clearHistory;

#pragma mark - Search

- (VLCMediaSearchAggregate *)searchMedia:(NSString *)pattern;
- (NSArray<VLCPlaylist *> *)searchPlaylistsByName:(NSString *)name;
- (NSArray<VLCAlbum *> *)searchAlbumsByPattern:(NSString *)pattern;
- (NSArray<VLCGenre *> *)searchGenreByName:(NSString *)name;
- (NSArray<VLCArtist *> *)searchArtistsByName:(NSString *)name;
- (VLCSearchAggregate *)search:(NSString *)pattern;

#pragma mark - Discover

- (void)discoverOnEntryPoint:(NSString *)path;
- (void)enableDiscoverNetwork:(BOOL)enable;
- (NSArray<VLCFolder *> *)entryPoints;
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
