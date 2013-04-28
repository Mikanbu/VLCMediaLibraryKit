/*****************************************************************************
 * MLShow.m
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

#import "MLShow.h"
#import "MLMediaLibrary.h"

@implementation MLShow

+ (NSArray *)allShows
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [[MLMediaLibrary sharedMediaLibrary] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Show" inManagedObjectContext:moc];
    [request setEntity:entity];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [request setSortDescriptors:@[descriptor]];

    NSArray *shows = [moc executeFetchRequest:request error:nil];
    [request release];
    [descriptor release];

    return shows;
}

+ (MLShow *)showWithName:(NSString *)name
{
    NSFetchRequest *request = [[MLMediaLibrary sharedMediaLibrary] fetchRequestForEntity:@"Show"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];

    NSArray *dbResults = [[[MLMediaLibrary sharedMediaLibrary] managedObjectContext] executeFetchRequest:request error:nil];
    NSAssert(dbResults, @"Can't execute fetch request");

    if ([dbResults count] <= 0)
        return nil;

    return dbResults[0];
}


@dynamic theTVDBID;
@dynamic shortSummary;
@dynamic artworkURL;
@dynamic name;
@dynamic lastSyncDate;
@dynamic releaseYear;
@dynamic episodes;
@dynamic unreadEpisodes;

//- (NSSet *)unreadEpisodes
//{
//    NSSet *episodes = [self episodes];
//    NSMutableSet *set = [NSMutableSet set];
//    for(id episode in set) {
//        NSSet *files = [episode valueForKey:@"files"];
//        for(id file in files) {
//            if ([[file valueForKey:@"unread"] boolValue]) {
//                [set addObject:episode];
//                break;
//            }
//        }
//    }
//    return set;
//}
@end
