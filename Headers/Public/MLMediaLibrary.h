/*****************************************************************************
 * MLMediaLibrary.h
 * MobileMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2017 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
 *          Felix Paul Kühne <fkuehne # videolan.org>
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

@class MLFile, MLLabel, MLMedia, MLAlbum, MLArtist, MLPlaylist, MLHistoryEntry;

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

@interface MLMediaLibrary : NSObject

/**
 * Medialibrary instance warpped inside a MLMediaLibrary instance.
 */
@property (nonatomic) void *instance;
@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong) NSString *thumbnailPath;

#pragma mark -

/**
 * Returns a `MLMedialibrary` shared instance.
 * \return a `MLMedialibrary` shared instance.
 */
+ (instancetype)sharedMediaLibrary;

/**
 * Returns a `medialibrary::IMediaLibrary *` shared instance.
 * \return a `medialibrary::IMediaLibrary *` shared instance.
 */
+ (void *)sharedInstance;

- (BOOL)startMedialibrary;
- (BOOL)setupMediaLibraryWithDb:(NSString *)dbPath forThumbnailPath:(NSString *)thumbnailPath;

#pragma mark -

- (void)setVerbosity:(MLLogLevel)level;

#pragma mark -

- (MLLabel *)createLabelWithName:(NSString *)name;
- (MLMedia *)mediaWithIdentifier:(int64_t)identifier;
- (MLMedia *)mediaWithMrl:(NSString *)mrl;
- (MLMedia *)addMediaWithMrl:(NSString *)mrl;
- (NSArray<MLMedia *> *)audioFilesWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc;
- (NSArray<MLMedia *> *)videoFilesWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc;
- (MLAlbum *)albumWithIdentifier:(int64_t)identifier;
- (NSArray<MLAlbum *> *)albumsWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc;

- (MLArtist *)artistWithIdentifier:(int64_t)identifier;
- (NSArray<MLArtist *> *)artistsWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc;

- (MLPlaylist *)createPlaylistWithName:(NSString *)name;
- (NSArray<MLPlaylist *> *)playlistsWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc;
- (MLPlaylist *)playlistWithIdentifier:(int64_t)identifier;
- (BOOL)deletePlaylistWithIdentifier:(int64_t)identifier;

- (BOOL)addMediaToStreamHistory:(MLMedia *)media;
- (NSArray<MLHistoryEntry *> *)lastStreamsPlayed;
- (NSArray<MLMedia *> *)lastMediaPlayed;
- (BOOL)clearHistory;

@end

