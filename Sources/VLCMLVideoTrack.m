/*****************************************************************************
 * VLCMLVideoTrack.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2017-2021 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
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

#import "VLCMLVideoTrack.h"
#import "VLCMLVideoTrack+Init.h"

@interface VLCMLVideoTrack ()
{
    medialibrary::VideoTrackPtr _videoTrack;
}

@property (nonatomic, copy) NSString *codec;
@property (nonatomic, copy) NSString *videoDescription;
@property (nonatomic, copy) NSString *language;
@end

@implementation VLCMLVideoTrack

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, codec: %@, desc: %@",
            NSStringFromClass([self class]), self.identifier, self.codec, self.videoDescription];
}

- (VLCMLIdentifier)identifier
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

- (UInt32)fpsNum
{
    return _videoTrack->fpsNum();
}

- (UInt32)fpsDen
{
    return _videoTrack->fpsDen();
}

- (UInt32)bitrate
{
    return _videoTrack->bitrate();
}

- (UInt32)sarNum
{
    return _videoTrack->sarNum();
}

- (UInt32)sarDen
{
    return _videoTrack->sarDen();
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

@implementation VLCMLVideoTrack (Internal)

- (instancetype)initWithVideoTrackPtr:(medialibrary::VideoTrackPtr)videoTrackPtr
{
    if (videoTrackPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _videoTrack = std::move(videoTrackPtr);
    }
    return self;
}

@end
