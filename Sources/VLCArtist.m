/*****************************************************************************
 * VLCArtist.m
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

#import "VLCArtist.h"
#import "VLCArtist+Init.h"
#import "VLCUtils.h"

@interface VLCArtist ()
{
    medialibrary::ArtistPtr _artist;
}
@end

@implementation VLCArtist

#pragma mark - Getters/Setters

- (int64_t)identifier
{
    return _artist->id();
}

- (NSString *)name
{
    if (!_name) {
        _name = [NSString stringWithUTF8String:_artist->name().c_str()];
    }
    return _name;
}

- (NSString *)shortBio
{
    if (!_shortBio) {
        _shortBio = [NSString stringWithUTF8String:_artist->shortBio().c_str()];
    }
    return _shortBio;
}

- (NSString *)artworkMrl
{
    if (!_artworkMrl) {
        _artworkMrl = [NSString stringWithUTF8String:_artist->artworkMrl().c_str()];
    }
    return _artworkMrl;
}

- (NSString *)musicBrainzId
{
    if (!_musicBrainzId) {
        _musicBrainzId = [NSString stringWithUTF8String:_artist->musicBrainzId().c_str()];
    }
    return _musicBrainzId;
}

- (NSArray<VLCAlbum *> *)albums:(VLCSortingCriteria)sortingCriteria
{
    return [VLCUtils arrayFromAlbumPtrVector:_artist->albums((medialibrary::SortingCriteria)sortingCriteria)];
}

- (NSArray<VLCMedia *> *)media:(VLCSortingCriteria)sortingCriteria
{
    return [VLCUtils arrayFromMediaPtrVector:_artist->media((medialibrary::SortingCriteria)sortingCriteria)];
}

@end

@implementation VLCArtist (Internal)

- (instancetype)initWithArtistPtr:(medialibrary::ArtistPtr)artistPtr
{
    self = [super init];
    if (self) {
        _artist = artistPtr;
    }
    return self;
}

- (medialibrary::ArtistPtr)artistPtr
{
    return _artist;
}

@end
