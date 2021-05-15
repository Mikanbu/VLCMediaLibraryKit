/*****************************************************************************
 * VLCMLPlaylist.h
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

#import "VLCMLPlaylist.h"
#import "VLCMLMedia+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLPlaylist ()
{
    medialibrary::PlaylistPtr _playlist;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSArray<VLCMLMedia *> *media;
@property (nonatomic) BOOL isReadOnly;
@property (nonatomic, copy, nullable) NSURL *mrl;
@end

@implementation VLCMLPlaylist

- (VLCMLIdentifier)identifier
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

- (BOOL)isReadOnly
{
    return _playlist->isReadOnly();
}

- (nullable NSURL *)mrl
{
    return [[NSURL alloc] initWithString:[NSString stringWithUTF8String:_playlist->mrl().c_str()]];
}

- (uint)creationDate
{
    return _playlist->creationDate();
}

- (NSString *)artworkMrl
{
    return [NSString stringWithUTF8String:_playlist->artworkMrl().c_str()];
}

- (NSArray<VLCMLMedia *> *)media
{
    return [VLCMLUtils arrayFromMediaQuery:_playlist->media()];;
}

- (NSArray<VLCMLMedia *> *)searchMediaWithPattern:(NSString *)pattern
                                             sort:(VLCMLSortingCriteria)criteria
                                             desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_playlist->searchMedia([pattern UTF8String],
                                                                  &param)];
}

- (BOOL)appendMedia:(VLCMLMedia *)media
{
    return _playlist->append(*media.mediaPtr);
}

- (BOOL)appendMediaWithIdentifier:(VLCMLIdentifier)identifier
{
    return _playlist->append(identifier);
}

- (BOOL)addMedia:(VLCMLMedia *)media atPosition:(uint32_t)position
{
    return _playlist->add(*media.mediaPtr, position);
}

- (BOOL)addMediaWithIdentifier:(VLCMLIdentifier)identifier atPosition:(uint32_t)position
{
    return _playlist->add(identifier, position);
}

- (BOOL)moveMediaFromPosition:(uint32_t)position toDestination:(uint32_t)destination
{
    return _playlist->move(position, destination);
}

- (BOOL)removeMediaFromPosition:(uint32_t)position
{
    return _playlist->remove(position);
}

@end

@implementation VLCMLPlaylist (Internal)

- (instancetype)initWithPlaylistPtr:(medialibrary::PlaylistPtr)playlistPtr
{
    if (playlistPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _playlist = playlistPtr;
    }
    return self;
}

@end
