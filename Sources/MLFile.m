/*****************************************************************************
 * MLFile.m
 * Lunettes
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2013 VLC authors and VideoLAN
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

#import "MLFile.h"
#import "MLShow.h"
#import "MLShowEpisode.h"
#import "MLAlbum.h"
#import "MLAlbumTrack.h"
#import "MLMediaLibrary.h"
#import "MLThumbnailerQueue.h"

NSString *kMLFileTypeMovie = @"movie";
NSString *kMLFileTypeClip = @"clip";
NSString *kMLFileTypeTVShowEpisode = @"tvShowEpisode";
NSString *kMLFileTypeAudio = @"audio";

@implementation MLFile

- (NSString *)description
{
    return [NSString stringWithFormat:@"<MLFile title='%@'>", [self title]];
}

+ (NSArray *)allFiles
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [[MLMediaLibrary sharedMediaLibrary] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:moc];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isOnDisk == YES"]];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:@[descriptor]];

    NSError *error;
    NSArray *movies = [moc executeFetchRequest:request error:&error];
    if (!movies) {
        APLog(@"WARNING: %@", error);
    }

    return movies;
}

+ (NSArray *)fileForURL:(NSString *)url;
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [[MLMediaLibrary sharedMediaLibrary] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:moc];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"url == %@", url]];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:@[descriptor]];

    NSError *error;
    NSArray *files = [moc executeFetchRequest:request error:&error];
    if (!files)
        APLog(@"WARNING: %@", error);

    return files;
}

- (BOOL)isKindOfType:(NSString *)type
{
    return [self.type isEqualToString:type];
}
- (BOOL)isMovie
{
    return [self isKindOfType:kMLFileTypeTVShowEpisode];
}
- (BOOL)isClip
{
    return [self isKindOfType:kMLFileTypeTVShowEpisode];
}
- (BOOL)isShowEpisode
{
    return [self isKindOfType:kMLFileTypeTVShowEpisode];
}
- (BOOL)isAlbumTrack
{
    return [self isKindOfType:kMLFileTypeAudio];
}

- (BOOL)isSupportedAudioFile
{
    NSUInteger options = NSRegularExpressionSearch | NSCaseInsensitiveSearch;
    return ([[self.url lastPathComponent] rangeOfString:@"\\.(aac|aiff|aif|amr|aob|ape|axa|caf|flac|it|m2a|m4a|m4b|mka|mlp|mod|mp1|mp2|mp3|mpa|mpc|oga|oma|opus|rmi|s3m|spx|tta|voc|vqf|w64|wav|wma|wv|xa|xm)$" options:options].location != NSNotFound);
}

- (NSString *)artworkURL
{
    if ([self isShowEpisode]) {
        return self.showEpisode.artworkURL;
    }
    return [self primitiveValueForKey:@"artworkURL"];
}

- (NSString *)title
{
    if ([self isShowEpisode]) {
        MLShowEpisode *episode = self.showEpisode;
        NSMutableString *name = [[NSMutableString alloc] init];
        if (episode.show.name.length > 0)
            [name appendString:episode.show.name];

        if ([episode.seasonNumber intValue] > 0) {
            if (![name isEqualToString:@""])
                [name appendString:@" - "];
            [name appendFormat:@"S%02dE%02d", [episode.seasonNumber intValue], [episode.episodeNumber intValue]];
        }

        if (episode.name.length > 0) {
            if ([name length] > 0)
                [name appendString:@" - "];
            [name appendString:episode.name];
        }

        NSString *returnValue = [NSString stringWithString:name];
        return returnValue;
    } else if ([self isAlbumTrack]) {
        MLAlbumTrack *track = self.albumTrack;
        if (track && track.title.length > 0) {
            NSMutableString *name = [[NSMutableString alloc] initWithString:track.title];

            if (track.album.name.length > 0)
                [name appendFormat:@" - %@", track.album.name];

            if (track.artist.length > 0)
                [name appendFormat:@" - %@", track.artist];

            NSString *returnValue = [NSString stringWithString:name];
            return returnValue;
        }
    }

    [self willAccessValueForKey:@"title"];
    NSString *ret = [self primitiveValueForKey:@"title"];
    [self didAccessValueForKey:@"title"];

    return ret;
}

@dynamic seasonNumber;
@dynamic remainingTime;
@dynamic releaseYear;
@dynamic lastSubtitleTrack;
@dynamic lastAudioTrack;
@dynamic playCount;
@dynamic artworkURL;
@dynamic type;
@dynamic title;
@dynamic shortSummary;
@dynamic currentlyWatching;
@dynamic episodeNumber;
@dynamic hasFetchedInfo;
@dynamic noOnlineMetaData;
@dynamic showEpisode;
@dynamic labels;
@dynamic tracks;
@dynamic isOnDisk;
@dynamic duration;
@dynamic artist;
@dynamic album;
@dynamic albumTrackNumber;
@dynamic folderTrackNumber;
@dynamic genre;
@dynamic albumTrack;
@dynamic unread;

- (NSNumber *)lastPosition
{
    [self willAccessValueForKey:@"lastPosition"];
    NSNumber *ret = [self primitiveValueForKey:@"lastPosition"];
    [self didAccessValueForKey:@"lastPosition"];
    return ret;
}

- (void)setLastPosition:(NSNumber *)lastPosition
{
    @try {
        [self willChangeValueForKey:@"lastPosition"];
        [self setPrimitiveValue:lastPosition forKey:@"lastPosition"];
        [self didChangeValueForKey:@"lastPosition"];
    }
    @catch (NSException *exception) {
        APLog(@"setLastPosition raised exception");
    }
}

- (NSString *)url
{
    [self willAccessValueForKey:@"url"];
    NSString *ret = [self primitiveValueForKey:@"url"];
    [self didAccessValueForKey:@"url"];

    /* we need to make sure that current app path is still part of the file
     * URL since app upgrades via iTunes or the App Store will change the
     * absolute URL of our files (trac #11330) */
    NSString *documentFolderPath = [[MLMediaLibrary sharedMediaLibrary] documentFolderPath];
    if ([ret rangeOfString:documentFolderPath].location != NSNotFound)
        return ret;

    NSArray *pathComponents = [ret componentsSeparatedByString:@"/"];
    NSUInteger componentCount = pathComponents.count;
    if ([pathComponents[componentCount - 2] isEqualToString:@"Documents"])
        ret = [NSString stringWithFormat:@"%@/%@", documentFolderPath, [ret lastPathComponent]];
    else {
        NSUInteger firstElement = [pathComponents indexOfObject:@"Documents"] + 1;
        ret = documentFolderPath;
        for (NSUInteger x = 0; x < componentCount - firstElement; x++)
            ret = [ret stringByAppendingFormat:@"/%@", pathComponents[firstElement + x]];
    }

    APLog(@"returning modified URL! will return %@", ret);
    return ret;
}

- (void)setUrl:(NSString *)url
{
    @try {
        [self willChangeValueForKey:@"url"];
        [self setPrimitiveValue:url forKey:@"url"];
        [self didChangeValueForKey:@"url"];
    }
    @catch (NSException *exception) {
        APLog(@"setUrl raised exception");
    }
}

- (NSString *)thumbnailPath
{
    NSString *folder = [[MLMediaLibrary sharedMediaLibrary] thumbnailFolderPath];
    NSURL *url = [[self objectID] URIRepresentation];
    return [[folder stringByAppendingPathComponent:[url path]] stringByAppendingString:@".png"];
}

- (UIImage *)computedThumbnail
{
    return [UIImage imageWithContentsOfFile:[self thumbnailPath]];
}

- (void)setComputedThumbnail:(UIImage *)image
{
    NSURL *url = [NSURL fileURLWithPath:[self thumbnailPath]];

    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:[[self thumbnailPath] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    if (!image) {
        [manager removeItemAtURL:url error:nil];
        return;
    }
    [UIImagePNGRepresentation(image) writeToURL:url atomically:YES];
}

- (BOOL)isSafe
{
    [self willAccessValueForKey:@"isSafe"];
    NSNumber *ret = [self primitiveValueForKey:@"isSafe"];
    [self didAccessValueForKey:@"isSafe"];
    return [ret boolValue];
}

- (void)setIsSafe:(BOOL)isSafe
{
    @try {
        [self willChangeValueForKey:@"isSafe"];
        [self setPrimitiveValue:@(isSafe) forKey:@"isSafe"];
        [self didChangeValueForKey:@"isSafe"];
    }
    @catch (NSException *exception) {
        APLog(@"setIsSafe raised exception");
    }
}

- (BOOL)isBeingParsed
{
    [self willAccessValueForKey:@"isBeingParsed"];
    NSNumber *ret = [self primitiveValueForKey:@"isBeingParsed"];
    [self didAccessValueForKey:@"isBeingParsed"];
    return [ret boolValue];
}

- (void)setIsBeingParsed:(BOOL)isBeingParsed
{
    @try {
        [self willChangeValueForKey:@"isBeingParsed"];
        [self setPrimitiveValue:@(isBeingParsed) forKey:@"isBeingParsed"];
        [self didChangeValueForKey:@"isBeingParsed"];
    }
    @catch (NSException *exception) {
        APLog(@"setIsBeingParsed raised exception");
    }
}

- (BOOL)thumbnailTimeouted
{
    [self willAccessValueForKey:@"thumbnailTimeouted"];
    NSNumber *ret = [self primitiveValueForKey:@"thumbnailTimeouted"];
    [self didAccessValueForKey:@"thumbnailTimeouted"];
    return [ret boolValue];
}

- (void)setThumbnailTimeouted:(BOOL)thumbnailTimeouted
{
    @try {
        [self willChangeValueForKey:@"thumbnailTimeouted"];
        [self setPrimitiveValue:@(thumbnailTimeouted) forKey:@"thumbnailTimeouted"];
        [self didChangeValueForKey:@"thumbnailTimeouted"];
    }
    @catch (NSException *exception) {
        APLog(@"setThumbnailTimeouted raised exception");
    }
}

- (void)willDisplay
{
    [[MLThumbnailerQueue sharedThumbnailerQueue] setHighPriorityForFile:self];
}

- (void)didHide
{
    [[MLThumbnailerQueue sharedThumbnailerQueue] setDefaultPriorityForFile:self];
}

- (NSManagedObject *)videoTrack
{
    NSSet *tracks = [self tracks];
    if (!tracks)
        return nil;
    for (NSManagedObject *track in tracks) {
        if ([[[track entity] name] isEqualToString:@"VideoTrackInformation"])
            return track;
    }
    return nil;
}

- (size_t)fileSizeInBytes
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:[[[NSURL URLWithString:self.url] path] stringByResolvingSymlinksInPath] error:nil];
    NSNumber *fileSize = fileAttributes[NSFileSize];
    return [fileSize unsignedLongLongValue];
}

@end
