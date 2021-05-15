/*****************************************************************************
 * VLCMLSubtitleTrack.m
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

#import "VLCMLSubtitleTrack.h"
#import "VLCMLSubtitleTrack+Init.h"

@interface VLCMLSubtitleTrack ()
{
    medialibrary::SubtitleTrackPtr _subTrack;
}

@property (nonatomic, copy) NSString *codec;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *trackDescription;
@property (nonatomic, copy) NSString *encoding;
@end

@implementation VLCMLSubtitleTrack

- (VLCMLIdentifier)identifier {
    return _subTrack->id();
}

- (NSString *)codec
{
    if (_codec) {
        _codec = [NSString stringWithUTF8String:_subTrack->codec().c_str()];
    }
    return _codec;
}

- (NSString *)language
{
    if (_language) {
        _language = [NSString stringWithUTF8String:_subTrack->language().c_str()];
    }
    return _language;
}

- (NSString *)trackDescription
{
    if (_trackDescription) {
        _trackDescription = [NSString stringWithUTF8String:_subTrack->description().c_str()];
    }
    return _trackDescription;
}

- (NSString *)encoding
{
    if (_encoding) {
        _encoding = [NSString stringWithUTF8String:_subTrack->encoding().c_str()];
    }
    return _encoding;
}

@end

@implementation VLCMLSubtitleTrack (Internal)

- (instancetype)initWithSubtitleTrackPtr:(medialibrary::SubtitleTrackPtr)subTrackPtr
{
    if (subTrackPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _subTrack = subTrackPtr;
    }
    return self;
}

- (medialibrary::SubtitleTrackPtr)subTrackPtr
{
    return _subTrack;
}

@end
