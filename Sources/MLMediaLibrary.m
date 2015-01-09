/*****************************************************************************
 * MLMediaLibrary.m
 * MobileMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2014 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
 *          Felix Paul Kühne <fkuehne # videolan.org>
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
#import "MLMovieInfoGrabber.h"
#import "MLTVShowInfoGrabber.h"
#import "MLTVShowEpisodesInfoGrabber.h"
#import "MLFile.h"
#import "MLLabel.h"
#import "MLShowEpisode.h"
#import "MLShow.h"
#import "MLThumbnailerQueue.h"
#import "MLAlbumTrack.h"
#import "MLAlbum.h"
#import "MLFileParserQueue.h"
#import "MLCrashPreventer.h"

@interface MLMediaLibrary ()
{
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel   *_managedObjectModel;

    BOOL _allowNetworkAccess;

    NSString *_thumbnailFolderPath;
    NSString *_databaseFolderPath;
    NSString *_documentFolderPath;
}
@end

#define DEBUG 1
// To debug
#define DELETE_LIBRARY_ON_EACH_LAUNCH 0

// Pref key
static NSString *kLastTVDBUpdateServerTime = @"MLLastTVDBUpdateServerTime";
static NSString *kUpdatedToTheGreatSharkHuntDatabaseFormat = @"upgradedToDatabaseFormat 2.3";
static NSString *kDecrapifyTitles = @"MLDecrapifyTitles";

#if HAVE_BLOCK
@interface MLMediaLibrary ()
#else
@interface MLMediaLibrary () <MLMovieInfoGrabberDelegate, MLTVShowEpisodesInfoGrabberDelegate, MLTVShowInfoGrabberDelegate>
#endif
- (NSManagedObjectContext *)managedObjectContext;
- (NSString *)databaseFolderPath;
@end

@implementation MLMediaLibrary
+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{kUpdatedToTheGreatSharkHuntDatabaseFormat : @NO, kDecrapifyTitles : @YES}];
}

+ (id)sharedMediaLibrary
{
    static id sharedMediaLibrary = nil;
    if (!sharedMediaLibrary) {
        sharedMediaLibrary = [[[self class] alloc] init];
        APLog(@"Initializing db in %@", [sharedMediaLibrary databaseFolderPath]);

        // Also force to init the crash preventer
        // Because it will correctly set up the parser and thumbnail queue
        [MLCrashPreventer sharedPreventer];
    }
    return sharedMediaLibrary;
}

- (void)dealloc
{
    if (_managedObjectContext)
        [_managedObjectContext removeObserver:self forKeyPath:@"hasChanges"];
}

- (NSFetchRequest *)fetchRequestForEntity:(NSString *)entity
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:moc];
    NSAssert(entityDescription, @"No entity");
    [request setEntity:entityDescription];
    return request;
}

- (id)createObjectForEntity:(NSString *)entity
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:moc];
}

- (void)removeObject:(NSManagedObject *)object
{
    [[self managedObjectContext] deleteObject:object];
}

#pragma mark -
#pragma mark Media Library
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
        return _managedObjectModel;
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (NSString *)databaseFolderPath
{
    if (_databaseFolderPath) {
        if (_databaseFolderPath.length > 0)
            return _databaseFolderPath;
    }
    int directory = NSLibraryDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSString *directoryPath = paths[0];
#if DELETE_LIBRARY_ON_EACH_LAUNCH
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
#endif
    _databaseFolderPath = directoryPath;
    return _databaseFolderPath;
}

- (NSString *)thumbnailFolderPath
{
    if (_thumbnailFolderPath) {
        if (_thumbnailFolderPath.length > 0)
            return _thumbnailFolderPath;
    }
    int directory = NSLibraryDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSString *directoryPath = paths[0];
#if DELETE_LIBRARY_ON_EACH_LAUNCH
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
#endif
    _thumbnailFolderPath = [directoryPath stringByAppendingPathComponent:@"Thumbnails"];
    return _thumbnailFolderPath;
}

- (NSString *)documentFolderPath
{
    if (_documentFolderPath) {
        if (_documentFolderPath.length > 0)
            return _documentFolderPath;
    }
    int directory = NSDocumentDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);

    _documentFolderPath = [NSString stringWithFormat:@"file://%@", paths[0]];
    return _documentFolderPath;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext)
        return _managedObjectContext;

    NSString *databaseFolderPath = [self databaseFolderPath];

    NSString *path = [databaseFolderPath stringByAppendingPathComponent: @"MediaLibrary.sqlite"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSNumber *yes = @YES;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : yes,
                             NSInferMappingModelAutomaticallyOption : yes};

    NSError *error;
    NSPersistentStore *persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];

    if (!persistentStore) {
#if! TARGET_OS_IPHONE
        // FIXME: Deal with versioning
        NSInteger ret = NSRunAlertPanel(@"Error", @"The Media Library you have on your disk is not compatible with the one Lunettes can read. Do you want to create a new one?", @"No", @"Yes", nil);
        if (ret == NSOKButton)
            [NSApp terminate:nil];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
#else
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
#endif
        persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
        if (!persistentStore) {
#if! TARGET_OS_IPHONE
            NSRunInformationalAlertPanel(@"Corrupted Media Library", @"There is nothing we can apparently do about it...", @"OK", nil, nil);
#else
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Corrupted Media Library" message:@"There is nothing we can apparently do about it..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
#endif
            // Probably assert instead.
            return nil;
        }
    }

    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    [_managedObjectContext setUndoManager:nil];
    [_managedObjectContext addObserver:self forKeyPath:@"hasChanges" options:NSKeyValueObservingOptionInitial context:nil];
    return _managedObjectContext;
}

- (void)savePendingChanges
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(savePendingChanges) object:nil];
    NSError *error = nil;
    BOOL success = [[self managedObjectContext] save:&error];
    NSAssert1(success, @"Can't save: %@", error);
#if !TARGET_OS_IPHONE && MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
    NSProcessInfo *process = [NSProcessInfo processInfo];
    if ([process respondsToSelector:@selector(enableSuddenTermination)])
        [process enableSuddenTermination];
#endif
}

- (void)save
{
    NSError *error = nil;
    BOOL success = [[self managedObjectContext] save:&error];
    NSAssert1(success, @"Can't save: %@", error);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hasChanges"] && object == _managedObjectContext) {
#if !TARGET_OS_IPHONE && MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
        NSProcessInfo *process = [NSProcessInfo processInfo];
        if ([process respondsToSelector:@selector(disableSuddenTermination)])
            [process disableSuddenTermination];
#endif

        if ([[self managedObjectContext] hasChanges]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(savePendingChanges) object:nil];
            [self performSelector:@selector(savePendingChanges) withObject:nil afterDelay:1.];
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark -
#pragma mark No meta data fallbacks

- (void)computeThumbnailForFile:(MLFile *)file
{
    if (!file.computedThumbnail) {
        APLog(@"Computing thumbnail for %@", file.title);
        [[MLThumbnailerQueue sharedThumbnailerQueue] addFile:file];
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

- (void)addNewLabelWithName:(NSString *)name
{
    MLLabel *label = [self createObjectForEntity:@"Label"];
    label.name = name;
}

/**
 * TV MLShow Episodes
 */

#pragma mark -
#pragma mark Online meta data grabbing

#if !HAVE_BLOCK
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
#else
    MLTVShowInfoGrabber *grabber = [[MLTVShowInfoGrabber alloc] init];
    grabber.delegate = self;
    grabber.userData = show;
    [grabber fetchServerTime];
#endif
}

- (void)addTVShowEpisodeWithInfo:(NSDictionary *)tvShowEpisodeInfo andFile:(MLFile *)file
{
    file.type = kMLFileTypeTVShowEpisode;

    NSNumber *seasonNumber = tvShowEpisodeInfo[@"season"];
    NSNumber *episodeNumber = tvShowEpisodeInfo[@"episode"];
    NSString *tvShowName = tvShowEpisodeInfo[@"tvShowName"];
    NSString *tvEpisodeName = tvShowEpisodeInfo[@"tvEpisodeName"];
    BOOL hasNoTvShow = NO;
    if (!tvShowName) {
        tvShowName = @"";
        hasNoTvShow = YES;
    }
    BOOL wasInserted = NO;
    MLShow *show = nil;
    MLShowEpisode *episode = [MLShowEpisode episodeWithShowName:tvShowName episodeNumber:episodeNumber seasonNumber:seasonNumber createIfNeeded:YES wasCreated:&wasInserted];

    if (episode) {
        show = episode.show;
        [show addEpisode:episode];
    }
    if (wasInserted && !hasNoTvShow) {
        show.name = tvShowName;
        [self fetchMetaDataForShow:show];
    }
    episode.name = tvEpisodeName;

    if (episode.name.length < 1)
        episode.name = file.title;
    file.seasonNumber = seasonNumber;
    file.episodeNumber = episodeNumber;
    episode.shouldBeDisplayed = @YES;

    [episode addFilesObject:file];
    file.showEpisode = episode;

    // The rest of the meta data will be fetched using the MLShow
    file.hasFetchedInfo = @YES;
}

- (void)addAudioContentWithInfo:(NSDictionary *)audioContentInfo andFile:(MLFile *)file
{
    file.type = kMLFileTypeAudio;

    file.title = audioContentInfo[VLCMetaInformationTitle];

    /* all further meta data is set by the FileParserQueue */

    file.hasFetchedInfo = @YES;
}

/**
 * MLFile auto detection
 */

#if !HAVE_BLOCK
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

- (void)fetchMetaDataForFile:(MLFile *)file
{
    APLog(@"Fetching meta data for %@", file.title);

    [[MLFileParserQueue sharedFileParserQueue] addFile:file];

    if (!_allowNetworkAccess) {
        // Automatically compute the thumbnail
        [self computeThumbnailForFile:file];
    }

    NSDictionary *tvShowEpisodeInfo = [MLTitleDecrapifier tvShowEpisodeInfoFromString:file.title];
    if (tvShowEpisodeInfo) {
        [self addTVShowEpisodeWithInfo:tvShowEpisodeInfo andFile:file];
        return;
    }

    if ([file isSupportedAudioFile]) {
        NSDictionary *audioContentInfo = [MLTitleDecrapifier audioContentInfoFromFile:file];
        if (audioContentInfo && ![file videoTrack]) {
            [self addAudioContentWithInfo:audioContentInfo andFile:file];
            return;
        }
    }

    if (!_allowNetworkAccess)
        return;

    // Go online and fetch info.

    // We don't care about keeping a reference to track the item during its life span
    // because we are a singleton
    MLMovieInfoGrabber *grabber = [[MLMovieInfoGrabber alloc] init];

    APLog(@"Looking up for Movie '%@'", file.title);

#if HAVE_BLOCK
    [grabber lookUpForTitle:file.title andExecuteBlock:^(NSError *err){
        if (err) {
            [self errorWhenFetchingMetaDataForFile:file];
            return;
        }

        NSArray *results = grabber.results;
        if ([results count] > 0) {
            NSDictionary *result = [results objectAtIndex:0];
            file.artworkURL = [result objectForKey:@"artworkURL"];
            if (!file.artworkURL)
                [self computeThumbnailForFile:file];
            file.title = [result objectForKey:@"title"];
            file.shortSummary = [result objectForKey:@"shortSummary"];
            file.releaseYear = [result objectForKey:@"releaseYear"];
        } else
            [self noMetaDataInRemoteDBForFile:file];
        file.hasFetchedInfo = [NSNumber numberWithBool:YES];
    }];
#else
    grabber.userData = file;
    grabber.delegate = self;
    [grabber lookUpForTitle:file.title];
#endif
}

#pragma mark -
#pragma mark Adding file to the DB

- (void)addFilePath:(NSString *)filePath
{
    APLog(@"Adding Path %@", filePath);

    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSString *title = [filePath lastPathComponent];
#if !TARGET_OS_IPHONE
    NSDate *openedDate = nil; // FIXME kMDItemLastUsedDate
    NSDate *modifiedDate = nil; // FIXME [result valueForAttribute:@"kMDItemFSContentChangeDate"];
#endif
    NSNumber *size = attributes[NSFileSize]; // FIXME [result valueForAttribute:@"kMDItemFSSize"];

    MLFile *file = [self createObjectForEntity:@"File"];
    file.url = [url absoluteString];

    // Yes, this is a negative number. VLCTime nicely display negative time
    // with "XX minutes remaining". And we are using this facility.

    NSNumber *no = @NO;
    NSNumber *yes = @YES;

    file.currentlyWatching = no;
    file.lastPosition = @0.0;
    file.remainingTime = @0.0;
    file.unread = yes;

#if !TARGET_OS_IPHONE
    if ([openedDate isGreaterThan:modifiedDate]) {
        file.playCount = [NSNumber numberWithDouble:1];
        file.unread = no;
    }
#endif

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kDecrapifyTitles] boolValue] == YES)
        file.title = [MLTitleDecrapifier decrapify:[title stringByDeletingPathExtension]];
    else
        file.title = [title stringByDeletingPathExtension];

    if ([size longLongValue] < 150000000) /* 150 MB */
        file.type = kMLFileTypeClip;
    else
        file.type = kMLFileTypeMovie;

    [self fetchMetaDataForFile:file];
}

- (void)addFilePaths:(NSArray *)filepaths
{
    NSUInteger count = [filepaths count];
    NSMutableArray *fetchPredicates = [NSMutableArray arrayWithCapacity:count];
    NSMutableDictionary *urlToObject = [NSMutableDictionary dictionaryWithCapacity:count];
    NSString *documentFolderPath = [[MLMediaLibrary sharedMediaLibrary] documentFolderPath];

    // Prepare a fetch request for all items
    NSArray *pathComponents;
    NSUInteger componentCount;

    for (NSString *path in filepaths) {
#if TARGET_OS_IPHONE
        NSString *urlString;
        NSString *componentString = @"";

        pathComponents = [path componentsSeparatedByString:@"/"];
        componentCount = pathComponents.count;
        if ([pathComponents[componentCount - 2] isEqualToString:@"Documents"])
            componentString = [path lastPathComponent];
        else {
            NSUInteger firstElement = [pathComponents indexOfObject:@"Documents"] + 1;
            for (NSUInteger x = 0; x < componentCount - firstElement; x++) {
                if (x == 0)
                    componentString = [componentString stringByAppendingFormat:@"%@", pathComponents[firstElement + x]];
                else
                    componentString = [componentString stringByAppendingFormat:@"/%@", pathComponents[firstElement + x]];
            }
        }

        /* compose and escape string */
        urlString = [[NSString stringWithFormat:@"%@/%@", documentFolderPath, componentString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        /* check for the end of the paths */
        [fetchPredicates addObject:[NSPredicate predicateWithFormat:@"url CONTAINS %@", [urlString lastPathComponent]]];
        [urlToObject setObject:path forKey:urlString];
#else
        [fetchPredicates addObject:[NSPredicate predicateWithFormat:@"url == %@", path]];
#endif
    }
    NSFetchRequest *request = [self fetchRequestForEntity:@"File"];

    [request setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:fetchPredicates]];

    APLog(@"Fetching");
    NSArray *dbResults = [[self managedObjectContext] executeFetchRequest:request error:nil];
    APLog(@"Done");

    NSMutableArray *filePathsToAdd = [NSMutableArray arrayWithArray:filepaths];

    // Remove objects that are already in db.
    for (MLFile *dbResult in dbResults) {
        NSString *urlString = dbResult.url;
        [filePathsToAdd removeObject:[urlToObject objectForKey:urlString]];
    }

    // Add only the newly added items
    for (NSString* path in filePathsToAdd)
        [self addFilePath:path];
}


#pragma mark -
#pragma mark DB Updates

#if !HAVE_BLOCK
- (void)tvShowInfoGrabber:(MLTVShowInfoGrabber *)grabber didFetchUpdates:(NSArray *)updates
{
    NSFetchRequest *request = [self fetchRequestForEntity:@"Show"];
    [request setPredicate:[NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"theTVDBID"] rightExpression:[NSExpression expressionForConstantValue:updates] modifier:NSDirectPredicateModifier type:NSInPredicateOperatorType options:0]];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    for (MLShow *show in results)
        [self fetchMetaDataForShow:show];
}
#endif

- (BOOL)libraryNeedsUpgrade
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kUpdatedToTheGreatSharkHuntDatabaseFormat] boolValue])
        return YES;
    return NO;
}

- (void)upgradeLibrary
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kUpdatedToTheGreatSharkHuntDatabaseFormat] boolValue])
        [self _upgradeLibraryToGreatSharkHuntDatabaseFormat];
}

- (void)_upgradeLibraryToGreatSharkHuntDatabaseFormat
{
    [self libraryDidDisappear];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    /* remove potential empty albums left over by previous releases */
    NSArray *collection = [MLAlbum allAlbums];
    NSUInteger count = collection.count;
    MLAlbum *album;
    MLAlbumTrack *track;
    NSArray *secondaryCollection;
    NSURL *fileURL;
    NSUInteger secondaryCount = 0;
    NSArray *tertiaryCollection;
    NSUInteger tertiaryCount = 0;
    NSUInteger emptyAlbumCounter = 0;
    for (NSUInteger x = 0; x < count; x++) {
        album = collection[x];
        if (album.tracks.count < 1)
            [[self managedObjectContext] deleteObject:album];
        else {
            secondaryCollection = album.tracks.allObjects;
            secondaryCount = secondaryCollection.count;
            emptyAlbumCounter = 0;
            for (NSUInteger y = 0; y < secondaryCount; y++) {
                track = secondaryCollection[y];
                tertiaryCollection = track.files.allObjects;
                tertiaryCount = tertiaryCollection.count;
                for (NSUInteger z = 0; z < tertiaryCount; z++) {
                    fileURL = [NSURL URLWithString:[(MLFile *)tertiaryCollection[z] url]];
                    BOOL exists = [fileManager fileExistsAtPath:[fileURL path]];
                    if (exists)
                        emptyAlbumCounter++;
                    else
                        [album removeTrack:track];
                }
            }
            if (emptyAlbumCounter == 0)
                [[self managedObjectContext] deleteObject:album];
        }
    }
    album = nil;

    /* remove potential empty shows left over by previous releases */
    collection = [MLShow allShows];
    MLShow *show;
    MLShowEpisode *showEpisode;
    count = collection.count;
    for (NSUInteger x = 0; x < count; x++) {
        show = collection[x];
        if (show.episodes.count < 1)
            [[self managedObjectContext] deleteObject:show];
        else {
            secondaryCollection = show.episodes.allObjects;
            secondaryCount = secondaryCollection.count;
            emptyAlbumCounter = 0;
            for (NSUInteger y = 0; y < secondaryCount; y++) {
                showEpisode = secondaryCollection[y];
                tertiaryCollection = showEpisode.files.allObjects;
                tertiaryCount = tertiaryCollection.count;
                for (NSUInteger z = 0; z < tertiaryCount; z++) {
                    fileURL = [NSURL URLWithString:[(MLFile *)tertiaryCollection[z] url]];
                    BOOL exists = [fileManager fileExistsAtPath:[fileURL path]];
                    if (exists)
                        emptyAlbumCounter++;
                    else
                        [show removeEpisode:showEpisode];
                }
            }
            if (emptyAlbumCounter == 0)
                [[self managedObjectContext] deleteObject:show];
        }
    }

    /* remove duplicates */
    NSArray *allFiles = [MLFile allFiles];
    NSUInteger allFilesCount = allFiles.count;
    NSMutableArray *seenFiles = [[NSMutableArray alloc] initWithCapacity:allFilesCount];
    MLFile *currentFile;
    NSString *currentFilePath;
    for (NSUInteger x = 0; x < allFilesCount; x++) {
        currentFile = allFiles[x];
        currentFilePath = [currentFile.url stringByReplacingOccurrencesOfString:@"/localhost/" withString:@"//"];
        if ([seenFiles containsObject:currentFilePath])
            [[self managedObjectContext] deleteObject:currentFile];
        else
            [seenFiles addObject:currentFilePath];
    }

    [defaults setBool:YES forKey:kUpdatedToTheGreatSharkHuntDatabaseFormat];
    [defaults synchronize];

    [self libraryDidAppear];
    if ([self.delegate respondsToSelector:@selector(libraryUpgradeComplete)])
        [self.delegate libraryUpgradeComplete];
}

- (void)updateMediaDatabase
{
    [self libraryDidDisappear];
    // Remove no more present files
    NSFetchRequest *request = [self fetchRequestForEntity:@"File"];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    unsigned int count = (unsigned int)results.count;
    for (unsigned int x = 0; x < count; x++) {
        MLFile *file = results[x];
        NSString *urlString = [file url];
        NSURL *fileURL = [NSURL URLWithString:urlString];
        BOOL exists = [fileManager fileExistsAtPath:[fileURL path]];
        if (!exists) {
            APLog(@"Marking - %@", [fileURL absoluteString]);
            file.isSafe = YES; // It doesn't exist, it's safe.
            if (file.isAlbumTrack) {
                MLAlbum *album = file.albumTrack.album;
                if (album.tracks.count <= 1) {
                    @try {
                        [[self managedObjectContext] deleteObject:album];
                    }
                    @catch (NSException *exception) {
                        APLog(@"failed to nuke object because it disappeared in front of us");
                    }
                } else
                    [album removeTrack:file.albumTrack];
            }
            if (file.isShowEpisode) {
                MLShow *show = file.showEpisode.show;
                if (show.episodes.count <= 1) {
                    @try {
                        [[self managedObjectContext] deleteObject:show];
                    }
                    @catch (NSException *exception) {
                        APLog(@"failed to nuke object because it disappeared in front of us");
                    }
                } else
                    [show removeEpisode:file.showEpisode];
            }
#if TARGET_OS_IPHONE
            NSString *thumbPath = [file thumbnailPath];
            bool thumbExists = [fileManager fileExistsAtPath:thumbPath];
            if (thumbExists)
                [fileManager removeItemAtPath:thumbPath error:nil];
            [[self managedObjectContext] deleteObject:file];
#endif
        }
#if !TARGET_OS_IPHONE
    file.isOnDisk = @(exists);
#endif
    }
    [self libraryDidAppear];

    // Get the file to parse
    request = [self fetchRequestForEntity:@"File"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isOnDisk == YES && tracks.@count == 0"]];
    results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    for (MLFile *file in results)
        [[MLFileParserQueue sharedFileParserQueue] addFile:file];

    if (!_allowNetworkAccess) {
        // Always attempt to fetch
        request = [self fetchRequestForEntity:@"File"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"isOnDisk == YES"]];
        results = [[self managedObjectContext] executeFetchRequest:request error:nil];
        for (MLFile *file in results) {
            if (!file.computedThumbnail)
                [self computeThumbnailForFile:file];
        }
        return;
    }

    // Get the thumbnails to compute
    request = [self fetchRequestForEntity:@"File"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isOnDisk == YES && hasFetchedInfo == 1 && artworkURL == nil"]];
    results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    for (MLFile *file in results)
        if (!file.computedThumbnail && ![file isAlbumTrack])
            [self computeThumbnailForFile:file];

    // Get to fetch meta data
    request = [self fetchRequestForEntity:@"File"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isOnDisk == YES && hasFetchedInfo == 0"]];
    results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    for (MLFile *file in results)
        [self fetchMetaDataForFile:file];

    // Get to fetch show info
    request = [self fetchRequestForEntity:@"Show"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"lastSyncDate == 0"]];
    results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    for (MLShow *show in results)
        [self fetchMetaDataForShow:show];

    // Get updated TV Shows
    NSNumber *lastServerTime = @([[NSUserDefaults standardUserDefaults] integerForKey:kLastTVDBUpdateServerTime]);
#if HAVE_BLOCK
    [MLTVShowInfoGrabber fetchUpdatesSinceServerTime:lastServerTime andExecuteBlock:^(NSArray *updates){
        NSFetchRequest *request = [self fetchRequestForEntity:@"Show"];
        [request setPredicate:[NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"theTVDBID"] rightExpression:[NSExpression expressionForConstantValue:updates] modifier:NSDirectPredicateModifier type:NSInPredicateOperatorType options:0]];
        NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
        for (MLShow *show in results)
            [self fetchMetaDataForShow:show];
    }];
#else
    MLTVShowInfoGrabber *grabber = [[MLTVShowInfoGrabber alloc] init];
    grabber.delegate = self;
    [grabber fetchUpdatesSinceServerTime:lastServerTime];
#endif
    /* Update every hour - FIXME: Preferences key */
    [self performSelector:@selector(updateMediaDatabase) withObject:nil afterDelay:60 * 60];
}

- (void)applicationWillExit
{
    [[MLCrashPreventer sharedPreventer] cancelAllFileParse];
}

- (void)applicationWillStart
{
    [[MLCrashPreventer sharedPreventer] markCrasherFiles];
}

- (void)libraryDidDisappear
{
    // Stop expansive work
    [[MLThumbnailerQueue sharedThumbnailerQueue] stop];
}

- (void)libraryDidAppear
{
    // Resume our work
    [[MLThumbnailerQueue sharedThumbnailerQueue] resume];
}
@end
