/*****************************************************************************
 * VLCAlbumTrack.m
 * MediaLibraryKit
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

#import "VLCAlbumTrack.h"
#import "VLCAlbumTrack+Init.h"
#import "VLCArtist+Init.h"
#import "VLCGenre+Init.h"
#import "VLCAlbum+Init.h"
#import "VLCMedia+Init.h"

@interface VLCAlbumTrack ()
{
    medialibrary::AlbumTrackPtr _albumTrackPtr;
}
@end

@implementation VLCAlbumTrack

- (int64_t)identifier
{
    return _albumTrackPtr->id();
}

- (VLCArtist *)artist
{
    if (!_artist) {
        _artist = [[VLCArtist alloc] initWithArtistPtr:_albumTrackPtr->artist()];
    }
    return _artist;
}

- (VLCGenre *)genre
{
    if (!_genre) {
        _genre = [[VLCGenre alloc] initWithGenrePtr:_albumTrackPtr->genre()];
    }
    return _genre;
}

- (uint)trackNumber
{
    return _albumTrackPtr->trackNumber();
}

- (VLCAlbum *)album
{
    if (!_album) {
        _album = [[VLCAlbum alloc] initWithAlbumPtr:_albumTrackPtr->album()];
    }
    return _album;
}

- (VLCMedia *)media
{
    if (!_media) {
        _media = [[VLCMedia alloc] initWithMediaPtr:_albumTrackPtr->media()];
    }
    return _media;
}

- (uint)discNumber
{
    return _albumTrackPtr->discNumber();
}

@end

@implementation VLCAlbumTrack (Internal)

- (instancetype)initWithAlbumTrackPtr:(medialibrary::AlbumTrackPtr)albumTrackPtr
{
    self = [super init];
    if (self) {
        _albumTrackPtr = albumTrackPtr;
    }
    return self;
}

@end
