/*****************************************************************************
 * VLCMLAudioTrack.m
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

#import "VLCMLAudioTrack.h"
#import "VLCMLAudioTrack+Init.h"

@interface VLCMLAudioTrack ()
{
    medialibrary::AudioTrackPtr _audioTrack;
}

@property (nonatomic, copy) NSString *codec;
@property (nonatomic, copy) NSString *audioDescription;
@property (nonatomic, copy) NSString *language;
@end

@implementation VLCMLAudioTrack

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, desc: %@",
            NSStringFromClass([self class]), self.identifier, self.audioDescription];
}

- (VLCMLIdentifier)identifier
{
    return _audioTrack->id();
}

- (NSString *)codec
{
    if (!_codec) {
        _codec = [[NSString alloc] initWithUTF8String:_audioTrack->codec().c_str()];
    }
    return _codec;
}

- (uint)bitrate
{
    return _audioTrack->bitrate();
}

- (uint)sampleRate
{
    return _audioTrack->sampleRate();
}

- (uint)nbChannels
{
    return _audioTrack->nbChannels();
}

- (NSString *)audioDescription
{
    if (!_audioDescription) {
        _audioDescription = [[NSString alloc] initWithUTF8String:_audioTrack->description().c_str()];
    }
    return _audioDescription;
}

- (NSString *)language
{
    if (!_language) {
        _language = [[NSString alloc] initWithUTF8String:_audioTrack->language().c_str()];
    }
    return _language;
}

@end

@implementation VLCMLAudioTrack (Internal)

- (instancetype)initWithAudioTrackPtr:(medialibrary::AudioTrackPtr)audioTrackPtr
{
    if (audioTrackPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _audioTrack = std::move(audioTrackPtr);
    }
    return self;
}

@end
