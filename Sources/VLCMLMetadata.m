/*****************************************************************************
 * VLCMLMetadata.m
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

#import "VLCMLMetadata.h"
#import "VLCMLMetadata+Init.h"
#import "VLCMLMedia.h"


@interface VLCMLMetadata ()
{
    const medialibrary::IMetadata *_metadata;
}

@property (nonatomic, copy) NSString *str;
@end

@implementation VLCMLMetadata

- (BOOL)isSet
{
    return _metadata->isSet();
}

- (int64_t)integer
{
    return _metadata->asInt();
}

- (NSString *)str
{
    if (!_str) {
        _str = [[NSString alloc] initWithUTF8String:_metadata->asStr().c_str()];
    }
    return _str;
}

@end

@implementation VLCMLMetadata (Internal)

- (instancetype)initWithMetadata:(const medialibrary::IMetadata &)metadata
{
    self = [super init];
    if (self) {
        _metadata = &metadata;
    }
    return self;
}

@end
