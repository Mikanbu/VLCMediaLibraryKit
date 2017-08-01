/*****************************************************************************
 * MLArtist.m
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

#import "MLArtist.h"
#import "MLArtist+Init.h"
#import "MLMedia.h"
#import "MLMedia+Init.h"
#import "MLAlbum.h"
#import "MLAlbum+Init.h"
#import "MLMediaLibrary.h"

@interface MLArtist ()
{
    medialibrary::ArtistPtr _artist;
    medialibrary::IMediaLibrary *_ml;
}
@end

@implementation MLArtist

- (instancetype)initWithIdentifier:(int64_t)identifier
{
    self = [super init];
    if (self) {
        _ml = (medialibrary::IMediaLibrary *)[MLMediaLibrary sharedInstance];

        if ((_artist = _ml->artist(identifier)))
            [self _cacheValuesOfArtistPtr];
        NSAssert(_artist, @"Failed to init Artist with identifier: %lld", identifier);
    }
    return self;
}

#pragma mark - Helpers

- (void)_cacheValuesOfArtistPtr
{
    if (_artist) {
        _name = [NSString stringWithUTF8String:_artist->name().c_str()];
        _shortBio = [NSString stringWithUTF8String:_artist->shortBio().c_str()];
        _artworkMRL = [NSString stringWithUTF8String:_artist->artworkMrl().c_str()];
        _musicBrainzId = [NSString stringWithUTF8String:_artist->musicBrainzId().c_str()];
    }
}

#pragma mark - Getters/Setters

- (int64_t)identifier
{
    return _artist->id();
}

- (NSArray *)albums:(MLSortingCriteria)sortingCriteria
{
    NSMutableArray *result = [NSMutableArray array];
    auto albumVector = _artist->albums((medialibrary::SortingCriteria)sortingCriteria);

    for (const auto &album : albumVector) {
        MLAlbum *mlAlbum = [[MLAlbum alloc] initWithAlbumPtr:album];
        [result addObject:mlAlbum];
    }
    return result;
}

- (NSArray *)media:(MLSortingCriteria)sortingCriteria
{
    NSMutableArray *result = [NSMutableArray array];
    auto mediaVector = _artist->media((medialibrary::SortingCriteria)sortingCriteria);

    for (const auto &media : mediaVector) {
        MLMedia *mlMedia = [[MLMedia alloc] initWithMediaPtr:media];
        [result addObject:mlMedia];
    }
    return result;
}

@end

@implementation MLArtist (Internal)

- (instancetype)initWithArtistPtr:(medialibrary::ArtistPtr)artistPtr
{
    self = [super init];
    if (self) {
        _artist = artistPtr;
        [self _cacheValuesOfArtistPtr];
    }
    return self;
}

- (medialibrary::ArtistPtr)artistPtr
{
    return _artist;
}

@end
