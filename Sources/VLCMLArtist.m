/*****************************************************************************
 * VLCMLArtist.m
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

#import "VLCMLArtist.h"
#import "VLCMLArtist+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLArtist ()
{
    medialibrary::ArtistPtr _artist;
}
@end

@implementation VLCMLArtist

#pragma mark - Getters/Setters

- (VLCMLIdentifier)identifier
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

- (NSURL *)artworkMrl
{
    if (!_artworkMrl) {
        _artworkMrl = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:_artist->thumbnailMrl().c_str()]];
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

- (NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = (medialibrary::QueryParameters) {
        .sort = (medialibrary::SortingCriteria)criteria,
        .desc = static_cast<bool>(desc)
    };

    return [VLCMLUtils arrayFromAlbumPtrVector:_artist->albums(&param)->all()];
}

- (NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = (medialibrary::QueryParameters) {
        .sort = (medialibrary::SortingCriteria)criteria,
        .desc = static_cast<bool>(desc)
    };

    return [VLCMLUtils arrayFromMediaPtrVector:_artist->tracks(&param)->all()];
}

@end

@implementation VLCMLArtist (Internal)

- (instancetype)initWithArtistPtr:(medialibrary::ArtistPtr)artistPtr
{
    if (artistPtr == nullptr) {
        return NULL;
    }

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
