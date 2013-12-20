/*****************************************************************************
 * MLShow.h
 * Lunettes
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2013 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
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

#import <CoreData/CoreData.h>

@class MLShowEpisode;

@interface MLShow :  NSManagedObject
{
}

+ (NSArray *)allShows;
+ (MLShow *)showWithName:(NSString *)name;

@property (nonatomic, retain) NSString *theTVDBID;
@property (nonatomic, retain) NSString *shortSummary;
@property (nonatomic, retain) NSString *artworkURL;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *releaseYear;
@property (nonatomic, retain) NSNumber *lastSyncDate;
@property (nonatomic, retain) NSSet *episodes;
@property (nonatomic, readonly) NSArray *sortedEpisodes;
@property (nonatomic, retain, readonly) NSSet *unreadEpisodes;

- (void)removeEpisode:(MLShowEpisode*)episode;
- (void)removeEpisodeWithSeasonNumber:(NSNumber *)seasonNumber andEpisodeNumber:(NSNumber *)episodeNumber;

@end


@interface MLShow   (CoreDataGeneratedAccessors)
- (void)addEpisodesObject:(NSManagedObject *)value;
- (void)removeEpisodesObject:(NSManagedObject *)value;
- (void)addEpisodes:(NSSet *)value;
- (void)removeEpisodes:(NSSet *)value;

@end

