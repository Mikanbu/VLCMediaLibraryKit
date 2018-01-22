/*****************************************************************************
 * VLCAlbum.m
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

#import "VLCAlbum.h"
#import "VLCAlbum+Init.h"
#import "VLCArtist+Init.h"
#import "VLCGenre+Init.h"
#import "VLCUtils.h"
#import "VLCMediaLibrary.h"

@interface VLCAlbum ()
{
    medialibrary::AlbumPtr _album;
}
@end

@implementation VLCAlbum

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

- (VLCArtist *)albumMainArtist
{
    return [[VLCArtist alloc] initWithArtistPtr:_album->albumArtist()];
}

- (NSArray<VLCMedia *> *)tracks
{
    if (!_tracks) {
        _tracks = [self tracksWithSortingCriteria:VLCSortingCriteriaDefault desc:YES];
    }
    return _tracks;
}

- (NSArray<VLCMedia *> *)tracksWithSortingCriteria:(VLCSortingCriteria)criteria desc:(BOOL)desc
{
    _tracks = [VLCUtils arrayFromMediaPtrVector:_album->tracks((medialibrary::SortingCriteria)criteria, desc)];
    return _tracks;
}

- (NSArray<VLCMedia *> *)tracksByGenre:(VLCGenre *)genre sortingCriteria:(VLCSortingCriteria)criteria;
{
    _tracks = [VLCUtils arrayFromMediaPtrVector:_album->tracks([genre genrePtr], (medialibrary::SortingCriteria)criteria)];
    return _tracks;
}

- (NSArray<VLCArtist *> *)artistsByDesc:(BOOL)desc
{
    return [VLCUtils arrayFromArtistPtrVector:_album->artists(desc)];
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

@implementation VLCAlbum (Internal)

- (instancetype)initWithAlbumPtr:(medialibrary::AlbumPtr)albumPtr
{
    self = [super init];
    if (self) {
        _album = albumPtr;
    }
    return self;
}

@end
