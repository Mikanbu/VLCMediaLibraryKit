/*****************************************************************************
 * MLMediaLibrary.m
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

#import "MLMediaLibrary.h"
#import "MLFile.h"
#import "MLLabel.h"
#import "MLShowEpisode.h"
#import "MLShow.h"
#import "MLAlbumTrack.h"
#import "MLMedia.h"
#import "MLAlbum.h"
#import "MLArtist.h"
#import "MLPlaylist.h"
#import "MLHistoryEntry.h"
#import "MLMedia+Init.h"
#import "MLAlbum+Init.h"
#import "MLArtist+Init.h"
#import "MLPlaylist+Init.h"

@interface MLMediaLibrary ()
{
    BOOL _isInitialized;
    
    medialibrary::IMediaLibrary *_ml;
}
@end

@implementation MLMediaLibrary

#pragma mark - Shared methods

+ (instancetype)sharedMediaLibrary
{
    static MLMediaLibrary *sharedMediaLibrary = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedMediaLibrary = [[MLMediaLibrary alloc] init];
    });

    return sharedMediaLibrary;
}

+ (void *)sharedInstance
{
    return [[self sharedMediaLibrary] instance];
}

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isInitialized = NO;
        _ml = NewMediaLibrary();
        _instance = _ml;
    }
    return self;
}

- (BOOL)startMedialibrary
{
    BOOL success = _ml->start();

    return success;
}

- (BOOL)setupMediaLibraryWithDb:(NSString *)dbPath forThumbnailPath:(NSString *)thumbnailPath
{
    BOOL success = _ml->initialize([dbPath UTF8String], [thumbnailPath UTF8String], nil);

    if (success) {
        _isInitialized = YES;
        _dbPath = dbPath;
        _thumbnailPath = thumbnailPath;
    }
    return success;
}

- (void)setVerbosity:(MLLogLevel)level
{
    _ml->setVerbosity((medialibrary::LogLevel)level);
}

#pragma mark -
#pragma mark Medialibrary main methods

- (MLLabel *)createLabelWithName:(NSString *)name
{
    return [[MLLabel alloc] initWithName:name];
}

# pragma mark - Media

- (MLMedia *)mediaWithIdentifier:(int64_t)identifier
{
    return [[MLMedia alloc] initWithMediaPtr:_ml->media(identifier)];
}

- (MLMedia *)mediaWithMrl:(NSString *)mrl
{
    return [[MLMedia alloc] initWithMediaPtr:_ml->media([mrl UTF8String])];
}

- (MLMedia *)addMediaWithMrl:(NSString *)mrl
{
    return [[MLMedia alloc] initWithMediaPtr:_ml->addMedia([mrl UTF8String])];
}

//NSArray of MLMedia
- (NSArray *)audioFilesWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc
{
    NSMutableArray *result = [NSMutableArray array];
    auto audioFiles = _ml->audioFiles((medialibrary::SortingCriteria)sort, desc);

    for (auto audioFile : audioFiles) {
        [result addObject:[[MLMedia alloc] initWithMediaPtr:audioFile]];
    }
    return result;
}

- (NSArray *)videoFilesWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc
{
    NSMutableArray *result = [NSMutableArray array];
    auto videoFiles = _ml->videoFiles((medialibrary::SortingCriteria)sort, desc);

    for (auto videoFile : videoFiles) {
        [result addObject:[[MLMedia alloc] initWithMediaPtr:videoFile]];
    }
    return result;
}

# pragma mark - Album

- (MLAlbum *)albumWithIdentifier:(int64_t)identifier
{
    return [[MLAlbum alloc] initWithAlbumPtr:_ml->album(identifier)];
}

- (NSArray *)albumsWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc
{
    NSMutableArray *result = [NSMutableArray array];
    auto albums = _ml->albums((medialibrary::SortingCriteria)sort, desc);
    for (const auto &album : albums) {
        [result addObject:[[MLAlbum alloc] initWithAlbumPtr:album]];
    }
    return result;
}

#pragma mark - Artist

- (MLArtist *)artistWithIdentifier:(int64_t)identifier
{
    return [[MLArtist alloc] initWithArtistPtr:_ml->artist(identifier)];
}

- (NSArray *)artistsWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc
{
    NSMutableArray *result = [NSMutableArray array];
    auto artists = _ml->artists((medialibrary::SortingCriteria)sort, desc);
    for (auto artist : artists) {
        [result addObject:[[MLArtist alloc] initWithArtistPtr:artist]];
    }
    return result;
}

#pragma mark - Genre

#pragma mark - Playlist

- (MLPlaylist *)createPlaylistWithName:(NSString *)name
{
    return [[MLPlaylist alloc] initWithPlaylistPtr:_ml->createPlaylist([name UTF8String])];
}

- (NSArray *)playlistsWithSortingCriteria:(MLSortingCriteria)sort desc:(BOOL)desc
{
    NSMutableArray *result = [NSMutableArray array];
    auto playlists = _ml->playlists((medialibrary::SortingCriteria)sort, desc);
    for (auto playlist : playlists) {
        [result addObject:[[MLPlaylist alloc] initWithPlaylistPtr:playlist]];
    }
    return result;
}

- (MLPlaylist *)playlistWithIdentifier:(int64_t)identifier
{
    return [[MLPlaylist alloc] initWithPlaylistPtr:_ml->playlist(identifier)];
}

- (BOOL)deletePlaylistWithIdentifier:(int64_t)identifier
{
    return _ml->deletePlaylist(identifier);
}

#pragma mark - History

- (BOOL)addMediaToStreamHistory:(MLMedia *)media
{
    return false;
}

- (NSArray<MLHistoryEntry *> *)lastStreamsPlayed
{
    //vector historyPtr
    auto history = _ml->lastStreamsPlayed();
    NSMutableArray *result = [NSMutableArray array];

    for (auto historyEntry : history) {
        [result addObject:[[MLHistoryEntry alloc] initWithHistoryPtr:historyEntry]];
    }
    return result;
}

- (NSArray<MLMedia *> *)lastMediaPlayed
{
    auto mediaList = _ml->lastMediaPlayed();
    NSMutableArray *result = [NSMutableArray array];

    for (auto media : mediaList) {
        [result addObject:[[MLMedia alloc] initWithMediaPtr:media]];
    }
    return result;
}

- (BOOL)clearHistory
{
    return _ml->clearHistory();
}

#pragma mark - Search

#pragma mark -



@end
