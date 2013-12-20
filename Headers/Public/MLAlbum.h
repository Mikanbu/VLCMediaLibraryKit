/*****************************************************************************
 * MLAlbum.h
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

@class MLAlbumTrack;

@interface MLAlbum : NSManagedObject

+ (NSArray *)allAlbums;
+ (MLAlbum *)albumWithName:(NSString *)name;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *releaseYear;
@property (nonatomic, retain) NSSet *tracks;
@property (nonatomic, retain, readonly) NSSet *unreadTracks;
@property (nonatomic, readonly) NSArray *sortedTracks;

- (void)removeTrack:(MLAlbumTrack *)track;
- (void)removeTrackWithNumber:(NSNumber *)trackNumber;

@end


@interface MLAlbum (CoreDataGeneratedAccessors)
- (void)addTracksObject:(NSManagedObject *)value;
- (void)removeTracksObject:(NSManagedObject *)value;
- (void)addTracks:(NSSet *)value;
- (void)removeTracks:(NSSet *)value;
@end
