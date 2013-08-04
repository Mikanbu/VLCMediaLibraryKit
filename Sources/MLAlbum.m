/*****************************************************************************
 * MLAlbum.m
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

#import "MLAlbum.h"
#import "MLMediaLibrary.h"

@implementation MLAlbum

+ (NSArray *)allAlbums
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = [[MLMediaLibrary sharedMediaLibrary] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:moc];
    [request setEntity:entity];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [request setSortDescriptors:@[descriptor]];

    NSArray *albums = [moc executeFetchRequest:request error:nil];
    [request release];
    [descriptor release];

    return albums;
}

+ (MLAlbum *)albumWithName:(NSString *)name
{
    NSFetchRequest *request = [[MLMediaLibrary sharedMediaLibrary] fetchRequestForEntity:@"Album"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];

    NSArray *dbResults = [[[MLMediaLibrary sharedMediaLibrary] managedObjectContext] executeFetchRequest:request error:nil];
    NSAssert(dbResults, @"Can't execute fetch request");

    if ([dbResults count] <= 0)
        return nil;

    return dbResults[0];
}

@dynamic name;
@dynamic releaseYear;
@dynamic tracks;
@dynamic unreadTracks;

@end
