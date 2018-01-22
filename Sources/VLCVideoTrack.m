/*****************************************************************************
 * VLCVideoTrack.m
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

#import "VLCVideoTrack.h"
#import "VLCVideoTrack+Init.h"

@interface VLCVideoTrack ()
{
    medialibrary::VideoTrackPtr _videoTrack;
}
@end

@implementation VLCVideoTrack

- (int64_t)identifier
{
    return _videoTrack->id();
}

- (NSString *)codec
{
    if (!_codec) {
        _codec = [[NSString alloc] initWithUTF8String:_videoTrack->codec().c_str()];
    }
    return _codec;
}

- (uint)width
{
    return _videoTrack->width();
}

- (uint)height
{
    return _videoTrack->height();
}

- (float)fps
{
    return _videoTrack->fps();
}

- (NSString *)videoDescription
{
    if (!_videoDescription) {
        _videoDescription = [[NSString alloc] initWithUTF8String:_videoTrack->description().c_str()];
    }
    return _videoDescription;
}

- (NSString *)language
{
    if (!_language) {
        _language = [[NSString alloc] initWithUTF8String:_videoTrack->language().c_str()];
    }
    return _language;
}

@end

@implementation VLCVideoTrack (Internal)

- (instancetype)initWithVideoTrackPtr:(medialibrary::VideoTrackPtr)videoTrackPtr
{
    self = [super init];
    if (self) {
        _videoTrack = videoTrackPtr;
    }
    return self;
}

@end
