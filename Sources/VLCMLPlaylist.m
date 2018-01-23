/*****************************************************************************
 * VLCMLPlaylist.h
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

#import "VLCMLPlaylist.h"

@interface VLCMLPlaylist ()
{
    medialibrary::PlaylistPtr _playlist;
}
@end

@implementation VLCMLPlaylist

- (int64_t)identifier
{
    return _playlist->id();
}

- (NSString *)name
{
    if (!_name) {
        _name = [[NSString alloc] initWithUTF8String:_playlist->name().c_str()];
    }
    return _name;
}

- (BOOL)updateName:(NSString *)name
{
    return _playlist->setName([name UTF8String]);
}

- (uint)creationDate
{
    return _playlist->creationDate();
}

- (NSArray<VLCMLMedia *> *)media
{
    return nil;
}

- (BOOL)appendMediaWithIdentifier:(int64_t)identifier
{
    return _playlist->append(identifier);
}

- (BOOL)addMediaWithIdentifier:(int64_t)identifier at:(uint)position
{
    return _playlist->add(identifier, position);
}

- (BOOL)moveMediaWithIdentifier:(int64_t)identifier at:(uint)position
{
    return _playlist->move(identifier, position);
}

- (BOOL)removeMediaWithIdentifier:(int64_t)identifier
{
    return _playlist->remove(identifier);
}

@end

@implementation VLCMLPlaylist (Internal)

- (instancetype)initWithPlaylistPtr:(medialibrary::PlaylistPtr)playlistPtr
{
    self = [super init];
    if (self) {
        _playlist = playlistPtr;
    }
    return self;
}

@end
