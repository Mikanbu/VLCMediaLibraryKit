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
#import "MLGenre+Init.h"
#import "MLUtils.h"

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
    if (!_name) {
        _name = [[NSString alloc] initWithUTF8String:_genre->name().c_str()];
    }
    return _name;
}

- (uint32_t)numberOfTracks
{
    return _genre->nbTracks();
}

- (NSArray<MLArtist *> *)artistWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc
{
    return [MLUtils arrayFromArtistPtrVector:_genre->artists((medialibrary::SortingCriteria)criteria, desc)];
}

- (NSArray<MLMedia *> *)tracksWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc
{
    return [MLUtils arrayFromMediaPtrVector:_genre->tracks((medialibrary::SortingCriteria)criteria, desc)];
}

- (NSArray<MLAlbum *> *)albumsWithSortingCriteria:(MLSortingCriteria)criteria desc:(BOOL)desc
{
    return [MLUtils arrayFromAlbumPtrVector:_genre->albums((medialibrary::SortingCriteria)criteria, desc)];
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

- (medialibrary::GenrePtr)genrePtr
{
    return _genre;
}

@end
