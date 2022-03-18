/*****************************************************************************
 * VLCMediaLibrary.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2021 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
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

#import "VLCMediaLibrary.h"
#import "VLCMLAlbum+Init.h"
#import "VLCMLArtist+Init.h"
#import "VLCMLFolder+Init.h"
#import "VLCMLGenre+Init.h"
#import "VLCMLLabel+Init.h"
#import "VLCMLMedia+Init.h"
#import "VLCMLMovie+Init.h"
#import "VLCMLPlaylist+Init.h"
#import "VLCMLShow+Init.h"
#import "VLCMLMediaGroup+Init.h"
#import "VLCMLUtils.h"
#import "VLCMLSearchAggregate.h"

#import "MediaLibraryCb.h"
#import "DeviceListerCb.h"
#import "VLCMLDeviceLister.h"

VLCMLIdentifier const UnknownArtistID = 1u;
VLCMLIdentifier const VariousArtistID = 2u;

@interface VLCMediaLibrary ()
{
    BOOL _isInitialized;

    medialibrary::MediaLibraryCb *_mlCb;
    medialibrary::DeviceListerCb *_deviceListerCb;

    medialibrary::IMediaLibrary *_ml;
    medialibrary::DeviceListerPtr _deviceLister;
}

@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, copy) NSString *medialibraryPath;
@end

@implementation VLCMediaLibrary

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isInitialized = NO;
        _deviceLister = std::make_shared<medialibrary::fs::VLCMLDeviceLister>();
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

- (void)setDeviceListerDelegate:(id<VLCMLDeviceListerDelegate>)deviceListerDelegate
{
    if (_deviceListerDelegate != deviceListerDelegate) {
        _deviceListerDelegate = deviceListerDelegate;
        _deviceListerCb->setDelegate(_deviceListerDelegate);
    }
}

- (VLCMLInitializeResult)setupMediaLibraryWithDatabasePath:(NSString *)databasePath
                                          medialibraryPath:(NSString *)medialibraryPath
{
    medialibrary::SetupConfig config;
    config.deviceListers["file://"] = _deviceLister;

    _ml = NewMediaLibrary([databasePath UTF8String], [medialibraryPath UTF8String],
                           false, &config);

    _mlCb = new medialibrary::MediaLibraryCb(self, _delegate);

    VLCMLInitializeResult result = (VLCMLInitializeResult)_ml->initialize(_mlCb);

    if (result == VLCMLInitializeResultSuccess) {
        _isInitialized = YES;
        _databasePath = databasePath;
        _medialibraryPath = medialibraryPath;
    }
    return result;
}

- (void)setVerbosity:(VLCMLLogLevel)level
{
    _ml->setVerbosity((medialibrary::LogLevel)level);
}

#pragma mark -
#pragma mark Medialibrary main methods

#pragma mark - Label

- (VLCMLLabel *)createLabelWithName:(NSString *)name
{
    return [[VLCMLLabel alloc] initWithLabelPtr:_ml->createLabel([name UTF8String])];
}

- (BOOL)deleteLabel:(VLCMLLabel *)label
{
    return _ml->deleteLabel([label labelPtr]);
}

#pragma mark - Media

- (VLCMLMedia *)mediaWithIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLMedia alloc] initWithMediaPtr:_ml->media(identifier)];
}

- (VLCMLMedia *)mediaWithMrl:(NSURL *)mrl
{
    return [[VLCMLMedia alloc] initWithMediaPtr:_ml->media([mrl.absoluteString UTF8String])];
}

- (VLCMLMedia *)addExternalMediaWithMrl:(NSURL *)mrl
{
    return [[VLCMLMedia alloc] initWithMediaPtr:_ml->addExternalMedia([mrl.absoluteString UTF8String], -1)];
}

- (VLCMLMedia *)addExternalMediaWithMrl:(NSURL *)mrl duration:(int64_t)duration
{
    return [[VLCMLMedia alloc] initWithMediaPtr:_ml->addExternalMedia([mrl.absoluteString UTF8String], duration)];
}

- (VLCMLMedia *)addStreamWithMrl:(NSURL *)mrl
{
    return [[VLCMLMedia alloc] initWithMediaPtr:_ml->addStream([mrl.absoluteString UTF8String])];
}

- (BOOL)removeExternalMedia:(VLCMLMedia *)media
{
    return _ml->removeExternalMedia(media.mediaPtr);
}

- (NSArray<VLCMLMedia *> *)audioFiles
{
    return [VLCMLUtils arrayFromMediaQuery:_ml->audioFiles()];
}

- (NSArray<VLCMLMedia *> *)audioFilesWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_ml->audioFiles(&param)];
}

- (NSArray<VLCMLMedia *> *)videoFiles
{
    return [VLCMLUtils arrayFromMediaQuery:_ml->videoFiles()];
}

- (NSArray<VLCMLMedia *> *)videoFilesWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_ml->videoFiles(&param)];
}

- (NSArray<VLCMLMedia *> *)movies
{
    return [VLCMLUtils arrayFromMediaQuery:_ml->movies()];
}

- (NSArray<VLCMLMedia *> *)moviesWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_ml->movies(&param)];
}

- (NSArray<VLCMLMedia *> *)inProgressMediaOfType:(VLCMLMediaType)type
                             withSortingCriteria:(VLCMLSortingCriteria)criteria
                                            desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_ml->inProgressMedia((medialibrary::IMedia::Type)type, &param)];
}

#pragma mark - Media groups

- (nullable VLCMLMediaGroup *)createMediaGroupWithName:(NSString *)name
{
    return [[VLCMLMediaGroup alloc]
            initWithMediaGroupPtr:_ml->createMediaGroup([name UTF8String])];
}

- (nullable VLCMLMediaGroup *)createMediaGroupWithMediaIds:(NSArray<NSNumber *> *)mediaIds
{
    std::vector<int64_t> cppMediaIds(mediaIds.count);

    for (NSNumber *mediaId in mediaIds) {
        cppMediaIds.push_back(mediaId.longLongValue);
    }
    return [[VLCMLMediaGroup alloc]
            initWithMediaGroupPtr:_ml->createMediaGroup(cppMediaIds)];
}

- (BOOL)deleteMediaGroupWithIdentifier:(VLCMLIdentifier)identifer
{
    return _ml->deleteMediaGroup(identifer);
}

- (nullable VLCMLMediaGroup *)mediaGroupWithIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLMediaGroup alloc] initWithMediaGroupPtr:_ml->mediaGroup(identifier)];
}

- (nullable NSArray<VLCMLMediaGroup *> *)mediaGroups
{
    return [self mediaGroupsOfType:VLCMLMediaTypeUnknown];
}

- (nullable NSArray<VLCMLMediaGroup *> *)mediaGroupsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                                   desc:(BOOL)desc
{
    return [self mediaGroupsOfType:VLCMLMediaTypeUnknown
                   sortingCriteria:criteria
                              desc:desc];
}

- (nullable NSArray<VLCMLMediaGroup *> *)mediaGroupsOfType:(VLCMLMediaType)type
{
    return [VLCMLUtils arrayFromMediaGroupQuery:_ml->mediaGroups((medialibrary::IMedia::Type)type)];
}
- (nullable NSArray<VLCMLMediaGroup *> *)mediaGroupsOfType:(VLCMLMediaType)type
                                           sortingCriteria:(VLCMLSortingCriteria)criteria
                                                      desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaGroupQuery:_ml->mediaGroups((medialibrary::IMedia::Type)type,
                                                                 &param)];
}

- (BOOL)regroupAll
{
    return _ml->regroupAll();
}

#pragma mark - Album

- (VLCMLAlbum *)albumWithIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLAlbum alloc] initWithAlbumPtr:_ml->album(identifier)];
}

- (NSArray<VLCMLAlbum *> *)albums
{
    return [VLCMLUtils arrayFromAlbumQuery:_ml->albums()];
}

- (NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromAlbumQuery:_ml->albums(&param)];
}

#pragma mark - Show

- (VLCMLShow *)showWithIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLShow alloc] initWithShowPtr:_ml->show(identifier)];
}

#pragma mark - Movie

- (VLCMLMovie *)movieWitIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLMovie alloc] initWithMoviePtr:_ml->movie(identifier)];
}

#pragma mark - Artist

- (VLCMLArtist *)artistWithIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLArtist alloc] initWithArtistPtr:_ml->artist(identifier)];
}

- (NSArray<VLCMLArtist *> *)artists:(BOOL)includeAll
{
    return [VLCMLUtils arrayFromArtistQuery:_ml->artists(includeAll ? medialibrary::ArtistIncluded::All :
                                                         medialibrary::ArtistIncluded::AlbumArtistOnly)];
}

- (NSArray<VLCMLArtist *> *)artistsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                  desc:(BOOL)desc all:(BOOL)includeAll
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromArtistQuery:_ml->artists(includeAll ? medialibrary::ArtistIncluded::All :
                                                         medialibrary::ArtistIncluded::AlbumArtistOnly,
                                                         &param)];
}

#pragma mark - Genre

- (VLCMLGenre *)genreWithIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLGenre alloc] initWithGenrePtr:_ml->genre(identifier)];
}

- (NSArray<VLCMLGenre *> *)genres
{
    return [VLCMLUtils arrayFromGenreQuery:_ml->genres()];
}

- (NSArray<VLCMLGenre *> *)genresWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromGenreQuery:_ml->genres(&param)];
}

#pragma mark - Playlist

- (VLCMLPlaylist *)playlistWithIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLPlaylist alloc] initWithPlaylistPtr:_ml->playlist(identifier)];
}

- (NSArray<VLCMLPlaylist *> *)playlists
{
    return [VLCMLUtils arrayFromPlaylistQuery:_ml->playlists( medialibrary::PlaylistType::All )];
}

- (NSArray<VLCMLPlaylist *> *)playlistsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromPlaylistQuery:_ml->playlists( medialibrary::PlaylistType::All, &param)];
}

- (VLCMLPlaylist *)createPlaylistWithName:(NSString *)name
{
    return [[VLCMLPlaylist alloc] initWithPlaylistPtr:_ml->createPlaylist([name UTF8String])];
}

- (BOOL)deletePlaylistWithIdentifier:(VLCMLIdentifier)identifier
{
    return _ml->deletePlaylist(identifier);
}

#pragma mark - History

- (NSArray<VLCMLMedia *> *)history
{
    return [VLCMLUtils arrayFromMediaQuery:_ml->history()];
}

- (NSArray<VLCMLMedia *> *)streamHistory
{
    return [VLCMLUtils arrayFromMediaQuery:_ml->streamHistory()];
}

- (BOOL)clearHistory
{
    return _ml->clearHistory();
}

#pragma mark - Search

- (NSArray<VLCMLMedia *> *)searchMedia:(NSString *)pattern
{
    return [VLCMLUtils arrayFromMediaQuery:_ml->searchMedia([pattern UTF8String])];
}

- (NSArray<VLCMLMedia *> *)searchMedia:(NSString *)pattern
                                  sort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_ml->searchMedia([pattern UTF8String], &param)];
}

- (NSArray<VLCMLPlaylist *> *)searchPlaylistsByName:(NSString *)name
{
    return [VLCMLUtils arrayFromPlaylistQuery:_ml->searchPlaylists([name UTF8String])];
}

- (NSArray<VLCMLPlaylist *> *)searchPlaylistsByName:(NSString *)name
                                               sort:(VLCMLSortingCriteria)criteria
                                               desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromPlaylistQuery:_ml->searchPlaylists([name UTF8String], &param)];
}

- (NSArray<VLCMLAlbum *> *)searchAlbumsByPattern:(NSString *)pattern
{
    return [VLCMLUtils arrayFromAlbumQuery:_ml->searchAlbums([pattern UTF8String])];
}

- (NSArray<VLCMLAlbum *> *)searchAlbumsByPattern:(NSString *)pattern
                                            sort:(VLCMLSortingCriteria)criteria
                                            desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromAlbumQuery:_ml->searchAlbums([pattern UTF8String], &param)];
}

- (NSArray<VLCMLGenre *> *)searchGenreByName:(NSString *)name
{
    return [VLCMLUtils arrayFromGenreQuery:_ml->searchGenre([name UTF8String])];
}

- (NSArray<VLCMLGenre *> *)searchGenreByName:(NSString *)name
                                        sort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromGenreQuery:_ml->searchGenre([name UTF8String], &param)];
}

- (NSArray<VLCMLArtist *> *)searchArtistsByName:(NSString *)name all:(BOOL)includeAll
{
    return [VLCMLUtils arrayFromArtistQuery:_ml->searchArtists([name UTF8String],
                                                               includeAll ? medialibrary::ArtistIncluded::All :
                                                               medialibrary::ArtistIncluded::AlbumArtistOnly)];
}

- (NSArray<VLCMLArtist *> *)searchArtistsByName:(NSString *)name all:(BOOL)includeAll
                                           sort:(VLCMLSortingCriteria)criteria
                                           desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromArtistQuery:_ml->searchArtists([name UTF8String],
                                                               includeAll ? medialibrary::ArtistIncluded::All :
                                                               medialibrary::ArtistIncluded::AlbumArtistOnly,
                                                               &param)];
}

- (NSArray<VLCMLFolder *> *)searchFoldersWithPattern:(NSString *)pattern
{
    return [self searchFoldersWithPattern:pattern type:VLCMLMediaTypeUnknown];
}

- (NSArray<VLCMLFolder *> *)searchFoldersWithPattern:(NSString *)pattern type:(VLCMLMediaType)type
{
    return [VLCMLUtils arrayFromFolderQuery:_ml->searchFolders([pattern UTF8String],
                                                               (medialibrary::IMedia::Type)type)];
}

- (NSArray<VLCMLFolder *> *)searchFoldersWithPattern:(NSString *)pattern
                                     sortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
{
    return [self searchFoldersWithPattern:pattern
                                     type:VLCMLMediaTypeUnknown
                          sortingCriteria:criteria
                                     desc:desc];
}

- (NSArray<VLCMLFolder *> *)searchFoldersWithPattern:(NSString *)pattern
                                                type:(VLCMLMediaType)type
                                     sortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromFolderQuery:_ml->searchFolders([pattern UTF8String],
                                                               (medialibrary::IMedia::Type)type,
                                                               &param)];
}

- (nullable NSArray<VLCMLMediaGroup *> *)searchMediaGroupsWithPattern:(NSString *)pattern
{
    return [self searchMediaGroupsWithPattern:pattern
                                         sort:VLCMLSortingCriteriaDefault desc:NO];
}

- (nullable NSArray<VLCMLMediaGroup *> *)searchMediaGroupsWithPattern:(NSString *)pattern
                                                                 sort:(VLCMLSortingCriteria)criteria
                                                                 desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaGroupQuery:_ml->searchMediaGroups([pattern UTF8String],
                                                                       &param)];
}

- (VLCMLSearchAggregate *)convertSearchResult:(medialibrary::SearchAggregate *)searchResult
{
    return [VLCMLSearchAggregate
            initWithAlbums:[VLCMLUtils arrayFromAlbumQuery:std::move(searchResult->albums)]
            artists:[VLCMLUtils arrayFromArtistQuery:std::move(searchResult->artists)]
            genres:[VLCMLUtils arrayFromGenreQuery:std::move(searchResult->genres)]
            media:[VLCMLUtils arrayFromMediaQuery:std::move(searchResult->media)]
            playlists:[VLCMLUtils arrayFromPlaylistQuery:std::move(searchResult->playlists)]];
}

- (VLCMLSearchAggregate *)search:(NSString *)pattern
{
    medialibrary::SearchAggregate searchResult = _ml->search([pattern UTF8String]);
    return [self convertSearchResult:&searchResult];
}

- (VLCMLSearchAggregate *)search:(NSString *)pattern
                            sort:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];
    medialibrary::SearchAggregate searchResult = _ml->search([pattern UTF8String], &param);

    return [self convertSearchResult:&searchResult];
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

- (NSArray<VLCMLFolder *> *)entryPoints
{
    return [VLCMLUtils arrayFromFolderQuery:_ml->entryPoints()];
}

- (void)removeEntryPointWithPath:(NSString *)path
{
    _ml->removeEntryPoint([path UTF8String]);
}

#pragma mark - Folder

- (VLCMLFolder *)folderWithIdentifier:(VLCMLIdentifier)identifier
{
    return [[VLCMLFolder alloc] initWithFolderPtr:_ml->folder(identifier)];
}

- (VLCMLFolder *)folderAtMrl:(NSURL *)mrl
{
    return [[VLCMLFolder alloc] initWithFolderPtr:_ml->folder([mrl.absoluteString UTF8String])];
}

- (NSArray<VLCMLFolder *> *)folders
{
    return [self foldersOfType:VLCMLMediaTypeUnknown];
}

- (NSArray<VLCMLFolder *> *)foldersOfType:(VLCMLMediaType)type
{
    return [VLCMLUtils arrayFromFolderQuery:_ml->folders((medialibrary::IMedia::Type)type)];
}

- (NSArray<VLCMLFolder *> *)foldersWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                  desc:(BOOL)desc
{
    return [self foldersWithSortingCriteria:criteria type:VLCMLMediaTypeUnknown desc:desc];
}

- (NSArray<VLCMLFolder *> *)foldersWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                  type:(VLCMLMediaType)type
                                                  desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromFolderQuery:_ml->folders((medialibrary::IMedia::Type)type,
                                                         &param)];
}

- (void)banFolderWithPath:(NSString *)path
{
    _ml->banFolder([path UTF8String]);
}

- (void)unbanFolderWithEntryPoint:(NSString *)entryPoint
{
    _ml->unbanFolder([entryPoint UTF8String]);
}

#pragma mark - Thumbnail

- (void)enableFailedThumbnailRegeneration
{
    _ml->enableFailedThumbnailRegeneration();
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

#pragma mark - Scan

- (void)forceRescan
{
    _ml->forceRescan();
}
#pragma mark - Database

- (void)clearDatabaseWithRestorePlaylists:(BOOL)restorePlaylists
{
    _ml->clearDatabase(restorePlaylists);
}

#pragma mark - Extensions

- (NSArray<NSString *> *)arrayFromVector:(std::vector<const char*>)vector
{
    NSMutableArray *res = [NSMutableArray array];

    for ( const auto &it :vector )
    {
        [res addObject:[NSString stringWithUTF8String:it]];
    }
    return [res copy];
}

- (NSArray<NSString *> *)supportedMediaExtensions
{
    return [self arrayFromVector:_ml->supportedMediaExtensions()];
}

- (BOOL)isMediaExtensionSupported:(NSString *)extension
{
    return _ml->isMediaExtensionSupported(extension.UTF8String);
}

- (NSArray<NSString *> *)supportedPlaylistExtensions
{
    return [self arrayFromVector:_ml->supportedPlaylistExtensions()];
}

- (BOOL)isPlaylistExtensionSupported:(NSString *)extension
{
    return _ml->isPlaylistExtensionSupported(extension.UTF8String);
}

#pragma mark -

@end
