/*****************************************************************************
 * VLCMediaMetadata.m
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

#import "VLCMediaMetadata.h"
#import "VLCMediaMetadata+Init.h"
#import "VLCMedia.h"

@interface VLCMediaMetadata ()
{
    const medialibrary::IMediaMetadata *_metadata;
}
@end

@implementation VLCMediaMetadata

- (BOOL)isSet
{
    return _metadata->isSet();
}

- (int64_t)integer
{
    return _metadata->integer();
}

- (NSString *)str
{
    if (!_str) {
        _str = [[NSString alloc] initWithUTF8String:_metadata->str().c_str()];
    }
    return _str;
}

@end

@implementation VLCMediaMetadata (Internal)

- (instancetype)initWithMediaMetadata:(const medialibrary::IMediaMetadata &)metadata
{
    self = [super init];
    if (self) {
        _metadata = &metadata;
    }
    return self;
}

@end
