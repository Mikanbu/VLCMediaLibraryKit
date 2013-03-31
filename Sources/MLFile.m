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
#import "MLMediaLibrary.h"
#import "MLThumbnailerQueue.h"

NSString *kMLFileTypeMovie = @"movie";
NSString *kMLFileTypeClip = @"clip";
NSString *kMLFileTypeTVShowEpisode = @"tvShowEpisode";

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
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];

    NSError *error;
    NSArray *movies = [moc executeFetchRequest:request error:&error];
    [request release];
    [descriptor release];
    if (!movies) {
        APLog(@"WARNING: %@", error);
    }

    return movies;
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
        NSString *name = [NSString stringWithFormat:@"%@ - S%02dE%02d",
                          episode.show.name, [episode.seasonNumber intValue],
                          [episode.episodeNumber intValue]];
        return episode.name ? [name stringByAppendingFormat:@" - %@", episode.name]
                            : name;
    }
    [self willAccessValueForKey:@"title"];
    NSString *ret = [self primitiveValueForKey:@"title"];
    [self didAccessValueForKey:@"title"];
    return ret;
}

@dynamic seasonNumber;
@dynamic remainingTime;
@dynamic releaseYear;
@dynamic lastPosition;
@dynamic playCount;
@dynamic artworkURL;
@dynamic url;
@dynamic type;
@dynamic title;
@dynamic shortSummary;
@dynamic currentlyWatching;
@dynamic episodeNumber;
@dynamic unread;
@dynamic hasFetchedInfo;
@dynamic noOnlineMetaData;
@dynamic showEpisode;
@dynamic labels;
@dynamic tracks;
@dynamic isOnDisk;
@dynamic duration;

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
    [self willChangeValueForKey:@"isSafe"];
    [self setPrimitiveValue:[NSNumber numberWithBool:isSafe] forKey:@"isSafe"];
    [self willChangeValueForKey:@"isSafe"];
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
    [self willChangeValueForKey:@"isBeingParsed"];
    [self setPrimitiveValue:[NSNumber numberWithBool:isBeingParsed] forKey:@"isBeingParsed"];
    [self willChangeValueForKey:@"isBeingParsed"];
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
    [self willChangeValueForKey:@"thumbnailTimeouted"];
    [self setPrimitiveValue:[NSNumber numberWithBool:thumbnailTimeouted] forKey:@"thumbnailTimeouted"];
    [self willChangeValueForKey:@"thumbnailTimeouted"];
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
    NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
    return [fileSize unsignedLongLongValue];
}

@end
