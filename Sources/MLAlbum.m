/*****************************************************************************
 * MLAlbum.m
 * MediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2017 VLC authors and VideoLAN
 * $Id$
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
#import "MLAlbum+Init.h"
#import "MLMedia+Init.h"
#import "MLArtist+Init.h"
#import "MLGenre+Init.h"

@interface MLAlbum ()
{
    medialibrary::AlbumPtr _album;
}
@end

@implementation MLAlbum

#pragma mark - Getters/Setters

- (int64_t)identifier
{
    return _album->id();
}

- (NSString *)title
{
    if (!_title) {
        _title = [[NSString alloc] initWithUTF8String:_album->title().c_str()];
    }
    return _title;
}

- (uint)releaseYear
{
    return _album->releaseYear();
}

- (NSString *)shortSummary
{
    if (!_shortSummary) {
        _shortSummary = [[NSString alloc] initWithUTF8String:_album->shortSummary().c_str()];
    }
    return _shortSummary;
}

- (NSString *)artworkMrl
{
    if (!_artworkMrl) {
        _artworkMrl = [[NSString alloc] initWithUTF8String:_album->artworkMrl().c_str()];
    }
    return _artworkMrl;
}

- (MLArtist *)albumMainArtist
{
    return [[MLArtist alloc] initWithArtistPtr:_album->albumArtist()];
}

- (NSArray *)tracksWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    NSMutableArray *result = [NSMutableArray array];
    auto tracks = _album->tracks((medialibrary::SortingCriteria)criteria, desc);

    for (const auto &media : tracks) {
        [result addObject:[[MLMedia alloc] initWithMediaPtr:media]];
    }
    return result;
}

- (NSArray<MLMedia *> *)tracksByGenre:(MLGenre *)genre sortingCriteria:(MLSortingCriteria)criteria;
{
    auto tracks = _album->tracks([genre genrePtr], (medialibrary::SortingCriteria)criteria);
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &track : tracks) {
        [result addObject:[[MLMedia alloc] initWithMediaPtr:track]];
    }
    return result;
}

- (NSArray<MLArtist *> *)artistsOrderedBy:(BOOL)desc
{
    auto artists = _album->artists(desc);
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &artist : artists) {
        [result addObject:[[MLArtist alloc] initWithArtistPtr:artist]];
    }
    return result;
}

- (uint32_t)numberOfTracks
{
    return _album->nbTracks();
}

- (uint)duration
{
    return _album->duration();
}

@end

@implementation MLAlbum (Internal)

- (instancetype)initWithAlbumPtr:(medialibrary::AlbumPtr)albumPtr
{
    self = [super init];
    if (self) {
        _album = albumPtr;
    }
    return self;
}

@end
