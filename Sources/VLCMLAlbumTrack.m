/*****************************************************************************
 * VLCMLAlbumTrack.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2021 VLC authors and VideoLAN
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

#import "VLCMLAlbumTrack.h"
#import "VLCMLAlbumTrack+Init.h"
#import "VLCMLArtist+Init.h"
#import "VLCMLGenre+Init.h"
#import "VLCMLAlbum+Init.h"
#import "VLCMLMedia+Init.h"

@interface VLCMLAlbumTrack ()
{
    medialibrary::AlbumTrackPtr _albumTrackPtr;
}

@property (nonatomic, strong, nullable) VLCMLArtist *artist;
@property (nonatomic, strong, nullable) VLCMLGenre *genre;
@property (nonatomic, strong, nullable) VLCMLAlbum *album;
@end

@implementation VLCMLAlbumTrack

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, artist: %@",
            NSStringFromClass([self class]), self.identifier, self.artist];
}

- (VLCMLIdentifier)identifier
{
    return _albumTrackPtr->id();
}

- (VLCMLArtist *)artist
{
    if (!_artist) {
        _artist = [[VLCMLArtist alloc] initWithArtistPtr:_albumTrackPtr->artist()];
    }
    return _artist;
}

- (VLCMLGenre *)genre
{
    if (!_genre) {
        _genre = [[VLCMLGenre alloc] initWithGenrePtr:_albumTrackPtr->genre()];
    }
    return _genre;
}

- (uint)trackNumber
{
    return _albumTrackPtr->trackNumber();
}

- (VLCMLAlbum *)album
{
    if (!_album) {
        _album = [[VLCMLAlbum alloc] initWithAlbumPtr:_albumTrackPtr->album()];
    }
    return _album;
}

- (uint)discNumber
{
    return _albumTrackPtr->discNumber();
}

@end

@implementation VLCMLAlbumTrack (Internal)

- (instancetype)initWithAlbumTrackPtr:(medialibrary::AlbumTrackPtr)albumTrackPtr
{
    if (albumTrackPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _albumTrackPtr = std::move(albumTrackPtr);
    }
    return self;
}

@end
