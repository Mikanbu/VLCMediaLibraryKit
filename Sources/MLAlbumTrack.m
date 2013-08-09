/*****************************************************************************
 * MLAlbumTrack.m
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2013 Felix Paul Kühne
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
#import "MLAlbumTrack.h"
#import "MLAlbum.h"

@interface MLAlbumTrack ()
@property (nonatomic, retain) NSNumber *primitiveUnread;
@end

@implementation MLAlbumTrack

+ (NSArray *)allTracks
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [[MLMediaLibrary sharedMediaLibrary] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AlbumTrack" inManagedObjectContext:moc];
    [request setEntity:entity];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    [request setSortDescriptors:@[descriptor]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"files.@count > 0"]];

    NSArray *tracks = [moc executeFetchRequest:request error:nil];
    [request release];
    [descriptor release];

    return tracks;
}

+ (MLAlbumTrack *)trackWithAlbum:(id)album trackNumber:(NSNumber *)trackNumber createIfNeeded:(BOOL)createIfNeeded
{
    NSMutableSet *tracks = [album mutableSetValueForKey:@"tracks"];
    MLAlbumTrack *track = nil;
    if (trackNumber) {
        for (MLAlbumTrack *trackIter in tracks) {
            if ([trackIter.trackNumber intValue] == [trackNumber intValue]) {
                track = trackIter;
                break;
            }
        }
    }
    if (!track && createIfNeeded) {
        track = [[MLMediaLibrary sharedMediaLibrary] createObjectForEntity:@"AlbumTrack"];
        track.trackNumber = trackNumber;
        [tracks addObject:track];
    }
    return track;
}

+ (MLAlbumTrack *)trackWithAlbumName:(NSString *)albumName trackNumber:(NSNumber *)trackNumber createIfNeeded:(BOOL)createIfNeeded wasCreated:(BOOL *)wasCreated
{
    MLAlbum *album = [MLAlbum albumWithName:albumName];
    *wasCreated = NO;
    if (!album && createIfNeeded) {
        *wasCreated = YES;
        album = [[MLMediaLibrary sharedMediaLibrary] createObjectForEntity:@"Album"];
        album.name = albumName ? albumName : @"";
    } else if (!album && !createIfNeeded)
        return nil;

    return [MLAlbumTrack trackWithAlbum:album trackNumber:trackNumber createIfNeeded:createIfNeeded];
}

@dynamic primitiveUnread;
@dynamic unread;
- (void)setUnread:(NSNumber *)unread
{
    [self willChangeValueForKey:@"unread"];
    [self setPrimitiveUnread:unread];
    [self didChangeValueForKey:@"unread"];
    [[[MLMediaLibrary sharedMediaLibrary] managedObjectContext] refreshObject:[self album] mergeChanges:YES];
    [[[MLMediaLibrary sharedMediaLibrary] managedObjectContext] refreshObject:self mergeChanges:YES];
}

@dynamic artist;
@dynamic genre;
@dynamic title;
@dynamic trackNumber;
@dynamic album;
@dynamic files;
@end
