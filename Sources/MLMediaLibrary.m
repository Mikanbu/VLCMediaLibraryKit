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
#import "MLTitleDecrapifier.h"
#import "MLFile.h"
#import "MLLabel.h"
#import "MLShowEpisode.h"
#import "MLShow.h"
#import "MLThumbnailerQueue.h"
#import "MLAlbumTrack.h"
#import "MLAlbum.h"
#import "MLFileParserQueue.h"
#import "MLCrashPreventer.h"
#import "MLMediaLibrary+Migration.h"
#import <sys/sysctl.h> // for sysctlbyname

#if TARGET_OS_IOS
//#import <CoreSpotlight/CoreSpotlight.h>
#endif

#if HAVE_BLOCK
#import "MLMovieInfoGrabber.h"
#import "MLTVShowInfoGrabber.h"
#import "MLTVShowEpisodesInfoGrabber.h"
#endif

@interface MLMediaLibrary ()
{
    BOOL _allowNetworkAccess;
    int _deviceSpeedCategory;

    NSString *_thumbnailFolderPath;
    NSString *_databaseFolderPath;
    NSString *_documentFolderPath;
    NSString *_libraryBasePath;
}
@end

// Pref key
static NSString *kLastTVDBUpdateServerTime = @"MLLastTVDBUpdateServerTime";
static NSString *kDecrapifyTitles = @"MLDecrapifyTitles";

//#if HAVE_BLOCK
//@interface MLMediaLibrary () <MLMovieInfoGrabberDelegate, MLTVShowEpisodesInfoGrabberDelegate, MLTVShowInfoGrabberDelegate>
//#else
//@interface MLMediaLibrary ()
//#endif
//- (NSString *)databaseFolderPath;
//@end

@implementation MLMediaLibrary

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{kDecrapifyTitles : @YES}];
}

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

+ (medialibrary::IMediaLibrary *)sharedInstance
{
    return [[self sharedMediaLibrary] instance];
}

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *key = @"MLKitGroupIdentifier";
        _applicationGroupIdentifier = [[[NSBundle bundleForClass:self.class] infoDictionary] valueForKey:key];
        if (!_applicationGroupIdentifier) {
            _applicationGroupIdentifier = [[[NSBundle mainBundle] infoDictionary] valueForKey:key];
        }
        if (!_applicationGroupIdentifier) {
            _applicationGroupIdentifier = @"group.org.videolan.vlc-ios";
        }

        _instance = NewMediaLibrary();
    }
    return self;
}

- (void)dealloc
{
    //removes shared instances. ARC
}


#pragma mark -
#pragma mark Media Library


#pragma mark - Path handling
- (void)setLibraryBasePath:(NSString *)libraryBasePath
{
    _libraryBasePath = [libraryBasePath copy];
    _databaseFolderPath = nil;
    _thumbnailFolderPath = nil;
    _persistentStoreURL = nil;
}

- (NSString *)databaseFolderPath
{
    if (_databaseFolderPath.length == 0) {
        _databaseFolderPath = self.libraryBasePath;
    }
    return _databaseFolderPath;
}

- (NSString *)thumbnailFolderPath
{
    if (_thumbnailFolderPath.length == 0) {
        _thumbnailFolderPath = [self.libraryBasePath stringByAppendingPathComponent:@"Thumbnails"];
    }
    return _thumbnailFolderPath;
}

- (NSURL *)persistentStoreURL
{
    if (_persistentStoreURL == nil) {
        NSString *databaseFolderPath = [self databaseFolderPath];
        NSString *path = [databaseFolderPath stringByAppendingPathComponent: @"MediaLibrary.sqlite"];
        _persistentStoreURL = [NSURL fileURLWithPath:path];
    }
    return _persistentStoreURL;
}

- (NSString *)pathRelativeToDocumentsFolderFromAbsolutPath:(NSString *)absolutPath
{
//    return [absolutPath stringByReplacingOccurrencesOfString:self.documentFolderPath withString:@""];
    return NULL;
}
- (NSString *)absolutPathFromPathRelativeToDocumentsFolder:(NSString *)relativePath
{
//    return [self.documentFolderPath stringByAppendingPathComponent:relativePath];
    return NULL;
}

#pragma mark -

- (NSPersistentStore *)addDefaultLibraryStoreToCoordinator:(NSPersistentStoreCoordinator *)coordinator withError:(NSError **)error {

    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES,
                              NSSQLitePragmasOption : @{@"journal_mode": @"DELETE"}};

    if (self.additionalPersitentStoreOptions.count > 0) {
        NSMutableDictionary *mutableOptions = options.mutableCopy;
        [mutableOptions addEntriesFromDictionary:self.additionalPersitentStoreOptions];
        options = mutableOptions;
    }
    return [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.persistentStoreURL options:options error:error];
}


- (void)overrideLibraryWithLibraryFromURL:(NSURL *)replacementURL {

    NSError *error;

    NSPersistentStoreCoordinator *psc = self.persistentStoreCoordinator;
    NSPersistentStore *store = [psc persistentStoreForURL:self.persistentStoreURL];
    if (store) {
        if(![psc removePersistentStore:store error:&error]) {
            APLog(@"%s failed to remove persistent store with error %@",__PRETTY_FUNCTION__,error);
            error = nil;
        }
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *finalTargetURL = self.persistentStoreURL;
    NSString *tmpName = [[NSUUID UUID] UUIDString];
    NSURL *tmpTargetURL = [[finalTargetURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:tmpName];

    BOOL success = [fileManager copyItemAtURL:replacementURL toURL:tmpTargetURL error:&error];
    if (!success) {
        APLog(@"%s failed to copy store to tmp url with with error %@",__PRETTY_FUNCTION__,error);
        error = nil;
    }

    success = [fileManager replaceItemAtURL:self.persistentStoreURL
                              withItemAtURL:tmpTargetURL
                             backupItemName:nil
                                    options:0
                           resultingItemURL:nil
                                      error:&error];
    if (!success) {
        APLog(@"%s failed to replace store with error %@",__PRETTY_FUNCTION__,error);
        error = nil;
    }

    if(![self addDefaultLibraryStoreToCoordinator:psc withError:&error]) {
        APLog(@"%s failed to add store with error %@",__PRETTY_FUNCTION__,error);
    }
}

#pragma mark -
#pragma mark No meta data fallbacks

- (void)computeThumbnailForFile:(MLFile *)file
{
    if (!file.computedThumbnail && ![file isKindOfType:kMLFileTypeAudio] && [file.hasFetchedInfo boolValue]) {
        APLog(@"Computing thumbnail for %@", file.title);
//        [[MLThumbnailerQueue sharedThumbnailerQueue] addFile:file];
    }
}

- (void)errorWhenFetchingMetaDataForFile:(MLFile *)file
{
    APLog(@"Error when fetching for '%@'", file.title);

    [self computeThumbnailForFile:file];
}

- (void)errorWhenFetchingMetaDataForShow:(MLShow *)show
{
    for (MLShowEpisode *episode in show.episodes) {
        for (MLFile *file in episode.files)
            [self errorWhenFetchingMetaDataForFile:file];
    }
}

- (void)noMetaDataInRemoteDBForFile:(MLFile *)file
{
    file.noOnlineMetaData = @YES;
    [self computeThumbnailForFile:file];
}

- (void)noMetaDataInRemoteDBForShow:(MLShow *)show
{
    for (MLShowEpisode *episode in show.episodes) {
        for (MLFile *file in episode.files)
            [self noMetaDataInRemoteDBForFile:file];
    }
}

#pragma mark -
#pragma mark Getter
//
//- (void)addNewLabelWithName:(NSString *)name
//{
//    MLLabel *label = [self createObjectForEntity:@"Label"];
//    label.name = name;
//}

/**
 * TV MLShow Episodes
 */

#pragma mark -
#pragma mark Online meta data grabbing

#if HAVE_BLOCK
- (void)tvShowEpisodesInfoGrabberDidFinishGrabbing:(MLTVShowEpisodesInfoGrabber *)grabber
{
    MLShow *show = grabber.userData;

    NSArray *results = grabber.episodesResults;
    [show setValue:(grabber.results)[@"serieArtworkURL"] forKey:@"artworkURL"];
    for (id result in results) {
        if ([result[@"serie"] boolValue]) {
            continue;
        }
        MLShowEpisode *showEpisode = [MLShowEpisode episodeWithShow:show episodeNumber:result[@"episodeNumber"] seasonNumber:result[@"seasonNumber"] createIfNeeded:YES];
        showEpisode.name = result[@"title"];
        showEpisode.theTVDBID = result[@"id"];
        showEpisode.shortSummary = result[@"shortSummary"];
        showEpisode.artworkURL = result[@"artworkURL"];
        if (!showEpisode.artworkURL) {
            for (MLFile *file in showEpisode.files)
                [self computeThumbnailForFile:file];
        }

        showEpisode.lastSyncDate = [MLTVShowInfoGrabber serverTime];
    }
    show.lastSyncDate = [MLTVShowInfoGrabber serverTime];
}

- (void)tvShowEpisodesInfoGrabber:(MLTVShowEpisodesInfoGrabber *)grabber didFailWithError:(NSError *)error
{
    MLShow *show = grabber.userData;
    [self errorWhenFetchingMetaDataForShow:show];
}

- (void)tvShowInfoGrabberDidFinishGrabbing:(MLTVShowInfoGrabber *)grabber
{
    MLShow *show = grabber.userData;
    NSArray *results = grabber.results;
    if ([results count] > 0) {
        NSDictionary *result = results[0];
        NSString *showId = result[@"id"];

        show.theTVDBID = showId;
        show.name = result[@"title"];
        show.shortSummary = result[@"shortSummary"];
        show.releaseYear = result[@"releaseYear"];

        // Fetch episodes info
        MLTVShowEpisodesInfoGrabber *grabber = [[MLTVShowEpisodesInfoGrabber alloc] init];
        grabber.delegate = self;
        grabber.userData = show;
        [grabber lookUpForShowID:showId];
    }
    else {
        // Not found.
        [self noMetaDataInRemoteDBForShow:show];
        show.lastSyncDate = [MLTVShowInfoGrabber serverTime];
    }
}

- (void)tvShowInfoGrabber:(MLTVShowInfoGrabber *)grabber didFailWithError:(NSError *)error
{
    MLShow *show = grabber.userData;
    [self errorWhenFetchingMetaDataForShow:show];
}

- (void)tvShowInfoGrabberDidFetchServerTime:(MLTVShowInfoGrabber *)grabber
{
    MLShow *show = grabber.userData;

    [[NSUserDefaults standardUserDefaults] setInteger:[[MLTVShowInfoGrabber serverTime] integerValue] forKey:kLastTVDBUpdateServerTime];

    // First fetch the MLShow ID
    MLTVShowInfoGrabber *showInfoGrabber = [[MLTVShowInfoGrabber alloc] init];
    showInfoGrabber.delegate = self;
    showInfoGrabber.userData = show;

    APLog(@"Fetching show information on %@", show.name);

    [showInfoGrabber lookUpForTitle:show.name];
}
#endif

- (void)fetchMetaDataForShow:(MLShow *)show
{
    if (!_allowNetworkAccess)
        return;
    APLog(@"Fetching show server time");

    // First fetch the serverTime, so that we can update each entry.
#if HAVE_BLOCK
    [MLTVShowInfoGrabber fetchServerTimeAndExecuteBlock:^(NSNumber *serverDate) {

        [[NSUserDefaults standardUserDefaults] setInteger:[serverDate integerValue] forKey:kLastTVDBUpdateServerTime];

        APLog(@"Fetching show information on %@", show.name);

        // First fetch the MLShow ID
        MLTVShowInfoGrabber *grabber = [[[MLTVShowInfoGrabber alloc] init] autorelease];
        [grabber lookUpForTitle:show.name andExecuteBlock:^{
            NSArray *results = grabber.results;
            if ([results count] > 0) {
                NSDictionary *result = [results objectAtIndex:0];
                NSString *showId = [result objectForKey:@"id"];

                show.theTVDBID = showId;
                show.name = [result objectForKey:@"title"];
                show.shortSummary = [result objectForKey:@"shortSummary"];
                show.releaseYear = [result objectForKey:@"releaseYear"];

                APLog(@"Fetching show episode information on %@", showId);

                // Fetch episode info
                MLTVShowEpisodesInfoGrabber *grabber = [[[MLTVShowEpisodesInfoGrabber alloc] init] autorelease];
                [grabber lookUpForShowID:showId andExecuteBlock:^{
                    NSArray *results = grabber.episodesResults;
                    [show setValue:[grabber.results objectForKey:@"serieArtworkURL"] forKey:@"artworkURL"];
                    for (id result in results) {
                        if ([[result objectForKey:@"serie"] boolValue]) {
                            continue;
                        }
                        MLShowEpisode *showEpisode = [MLShowEpisode episodeWithShow:show episodeNumber:[result objectForKey:@"episodeNumber"] seasonNumber:[result objectForKey:@"seasonNumber"] createIfNeeded:YES];
                        showEpisode.name = [result objectForKey:@"title"];
                        showEpisode.theTVDBID = [result objectForKey:@"id"];
                        showEpisode.shortSummary = [result objectForKey:@"shortSummary"];
                        showEpisode.artworkURL = [result objectForKey:@"artworkURL"];
                        showEpisode.lastSyncDate = serverDate;
                    }
                    show.lastSyncDate = serverDate;
                }];
            }
            else {
                // Not found.
                show.lastSyncDate = serverDate;
            }

        }];
    }];
#endif
}

/**
 * MLFile auto detection
 */

#if HAVE_BLOCK
- (void)movieInfoGrabber:(MLMovieInfoGrabber *)grabber didFailWithError:(NSError *)error
{
    MLFile *file = grabber.userData;
    [self errorWhenFetchingMetaDataForFile:file];
}

- (void)movieInfoGrabberDidFinishGrabbing:(MLMovieInfoGrabber *)grabber
{
    NSNumber *yes = @YES;

    NSArray *results = grabber.results;
    MLFile *file = grabber.userData;
    if ([results count] > 0) {
        NSDictionary *result = results[0];
        file.artworkURL = result[@"artworkURL"];
        file.title = result[@"title"];
        file.shortSummary = result[@"shortSummary"];
        file.releaseYear = result[@"releaseYear"];
    }
    else {
        [self noMetaDataInRemoteDBForFile:file];
    }

    file.hasFetchedInfo = yes;
}
#endif

- (void)applicationWillExit
{
    [[MLFileParserQueue sharedFileParserQueue] stop];
    [[MLCrashPreventer sharedPreventer] cancelAllFileParse];
}

- (void)applicationWillStart
{
//    [[MLCrashPreventer sharedPreventer] markCrasherFiles];
    [[MLFileParserQueue sharedFileParserQueue] resume];
}

- (void)libraryDidDisappear
{
    // Stop expansive work
//    [[MLThumbnailerQueue sharedThumbnailerQueue] stop];
    [[MLFileParserQueue sharedFileParserQueue] stop];
}

- (void)libraryDidAppear
{
    // Resume our work
//    [[MLThumbnailerQueue sharedThumbnailerQueue] resume];
    [[MLFileParserQueue sharedFileParserQueue] resume];
}

#pragma mark - migrations

- (BOOL)libraryMigrationNeeded
{
    return [self _libraryMigrationNeeded];
}
- (void)migrateLibrary
{
    [self _migrateLibrary];
}

@end
