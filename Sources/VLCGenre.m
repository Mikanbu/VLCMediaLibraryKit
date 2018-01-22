/*****************************************************************************
 * VLCGenre.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2018 VLC authors and VideoLAN
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

#import "VLCGenre.h"
#import "VLCGenre+Init.h"
#import "VLCUtils.h"

@interface VLCGenre ()
{
    medialibrary::GenrePtr _genre;
}
@end

@implementation VLCGenre

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

- (NSArray<VLCArtist *> *)artistWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    return [VLCUtils arrayFromArtistPtrVector:_genre->artists((medialibrary::SortingCriteria)criteria, desc)];
}

- (NSArray<VLCMedia *> *)tracksWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    return [VLCUtils arrayFromMediaPtrVector:_genre->tracks((medialibrary::SortingCriteria)criteria, desc)];
}

- (NSArray<VLCAlbum *> *)albumsWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    return [VLCUtils arrayFromAlbumPtrVector:_genre->albums((medialibrary::SortingCriteria)criteria, desc)];
}

@end

@implementation VLCGenre (Internal)

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
