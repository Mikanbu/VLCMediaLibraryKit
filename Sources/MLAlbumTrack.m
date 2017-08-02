/*****************************************************************************
 * MLAlbumTrack.m
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

#import "MLAlbumTrack.h"
#import "MLAlbumTrack+Init.h"
#import "MLArtist+Init.h"
#import "MLGenre+Init.h"
#import "MLAlbum+Init.h"
#import "MLMedia+Init.h"

@interface MLAlbumTrack ()
{
    medialibrary::AlbumTrackPtr _albumTrackPtr;
}
@end

@implementation MLAlbumTrack

- (int64_t)identifier
{
    return _albumTrackPtr->id();
}

- (MLArtist *)artist
{
    if (!_artist) {
        _artist = [[MLArtist alloc] initWithArtistPtr:_albumTrackPtr->artist()];
    }
    return _artist;
}

- (MLGenre *)genre
{
    if (!_genre) {
        _genre = [[MLGenre alloc] initWithGenrePtr:_albumTrackPtr->genre()];
    }
    return _genre;
}

- (uint)trackNumber
{
    return _albumTrackPtr->trackNumber();
}

- (MLAlbum *)album
{
    if (!_album) {
        _album = [[MLAlbum alloc] initWithAlbumPtr:_albumTrackPtr->album()];
    }
    return _album;
}

- (MLMedia *)media
{
    if (!_media) {
        _media = [[MLMedia alloc] initWithMediaPtr:_albumTrackPtr->media()];
    }
    return _media;
}

- (uint)discNumber
{
    return _albumTrackPtr->discNumber();
}

@end

@implementation MLAlbumTrack (Internal)

- (instancetype)initWithAlbumTrackPtr:(medialibrary::AlbumTrackPtr)albumTrackPtr
{
    self = [super init];
    if (self) {
        _albumTrackPtr = albumTrackPtr;
    }
    return self;
}

@end
