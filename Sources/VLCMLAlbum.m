/*****************************************************************************
 * VLCMLAlbum.m
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

#import "VLCMLAlbum.h"
#import "VLCMLAlbum+Init.h"
#import "VLCMLArtist+Init.h"
#import "VLCMLGenre+Init.h"
#import "VLCMLUtils.h"
#import "VLCMediaLibrary.h"

@interface VLCMLAlbum ()
{
    medialibrary::AlbumPtr _album;
}
@end

@implementation VLCMLAlbum

#pragma mark - Getters/Setters

- (VLCMLIdentifier)identifier
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

- (VLCMLArtist *)albumMainArtist
{
    return [[VLCMLArtist alloc] initWithArtistPtr:_album->albumArtist()];
}

- (NSArray<VLCMLMedia *> *)tracks
{
    if (!_tracks) {
        _tracks = [self tracksWithSortingCriteria:VLCMLSortingCriteriaDefault desc:YES];
    }
    return _tracks;
}

- (NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    _tracks = [VLCMLUtils arrayFromMediaPtrVector:_album->tracks((medialibrary::SortingCriteria)criteria, desc)];
    return _tracks;
}

- (NSArray<VLCMLMedia *> *)tracksByGenre:(VLCMLGenre *)genre sortingCriteria:(VLCMLSortingCriteria)criteria;
{
    _tracks = [VLCMLUtils arrayFromMediaPtrVector:_album->tracks([genre genrePtr], (medialibrary::SortingCriteria)criteria)];
    return _tracks;
}

- (NSArray<VLCMLArtist *> *)artistsByDesc:(BOOL)desc
{
    return [VLCMLUtils arrayFromArtistPtrVector:_album->artists(desc)];
}

- (UInt32)numberOfTracks
{
    return _album->nbTracks();
}

- (uint)duration
{
    return _album->duration();
}

@end

@implementation VLCMLAlbum (Internal)

- (instancetype)initWithAlbumPtr:(medialibrary::AlbumPtr)albumPtr
{
    if (albumPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _album = albumPtr;
    }
    return self;
}

@end
