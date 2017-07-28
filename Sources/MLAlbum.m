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
#import "MLMedia.h"
#import "MLMedia+Init.h"
#import "MLArtist.h"
#import "PimplHelper.h"
#import "MLMediaLibrary.h"

@interface MLAlbum ()
{
    medialibrary::AlbumPtr _album;
    medialibrary::IMediaLibrary *_ml;
}
@end

@implementation MLAlbum

#pragma mark - Initilization

- (void)_cacheValuesOfAlbumPtr
{
    if (_album) {
        _name = [[NSString alloc] initWithUTF8String:_album->title().c_str()];
        _shortsummary = [[NSString alloc] initWithUTF8String:_album->shortSummary().c_str()];
        _artworkMRL = [[NSString alloc] initWithUTF8String:_album->artworkMrl().c_str()];
    }
}

- (instancetype)initWithIdentifier:(int64_t)identifier
{
    self = [super init];
    if (self) {
        _ml = (medialibrary::IMediaLibrary *)[[MLMediaLibrary alloc] instance];
        NSAssert(_ml, @"Failed to retrieve medialibrary instance!");
        _album = _ml->album(identifier);
        NSAssert(_album, @"Failed to retrieve an album with the identifier: %lld!", identifier);
        [self _cacheValuesOfAlbumPtr];
    }
    return self;
}

#pragma mark - Getters/Setters

- (int64_t)identifier
{
    return _album->id();
}

- (MLArtist *)albumMainArtist
{
    return [[MLArtist alloc] initWithIdentifier:_album->albumArtist()->id()];
}

- (NSArray *)artists
{
    return nil;
}

- (NSArray *)tracks:(MLSortingCriteria)sortingCriteria desc:(BOOL)desc
{
    NSMutableArray *result = [NSMutableArray array];
    auto tracks = _album->tracks((medialibrary::SortingCriteria)sortingCriteria, desc);

    for (auto media : tracks) {
        struct mediaImpl tmp;
        tmp.mediaPtr = media;
        MLMedia *tmpMedia = [[MLMedia alloc] initWithMediaPtr:&tmp];
        [result addObject:tmpMedia];
    }
    return result;
}

- (void)tracks
{
    auto tracks = _album->tracks();
}

@end

@implementation MLAlbum (Internal)

- (instancetype)initWithAlbumPtr:(struct albumImpl *)impl
{
    self = [super init];
    if (self) {
        _album = impl->albumPtr;
        [self _cacheValuesOfAlbumPtr];
    }
    return self;
}

@end
