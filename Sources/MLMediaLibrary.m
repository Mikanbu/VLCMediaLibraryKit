/*****************************************************************************
 * MLMediaLibrary.m
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

#import "MLMediaLibrary.h"
#import "MLAlbumTrack.h"

#import "MLAlbum+Init.h"
#import "MLArtist+Init.h"
#import "MLFolder+Init.h"
#import "MLGenre+Init.h"
#import "MLHistoryEntry+Init.h"
#import "MLLabel+Init.h"
#import "MLMedia+Init.h"
#import "MLMovie+Init.h"
#import "MLPlaylist+Init.h"
#import "MLShow+Init.h"


struct MLMediaSearchAggregate
{
    std::vector<medialibrary::MediaPtr> episodes;
    std::vector<medialibrary::MediaPtr> movies;
    std::vector<medialibrary::MediaPtr> others;
    std::vector<medialibrary::MediaPtr> tracks;
};

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

- (BOOL)setupMediaLibraryWithDb:(NSString *)dbPath thumbnailPath:(NSString *)thumbnailPath
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

#pragma mark - Label

- (MLLabel *)createLabelWithName:(NSString *)name
{
    return [[MLLabel alloc] initWithLabelPtr:_ml->createLabel([name UTF8String])];
}

- (BOOL)deleteLabel:(MLLabel *)label
{
    return _ml->deleteLabel([label labelPtr]);
}

#pragma mark - Media

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

- (NSArray<MLMedia *> *)audioFilesWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto audioFiles = _ml->audioFiles((medialibrary::SortingCriteria)criteria, desc);
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &audioFile : audioFiles) {
        [result addObject:[[MLMedia alloc] initWithMediaPtr:audioFile]];
    }
    return result;
}

- (NSArray<MLMedia *> *)videoFilesWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto videoFiles = _ml->videoFiles((medialibrary::SortingCriteria)criteria, desc);
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &videoFile : videoFiles) {
        [result addObject:[[MLMedia alloc] initWithMediaPtr:videoFile]];
    }
    return result;
}

#pragma mark - Album

- (MLAlbum *)albumWithIdentifier:(int64_t)identifier
{
    return [[MLAlbum alloc] initWithAlbumPtr:_ml->album(identifier)];
}

- (NSArray<MLAlbum *> *)albumsWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto albums = _ml->albums((medialibrary::SortingCriteria)criteria, desc);
    NSMutableArray *result = [NSMutableArray array];
    auto albums = _ml->albums((medialibrary::SortingCriteria)sort, desc);

    for (const auto &album : albums) {
        [result addObject:[[MLAlbum alloc] initWithAlbumPtr:album]];
    }
    return result;
}

#pragma mark - Show

- (MLShow *)showWithName:(NSString *)name
{
    return [[MLShow alloc] initWithShowPtr:_ml->show([name UTF8String
                                                      ])];
}

#pragma mark - Movie
//issue, if called multiple times with the same name mulitple instance of mlmovie will be created!
- (MLMovie *)movieWithName:(NSString *)name
{
    return [[MLMovie alloc] initWithMoviePtr:_ml->movie([name UTF8String])];
}

#pragma mark - Artist

- (MLArtist *)artistWithIdentifier:(int64_t)identifier
{
    return [[MLArtist alloc] initWithArtistPtr:_ml->artist(identifier)];
}

- (NSArray<MLArtist *> *)artistsWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto artists = _ml->artists((medialibrary::SortingCriteria)criteria, desc);
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &artist : artists) {
        [result addObject:[[MLArtist alloc] initWithArtistPtr:artist]];
    }
    return result;
}

#pragma mark - Genre

- (NSArray<MLGenre *> *)genresWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto genres = _ml->genres((medialibrary::SortingCriteria)criteria, desc);
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &genre : genres) {
        [result addObject:[[MLGenre alloc] initWithGenrePtr:genre]];
    }
    return result;
}

- (MLGenre *)genreWithIdentifier:(int64_t)identifier
{
    return [[MLGenre alloc] initWithGenrePtr:_ml->genre(identifier)];
}

#pragma mark - Playlist

- (MLPlaylist *)createPlaylistWithName:(NSString *)name
{
    return [[MLPlaylist alloc] initWithPlaylistPtr:_ml->createPlaylist([name UTF8String])];
}

- (NSArray<MLPlaylist *> *)playlistsWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto playlists = _ml->playlists((medialibrary::SortingCriteria)criteria, desc);
    NSMutableArray *result = [NSMutableArray array];
    auto playlists = _ml->playlists((medialibrary::SortingCriteria)sort, desc);

    for (const auto &playlist : playlists) {
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
    return _ml->addToStreamHistory([media mediaPtr]);
}

- (NSArray<MLHistoryEntry *> *)lastStreamsPlayed
{
    auto history = _ml->lastStreamsPlayed();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &historyEntry : history) {
        [result addObject:[[MLHistoryEntry alloc] initWithHistoryPtr:historyEntry]];
    }
    return result;
}

- (NSArray<MLMedia *> *)lastMediaPlayed
{
    auto mediaList = _ml->lastMediaPlayed();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &media : mediaList) {
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
- (NSArray<MLPlaylist *> *)searchPlaylistsByName:(NSString *)name
{
    auto playlists = _ml->searchPlaylists([name UTF8String]);
    NSMutableArray<MLPlaylist *> *result = [NSMutableArray array];

    for (const auto &playlist : playlists) {
        [result addObject:[[MLPlaylist alloc] initWithPlaylistPtr:playlist]];
    }
    return result;
}

- (NSArray<MLAlbum *> *)searchAlbumsByPattern:(NSString *)pattern
{
    auto albums = _ml->searchAlbums([pattern UTF8String]);
    NSMutableArray<MLAlbum *> *result = [NSMutableArray array];

    for (const auto &album : albums) {
        [result addObject:[[MLAlbum alloc] initWithAlbumPtr:album]];
    }
    return result;
}

- (NSArray<MLGenre *> *)searchGenreByName:(NSString *)name
{
    auto genres = _ml->searchGenre([name UTF8String]);
    NSMutableArray<MLGenre *> *result = [NSMutableArray array];

    for (const auto &genre : genres) {
        [result addObject:[[MLGenre alloc] initWithGenrePtr:genre]];
    }
    return result;
}

- (NSArray<MLArtist *> *)searchArtistsByName:(NSString *)name
{
    auto artists = _ml->searchArtists([name UTF8String]);
    NSMutableArray<MLArtist *> *result = [NSMutableArray array];

    for (const auto &artist : artists) {
        [result addObject:[[MLArtist alloc] initWithArtistPtr:artist]];
    }
    return result;
}

#pragma mark - Discover

- (void)discoverOnEntryPoint:(NSString *)path
{
    _ml->discover([path UTF8String]);
}

- (void)enableDiscoverNetwork:(BOOL)enable
{
    _ml->setDiscoverNetworkEnabled(enable);
}

- (NSArray<MLFolder *> *)entryPoints
{
    auto entryPoints = _ml->entryPoints();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &entryPoint : entryPoints) {
        [result addObject:[[MLFolder alloc] initWithFolderPtr:entryPoint]];
    }
    return result;
}

- (void)removeEntryPointWithPath:(NSString *)path
{
    _ml->removeEntryPoint([path UTF8String]);
}

#pragma mark - Folder

- (void)banFolderWithPath:(NSString *)path
{
    _ml->banFolder([path UTF8String]);
}

- (void)unbanFolderWithEntryPoint:(NSString *)entryPoint
{
    _ml->unbanFolder([entryPoint UTF8String]);
}

#pragma mark - Thumbnail
- (NSString *)thumbnailPath
{
    if (!_thumbnailPath)
        _thumbnailPath = [[NSString alloc] initWithUTF8String:_ml->thumbnailPath().c_str()];
    return _thumbnailPath;
}

#pragma mark - Logger

#pragma mark - Background Operation

- (void)pauseBackgroundOperations
{
    _ml->pauseBackgroundOperations();
}

- (void)resumeBackgroundOperations
{
    _ml->resumeBackgroundOperations();
}

#pragma mark - Reload

- (void)reload
{
    _ml->reload();
}

- (void)reloadEntryPoint:(NSString *)entryPoint
{
    _ml->reload([entryPoint UTF8String]);
}

#pragma mark - Parser

- (void)forceParserRetry
{
    _ml->forceParserRetry();
}

#pragma mark -

@end
