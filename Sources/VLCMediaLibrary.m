/*****************************************************************************
 * VLCMediaLibrary.m
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

#import "VLCMediaLibrary.h"
#import "VLCAlbumTrack.h"
#import "VLCAlbum+Init.h"
#import "VLCArtist+Init.h"
#import "VLCFolder+Init.h"
#import "VLCGenre+Init.h"
#import "VLCHistoryEntry+Init.h"
#import "VLCLabel+Init.h"
#import "VLCMedia+Init.h"
#import "VLCMovie+Init.h"
#import "VLCPlaylist+Init.h"
#import "VLCShow+Init.h"
#import "VLCUtils.h"
#import "VLCMediaSearchAggregate.h"
#import "VLCSearchAggregate.h"

#import "MediaLibraryCb.h"
#import "DeviceListerCb.h"
#import "VLCDeviceLister.h"

@interface VLCMediaLibrary ()
{
    BOOL _isInitialized;

    medialibrary::MediaLibraryCb *_mlCb;
    medialibrary::DeviceListerCb *_deviceListerCb;

    medialibrary::IMediaLibrary *_ml;
    medialibrary::DeviceListerPtr _deviceLister;
}
@end

@implementation VLCMediaLibrary

#pragma mark - Shared methods

+ (instancetype)sharedMediaLibrary
{
    static VLCMediaLibrary *sharedMediaLibrary = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedMediaLibrary = [[VLCMediaLibrary alloc] init];
    });

    return sharedMediaLibrary;
}

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isInitialized = NO;
        _ml = NewMediaLibrary();
        _mlCb = new medialibrary::MediaLibraryCb(_delegate);
        _deviceListerCb = new medialibrary::DeviceListerCb(_deviceListerDelegate);
    }
    return self;
}

- (void)dealloc
{
    if (_mlCb) {
        delete _mlCb;
    }
    if (_deviceListerCb) {
        delete _deviceListerCb;
    }
    if (_ml) {
        delete _ml;
    }
}

- (void)setDelegate:(id<VLCMediaLibraryDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        _mlCb->setDelegate(_delegate);
    }
}

- (void)setDeviceListerDelegate:(id<VLCDeviceListerDelegate>)deviceListerDelegate
{
    if (_deviceListerDelegate != deviceListerDelegate) {
        _deviceListerDelegate = deviceListerDelegate;
        _deviceListerCb->setDelegate(_deviceListerDelegate);
    }
}

- (BOOL)start
{
    BOOL success = _ml->start();

    return success;
}

- (BOOL)setupMediaLibraryWithDb:(NSString *)dbPath thumbnailPath:(NSString *)thumbnailPath
{
    [self setDeviceLister:(_deviceLister)];
    medialibrary::InitializeResult success = _ml->initialize([dbPath UTF8String], [thumbnailPath UTF8String], _mlCb);

    if (success == medialibrary::InitializeResult::Success) {
        _isInitialized = YES;
        _dbPath = dbPath;
        _thumbnailPath = thumbnailPath;
    }
    return success == medialibrary::InitializeResult::Success;
}

- (void)setVerbosity:(VLCLogLevel)level
{
    _ml->setVerbosity((medialibrary::LogLevel)level);
}

#pragma mark -
#pragma mark Medialibrary main methods

#pragma mark - Label

- (VLCLabel *)createLabelWithName:(NSString *)name
{
    return [[VLCLabel alloc] initWithLabelPtr:_ml->createLabel([name UTF8String])];
}

- (BOOL)deleteLabel:(VLCLabel *)label
{
    return _ml->deleteLabel([label labelPtr]);
}

#pragma mark - Media

- (VLCMedia *)mediaWithIdentifier:(int64_t)identifier
{
    return [[VLCMedia alloc] initWithMediaPtr:_ml->media(identifier)];
}

- (VLCMedia *)mediaWithMrl:(NSString *)mrl
{
    return [[VLCMedia alloc] initWithMediaPtr:_ml->media([mrl UTF8String])];
}

- (VLCMedia *)addMediaWithMrl:(NSString *)mrl
{
    return [[VLCMedia alloc] initWithMediaPtr:_ml->addMedia([mrl UTF8String])];
}

- (NSArray<VLCMedia *> *)audioFilesWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    return [VLCUtils arrayFromMediaPtrVector:_ml->audioFiles((medialibrary::SortingCriteria)criteria, desc)];
}

- (NSArray<VLCMedia *> *)videoFilesWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    return [VLCUtils arrayFromMediaPtrVector:_ml->videoFiles((medialibrary::SortingCriteria)criteria, desc)];
}

#pragma mark - Album

- (VLCAlbum *)albumWithIdentifier:(int64_t)identifier
{
    return [[VLCAlbum alloc] initWithAlbumPtr:_ml->album(identifier)];
}

- (NSArray<VLCAlbum *> *)albumsWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    return [VLCUtils arrayFromAlbumPtrVector:_ml->albums((medialibrary::SortingCriteria)criteria, desc)];
}

#pragma mark - Show

- (VLCShow *)showWithName:(NSString *)name
{
    return [[VLCShow alloc] initWithShowPtr:_ml->show([name UTF8String])];
}

#pragma mark - Movie

- (VLCMovie *)movieWithName:(NSString *)name
{
    return [[VLCMovie alloc] initWithMoviePtr:_ml->movie([name UTF8String])];
}

#pragma mark - Artist

- (VLCArtist *)artistWithIdentifier:(int64_t)identifier
{
    return [[VLCArtist alloc] initWithArtistPtr:_ml->artist(identifier)];
}

- (NSArray<VLCArtist *> *)artistsWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    return [VLCUtils arrayFromArtistPtrVector:_ml->artists((medialibrary::SortingCriteria)criteria, desc)];
}

#pragma mark - Genre

- (NSArray<VLCGenre *> *)genresWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    return [VLCUtils arrayFromGenrePtrVector:_ml->genres((medialibrary::SortingCriteria)criteria, desc)];
}

- (VLCGenre *)genreWithIdentifier:(int64_t)identifier
{
    return [[VLCGenre alloc] initWithGenrePtr:_ml->genre(identifier)];
}

#pragma mark - Playlist

- (VLCPlaylist *)createPlaylistWithName:(NSString *)name
{
    return [[VLCPlaylist alloc] initWithPlaylistPtr:_ml->createPlaylist([name UTF8String])];
}

- (NSArray<VLCPlaylist *> *)playlistsWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
   return [VLCUtils arrayFromPlaylistPtrVector:_ml->playlists((medialibrary::SortingCriteria)criteria, desc)];
}

- (VLCPlaylist *)playlistWithIdentifier:(int64_t)identifier
{
    return [[VLCPlaylist alloc] initWithPlaylistPtr:_ml->playlist(identifier)];
}

- (BOOL)deletePlaylistWithIdentifier:(int64_t)identifier
{
    return _ml->deletePlaylist(identifier);
}

#pragma mark - History

- (BOOL)addMediaToStreamHistory:(VLCMedia *)media
{
    return _ml->addToStreamHistory([media mediaPtr]);
}

- (NSArray<VLCHistoryEntry *> *)lastStreamsPlayed
{
    auto history = _ml->lastStreamsPlayed();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &historyEntry : history) {
        [result addObject:[[VLCHistoryEntry alloc] initWithHistoryPtr:historyEntry]];
    }
    return result;
}

- (NSArray<VLCMedia *> *)lastMediaPlayed
{
    return [VLCUtils arrayFromMediaPtrVector:_ml->lastMediaPlayed()];
}

- (BOOL)clearHistory
{
    return _ml->clearHistory();
}

#pragma mark - Search

- (VLCMediaSearchAggregate *)_convertMediaSearchAggregate:(medialibrary::MediaSearchAggregate)searchResult
{
    return [VLCMediaSearchAggregate initWithEpisodes:[VLCUtils arrayFromMediaPtrVector:searchResult.episodes]
                                             movies:[VLCUtils arrayFromMediaPtrVector:searchResult.movies]
                                             others:[VLCUtils arrayFromMediaPtrVector:searchResult.others]
                                             tracks:[VLCUtils arrayFromMediaPtrVector:searchResult.tracks]];
}

- (VLCMediaSearchAggregate *)searchMedia:(NSString *)pattern
{
    return [self _convertMediaSearchAggregate:_ml->searchMedia([pattern UTF8String])];
}

- (NSArray<VLCPlaylist *> *)searchPlaylistsByName:(NSString *)name
{
    return [VLCUtils arrayFromPlaylistPtrVector:_ml->searchPlaylists([name UTF8String])];
}

- (NSArray<VLCAlbum *> *)searchAlbumsByPattern:(NSString *)pattern
{
    return [VLCUtils arrayFromAlbumPtrVector:_ml->searchAlbums([pattern UTF8String])];
}

- (NSArray<VLCGenre *> *)searchGenreByName:(NSString *)name
{
    return [VLCUtils arrayFromGenrePtrVector:_ml->searchGenre([name UTF8String])];
}

- (NSArray<VLCArtist *> *)searchArtistsByName:(NSString *)name
{
    return [VLCUtils arrayFromArtistPtrVector:_ml->searchArtists([name UTF8String])];
}

- (VLCSearchAggregate *)search:(NSString *)pattern
{
    medialibrary::SearchAggregate searchResult = _ml->search([pattern UTF8String]);

    return [VLCSearchAggregate initWithAlbums:[VLCUtils arrayFromAlbumPtrVector:searchResult.albums]
                                     artists:[VLCUtils arrayFromArtistPtrVector:searchResult.artists]
                                      genres:[VLCUtils arrayFromGenrePtrVector:searchResult.genres]
                        mediaSearchAggregate:[self _convertMediaSearchAggregate:searchResult.media]
                                   playlists:[VLCUtils arrayFromPlaylistPtrVector:searchResult.playlists]];
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

- (NSArray<VLCFolder *> *)entryPoints
{
    auto entryPoints = _ml->entryPoints();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &entryPoint : entryPoints) {
        [result addObject:[[VLCFolder alloc] initWithFolderPtr:entryPoint]];
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
    if (!_thumbnailPath) {
        _thumbnailPath = [[NSString alloc] initWithUTF8String:_ml->thumbnailPath().c_str()];
    }
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

#pragma mark - DeviceLister

- (void)setDeviceLister:(medialibrary::DeviceListerPtr)lister
{
    _deviceLister = std::make_shared<medialibrary::fs::VLCDeviceLister>();
    _ml->setDeviceLister(lister);
}

#pragma mark -

@end
