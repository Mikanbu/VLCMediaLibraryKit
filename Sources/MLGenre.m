/*****************************************************************************
 * MLGenre.m
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

#import "MLGenre.h"
#import "MLMedia+Init.h"
#import "MLAlbum+Init.h"
#import "MLGenre+Init.h"
#import "MLArtist+Init.h"


@interface MLGenre ()
{
    medialibrary::GenrePtr _genre;
}
@end

@implementation MLGenre

- (int64_t)identifier
{
    return _genre->id();
}

- (NSString *)name
{
    if (!_name)
        _name = [[NSString alloc] initWithUTF8String:_genre->name().c_str()];
    return _name;
}

- (uint32_t)numberOfTracks
{
    return _genre->nbTracks();
}

- (NSArray<MLArtist *> *)artistWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto artists = _genre->artists();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &artist : artists) {
        [result addObject:[[MLArtist alloc] initWithArtistPtr:artist]];
    }
    return result;
}

- (NSArray<MLMedia *> *)tracksWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto tracks = _genre->tracks();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &track : tracks) {
        [result addObject:[[MLMedia alloc] initWithMediaPtr:track]];
    }
    return result;
}

- (NSArray<MLAlbum *> *)albumsWithSortingCriteria:(MLSortingCriteria)criteria orderedBy:(BOOL)desc
{
    auto albums = _genre->albums();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &album : albums) {
        [result addObject:[[MLAlbum alloc] initWithAlbumPtr:album]];
    }
    return result;
}

@end

@implementation MLGenre (Internal)

- (instancetype)initWithGenrePtr:(medialibrary::GenrePtr)genrePtr
{
    self = [super init];
    if (self) {
        _genre = genrePtr;
    }
    return self;
}

-(medialibrary::GenrePtr)genrePtr
{
    return _genre;
}

@end
